from datetime import datetime, timedelta
from typing import List, Optional, Literal, Any, Dict, Tuple
import os
import time
import base64
import json

import requests
from fastapi import FastAPI, Request, HTTPException, Depends
from pydantic import BaseModel, Field
try:
    from openai import OpenAI as OpenAIClient
except Exception:  # pragma: no cover
    OpenAIClient = None
try:
    import google.generativeai as genai
except Exception:  # pragma: no cover
    genai = None


# Schemas (alinhados a docs/ai/tools_contract.json)

Sexo = Literal["f", "m", "outro"]
NivelAtividade = Literal["sedentario", "leve", "moderado", "alto", "atleta"]
Objetivo = Literal["perda", "manutencao", "ganho"]
ProtocoloJejum = Literal["12:12", "14:10", "16:8", "18:6", "20:4", "omad"]
RefeicaoTipo = Literal["cafe", "almoco", "jantar", "lanche"]


class CalcularMetasIn(BaseModel):
    sexo: Sexo
    idade: float
    peso_kg: float
    altura_cm: float
    bf_percent: Optional[float] = None
    nivel_atividade: NivelAtividade
    objetivo: Objetivo
    ritmo_semana: Optional[float] = Field(None, description="kg/semana desejados")


class Macros(BaseModel):
    proteina: float
    carbo: float
    gordura: float


class CalcularMetasOut(BaseModel):
    bmr: float
    tdee: float
    kcal_meta: float
    macros_g: Macros


class PlanejarJejumIn(BaseModel):
    protocolo: ProtocoloJejum
    inicio_preferido: Optional[str] = None  # HH:MM local
    fuso: Optional[str] = None
    dias: int = 7


class Janela(BaseModel):
    inicio: str
    fim: str


class PlanejarJejumOut(BaseModel):
    janelas: List[Janela]
    lembretes: Optional[List[str]] = None


class NutricaoPor100g(BaseModel):
    kcal: float
    proteina: Optional[float] = None
    carbo: Optional[float] = None
    gordura: Optional[float] = None
    # Extras (paridade c/ Express):
    acucar: Optional[float] = None  # g
    fibra: Optional[float] = None   # g
    sal_g: Optional[float] = None   # g
    sodio_mg: Optional[float] = None  # mg


class NutricaoPorPorcao(BaseModel):
    kcal: Optional[float] = None
    proteina: Optional[float] = None
    carbo: Optional[float] = None
    gordura: Optional[float] = None
    acucar: Optional[float] = None
    fibra: Optional[float] = None
    sal_g: Optional[float] = None
    sodio_mg: Optional[float] = None


class ItemAlimento(BaseModel):
    id: str
    nome: str
    barcode: Optional[str] = None
    porcao_padrao: Optional[str] = None
    nutricao_por_100g: Optional[NutricaoPor100g] = None


class BuscarAlimentoIn(BaseModel):
    query: str
    fonte: Optional[Literal["taco", "usda", "open_food_facts", "local"]] = "open_food_facts"
    top_k: Optional[int] = 10


class BuscarAlimentoOut(BaseModel):
    itens: List[ItemAlimento]


class AnalisarBarcodeIn(BaseModel):
    barcode: str


class ItemNormalizado(BaseModel):
    id: str
    nome: str
    nutricao_por_porcao: Optional[NutricaoPorPorcao] = None


class AnalisarBarcodeOut(BaseModel):
    item: ItemNormalizado


class AnalisarFotoIn(BaseModel):
    image_url: Optional[str] = None
    image_base64: Optional[str] = None
    refeicao_tipo: Optional[RefeicaoTipo] = None


class CandidatoFoto(BaseModel):
    nome: str
    porcao: Optional[str] = None
    confianca: Optional[float] = None


class AnalisarFotoOut(BaseModel):
    candidatos: List[CandidatoFoto]


class ItemLog(BaseModel):
    id: Optional[str] = None
    nome: Optional[str] = None
    quantidade: float
    unidade: str


class LogRefeicaoIn(BaseModel):
    refeicao_tipo: RefeicaoTipo
    itens: List[ItemLog]
    origem: Optional[Literal["foto", "voz", "texto", "barcode", "sugestao"]] = None
    hora: Optional[str] = None


class Totais(BaseModel):
    kcal: float
    proteina: Optional[float] = 0.0
    carbo: Optional[float] = 0.0
    gordura: Optional[float] = 0.0


class LogRefeicaoOut(BaseModel):
    total: Totais
    itens: List[dict]


class SugerirRefeicaoIn(BaseModel):
    macros_restantes: Optional[dict] = None
    restricoes: Optional[List[str]] = None
    preferencias: Optional[List[str]] = None
    tempo_preparo_min: Optional[int] = None
    equipamentos: Optional[List[str]] = None


class Sugestao(BaseModel):
    nome: str
    kcal: Optional[float] = None
    macros_g: Optional[dict] = None
    passos: Optional[List[str]] = None


class SugerirRefeicaoOut(BaseModel):
    sugestoes: List[Sugestao]


class RegistrarCheckinIn(BaseModel):
    humor: Optional[str] = None
    fome: Optional[float] = Field(None, ge=0, le=10)
    energia: Optional[float] = Field(None, ge=0, le=10)
    jejum_status: Optional[Literal["ativo", "encerrado", "planejado"]] = None


class OkOut(BaseModel):
    ok: bool


class ObterEstatisticasOut(BaseModel):
    resumo: dict


class AtualizarPreferenciasIn(BaseModel):
    alergias: Optional[List[str]] = None
    restricoes: Optional[List[str]] = None
    preferencias: Optional[List[str]] = None


app = FastAPI(title="NutriTracker AI Coach API", version="0.1.0")


# Cache em memória simples com TTL (paridade c/ Express)
class TTLCache:
    def __init__(self, max_entries: int = 200, ttl_seconds: float = 3600.0):
        self.max = max_entries
        self.ttl = ttl_seconds
        self._store: Dict[str, Tuple[float, Any]] = {}

    def get(self, key: str):
        entry = self._store.get(key)
        if not entry:
            return None
        ts, val = entry
        if time.time() - ts > self.ttl:
            self._store.pop(key, None)
            return None
        return val

    def set(self, key: str, val: Any):
        if len(self._store) >= self.max:
            oldest = min(self._store, key=lambda k: self._store[k][0])
            self._store.pop(oldest, None)
        self._store[key] = (time.time(), val)


OFF_CACHE_TTL_MS = int(os.getenv("OFF_CACHE_TTL_MS", "3600000"))
CACHE_MAX = int(os.getenv("CACHE_MAX", "200"))
_cache = TTLCache(max_entries=CACHE_MAX, ttl_seconds=OFF_CACHE_TTL_MS / 1000.0)


# Configs de integrações
OFF_BASE_URL = os.getenv("OFF_BASE_URL", "https://world.openfoodfacts.org")
OFF_USER_AGENT = os.getenv("OFF_USER_AGENT", "nutritracker-ai-coach/0.1 (+https://example.com)")
VISION_PROVIDER = (os.getenv("VISION_PROVIDER") or "").lower()  # 'openai' | 'gemini'
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
OPENAI_VISION_MODEL = os.getenv("OPENAI_VISION_MODEL", "gpt-4o-mini")
GEMINI_VISION_MODEL = os.getenv("GEMINI_VISION_MODEL", "gemini-1.5-flash")
IMAGE_CACHE_TTL_MS = int(os.getenv("IMAGE_CACHE_TTL_MS", "3600000"))
_image_cache = TTLCache(max_entries=max(50, CACHE_MAX // 2), ttl_seconds=IMAGE_CACHE_TTL_MS / 1000.0)

# Rate limiting (in-memory window counter)
RL_WINDOW_MS = int(os.getenv("RATE_LIMIT_WINDOW_MS", "60000"))
RL_MAX_DEFAULT = int(os.getenv("RATE_LIMIT_MAX", "60"))
RL_MAX_PHOTO = int(os.getenv("RATE_LIMIT_PHOTO_MAX", "10"))


class WindowLimiter:
    def __init__(self, window_ms: int, max_req: int):
        self.window = window_ms / 1000.0
        self.max = max_req
        self._buckets: Dict[str, Tuple[float, int]] = {}

    def allow(self, key: str) -> bool:
        now = time.time()
        ts, cnt = self._buckets.get(key, (0.0, 0))
        if now - ts > self.window:
            self._buckets[key] = (now, 1)
            return True
        if cnt + 1 > self.max:
            return False
        self._buckets[key] = (ts, cnt + 1)
        return True


_limiter_default = WindowLimiter(RL_WINDOW_MS, RL_MAX_DEFAULT)
_limiter_photo = WindowLimiter(RL_WINDOW_MS, RL_MAX_PHOTO)


def enforce_default_limit(request: Request):
    ip = request.client.host if request.client else "anon"
    if not _limiter_default.allow(f"default:{ip}"):
        raise HTTPException(status_code=429, detail="Too Many Requests")


def enforce_photo_limit(request: Request):
    ip = request.client.host if request.client else "anon"
    if not _limiter_photo.allow(f"photo:{ip}"):
        raise HTTPException(status_code=429, detail="Too Many Requests (photo)")


# Helpers simples
def activity_multiplier(nivel: NivelAtividade) -> float:
    return {
        "sedentario": 1.2,
        "leve": 1.375,
        "moderado": 1.55,
        "alto": 1.725,
        "atleta": 1.9,
    }[nivel]


@app.get("/")
def root():
    return {"status": "ok", "service": "nutritracker-ai-coach"}


# --- Helpers de OFF e Nutrição ---
def _try_num(v):
    try:
        n = float(v)
        if n == float("inf") or n == float("-inf"):
            return None
        return n
    except Exception:
        return None


def _nutriment_of(nutr: dict, keys: List[str]):
    for k in keys:
        if k in nutr:
            val = _try_num(nutr[k])
            if val is not None:
                return val
    return None


def _extract_kcal_100g(nutr: dict):
    kcal = _nutriment_of(nutr, ["energy-kcal_100g", "energy-kcal_value_100g"])
    if kcal is not None:
        return kcal
    kj = _nutriment_of(nutr, ["energy-kj_100g", "energy_100g"])
    if kj is not None:
        return round(kj / 4.184, 1)
    return None


def _pick_off_name(p: dict) -> str:
    def c(v):
        return (str(v).strip() if v else None)
    return (
        c(p.get("product_name_pt"))
        or c(p.get("product_name"))
        or c(p.get("generic_name_pt"))
        or c(p.get("generic_name"))
        or c(p.get("product_name_en"))
        or c(p.get("generic_name_en"))
        or c(p.get("brands"))
        or c(p.get("code"))
        or "Produto"
    )


def _round1(x: Optional[float]):
    return round(x, 1) if x is not None else None


def _round0(x: Optional[float]):
    return round(x) if x is not None else None


def _derive_salt_sodium(salt_g: Optional[float], sodium_g: Optional[float]):
    ratio = 0.393
    out_salt = salt_g
    out_sodium = sodium_g
    if out_salt is None and out_sodium is not None:
        out_salt = out_sodium / ratio
    if out_sodium is None and out_salt is not None:
        out_sodium = out_salt * ratio
    return out_salt, out_sodium


def _extras_from_nutriments(nutr: dict, scope: str = "100g") -> Dict[str, Optional[float]]:
    suffix = "_serving" if scope == "serving" else "_100g"
    sugars = _nutriment_of(nutr, ["sugars" + suffix])
    fiber = _nutriment_of(nutr, ["fiber" + suffix])
    salt = _nutriment_of(nutr, ["salt" + suffix])
    sodium = _nutriment_of(nutr, ["sodium" + suffix])
    salt, sodium = _derive_salt_sodium(salt, sodium)
    return {
        "acucar": _round1(sugars),
        "fibra": _round1(fiber),
        "sal_g": _round1(salt),
        "sodio_mg": _round0(sodium * 1000) if sodium is not None else None,
    }


def _normalize_off_100g(p: dict) -> ItemAlimento:
    nutr = p.get("nutriments", {})
    kcal = _extract_kcal_100g(nutr)
    prot = _nutriment_of(nutr, ["proteins_100g"]) or None
    carb = _nutriment_of(nutr, ["carbohydrates_100g"]) or None
    fat = _nutriment_of(nutr, ["fat_100g"]) or None
    name = _pick_off_name(p)
    code = p.get("code") or p.get("_id") or name
    extras = _extras_from_nutriments(nutr, "100g")
    return ItemAlimento(
        id=str(code),
        nome=name,
        porcao_padrao="100 g",
        nutricao_por_100g=NutricaoPor100g(
            kcal=round(kcal) if kcal is not None else 0,
            proteina=_round1(prot),
            carbo=_round1(carb),
            gordura=_round1(fat),
            **extras,
        ),
    )


def _convert_to_grams(val: float, unit: str) -> Optional[float]:
    unit = unit.lower()
    if unit == "mg":
        return val / 1000
    if unit == "g":
        return val
    if unit == "kg":
        return val * 1000
    if unit == "ml":
        return val
    if unit == "l":
        return val * 1000
    if unit == "oz":
        return val * 28.3495
    return None


def _parse_serving_size_to_grams(serving_size: Optional[str]) -> Optional[float]:
    if not serving_size:
        return None
    txt = str(serving_size).lower()
    import re

    m = re.search(r"\(([0-9]+(?:\.[0-9]+)?)\s*(mg|g|kg|ml|l|oz)\)", txt)
    if m:
        val = float(m.group(1))
        unit = m.group(2)
        grams = _convert_to_grams(val, unit)
        if grams is not None:
            return grams

    m2 = re.search(r"(^|\s)([0-9]+(?:\.[0-9]+)?)\s*(mg|g|kg|ml|l|oz)(\s|$)", txt)
    if m2:
        val = float(m2.group(2))
        unit = m2.group(3)
        grams = _convert_to_grams(val, unit)
        if grams is not None:
            return grams
    return None


def _normalize_off_serving(p: dict) -> Dict[str, Any]:
    nutr = p.get("nutriments", {})
    kcal = _nutriment_of(nutr, ["energy-kcal_serving"]) or None
    prot = _nutriment_of(nutr, ["proteins_serving"]) or None
    carb = _nutriment_of(nutr, ["carbohydrates_serving"]) or None
    fat = _nutriment_of(nutr, ["fat_serving"]) or None
    portion = p.get("serving_size") or None
    extras = _extras_from_nutriments(nutr, "serving")
    out = {"kcal": kcal, "proteina": prot, "carbo": carb, "gordura": fat, **extras}

    if all(v is None for v in [kcal, prot, carb, fat]):
        grams = _parse_serving_size_to_grams(p.get("serving_size"))
        per100 = _normalize_off_100g(p).nutricao_por_100g
        if grams and per100:
            ratio = grams / 100.0
            out = {
                "kcal": round((per100.kcal or 0) * ratio) if per100.kcal is not None else None,
                "proteina": _round1((per100.proteina or 0) * ratio) if per100.proteina is not None else None,
                "carbo": _round1((per100.carbo or 0) * ratio) if per100.carbo is not None else None,
                "gordura": _round1((per100.gordura or 0) * ratio) if per100.gordura is not None else None,
                "acucar": _round1((per100.acucar or 0) * ratio) if per100.acucar is not None else None,
                "fibra": _round1((per100.fibra or 0) * ratio) if per100.fibra is not None else None,
                "sal_g": _round1((per100.sal_g or 0) * ratio) if per100.sal_g is not None else None,
                "sodio_mg": _round0((per100.sodio_mg or 0) * ratio) if per100.sodio_mg is not None else None,
            }
            if not portion:
                portion = f"{_round1(grams)} g"

    return {
        "porcao": portion or "1 porção",
        "nutricao_por_porcao": out,
    }


def _get_with_retry(url: str, params: Optional[dict] = None, headers: Optional[dict] = None, timeout: int = 15, retries: int = 3, backoff: float = 0.3):
    last = None
    for i in range(retries + 1):
        try:
            r = requests.get(url, params=params, headers=headers, timeout=timeout)
            if r.ok:
                return r
            last = Exception(f"HTTP {r.status_code}")
        except Exception as e:
            last = e
        if i < retries:
            time.sleep(backoff * (2 ** i))
    if last:
        raise last
    raise RuntimeError("request_failed")


def off_search(query: str, top_k: int = 10) -> List[dict]:
    url = f"{OFF_BASE_URL}/api/v2/search"
    params = {
        "page_size": str(top_k),
        "query": query,
        "fields": "code,product_name,product_name_pt,generic_name,generic_name_pt,brands,serving_size,nutriments",
    }
    cache_key = f"search:{query}:{top_k}"
    cached = _cache.get(cache_key)
    if cached is not None:
        return cached
    r = _get_with_retry(url, params=params, headers={"User-Agent": OFF_USER_AGENT}, timeout=15)
    j = r.json()
    products = [p for p in j.get("products", []) if p]
    _cache.set(cache_key, products)
    return products


def off_by_barcode(barcode: str) -> Optional[dict]:
    cache_key = f"barcode:{barcode}"
    cached = _cache.get(cache_key)
    if cached is not None:
        return cached
    url = f"{OFF_BASE_URL}/api/v2/product/{barcode}.json"
    r = _get_with_retry(url, headers={"User-Agent": OFF_USER_AGENT}, timeout=15)
    j = r.json()
    p = j.get("product")
    if p:
        _cache.set(cache_key, p)
    return p


@app.post("/calcular_metas", response_model=CalcularMetasOut)
def calcular_metas(payload: CalcularMetasIn):
    # BMR Mifflin-St Jeor
    if payload.sexo == "m":
        bmr = 10 * payload.peso_kg + 6.25 * payload.altura_cm - 5 * payload.idade + 5
    else:
        bmr = 10 * payload.peso_kg + 6.25 * payload.altura_cm - 5 * payload.idade - 161

    tdee = bmr * activity_multiplier(payload.nivel_atividade)

    ajuste = 0.0
    if payload.objetivo == "perda":
        # leve déficit (~15%)
        ajuste = -0.15
    elif payload.objetivo == "ganho":
        # leve superávit (~10%)
        ajuste = 0.10
    kcal_meta = tdee * (1 + ajuste)

    # macros simples: P=1.8 g/kg, G=0.8 g/kg, resto carb
    proteina_g = max(1.6, 1.8) * payload.peso_kg
    gordura_g = 0.8 * payload.peso_kg
    kcal_prot = proteina_g * 4
    kcal_gord = gordura_g * 9
    carbo_g = max(0.0, (kcal_meta - kcal_prot - kcal_gord) / 4)

    return CalcularMetasOut(
        bmr=round(bmr, 1),
        tdee=round(tdee, 1),
        kcal_meta=round(kcal_meta, 0),
        macros_g=Macros(
            proteina=round(proteina_g), carbo=round(carbo_g), gordura=round(gordura_g)
        ),
    )


@app.post("/planejar_jejum", response_model=PlanejarJejumOut)
def planejar_jejum(payload: PlanejarJejumIn):
    janela_map = {
        "12:12": (12, 12),
        "14:10": (14, 10),
        "16:8": (16, 8),
        "18:6": (18, 6),
        "20:4": (20, 4),
        "omad": (23, 1),
    }
    f_h, e_h = janela_map[payload.protocolo]

    now = datetime.now()
    if payload.inicio_preferido:
        hh, mm = payload.inicio_preferido.split(":")
        start = now.replace(hour=int(hh), minute=int(mm), second=0, microsecond=0)
        if start < now:
            start += timedelta(days=1)
    else:
        start = now.replace(second=0, microsecond=0)

    janelas: List[Janela] = []
    cur = start
    for _ in range(payload.dias):
        j_inicio = cur.isoformat()
        j_fim = (cur + timedelta(hours=f_h)).isoformat()
        janelas.append(Janela(inicio=j_inicio, fim=j_fim))
        cur = (cur + timedelta(days=1)).replace(hour=start.hour, minute=start.minute)

    lembretes = ["00:30 antes do início", "Início"]
    return PlanejarJejumOut(janelas=janelas, lembretes=lembretes)


@app.post("/buscar_alimento", response_model=BuscarAlimentoOut, dependencies=[Depends(enforce_default_limit)])
def buscar_alimento(payload: BuscarAlimentoIn):
    # Se fonte = OFF, consulta e normaliza; caso contrário, demo local com cache
    if (payload.fonte or "").lower() == "open_food_facts":
        try:
            products = off_search(payload.query, min(int(payload.top_k or 10), 50))
            itens: List[ItemAlimento] = []
            for p in products:
                try:
                    item = _normalize_off_100g(p)
                    if item.nutricao_por_100g and item.nutricao_por_100g.kcal is not None:
                        itens.append(item)
                except Exception:
                    continue
            return BuscarAlimentoOut(itens=itens)
        except Exception:
            # Fallback para demo
            pass

    cache_key = f"search:{payload.query}:{payload.top_k}"
    cached = _cache.get(cache_key)
    if cached is not None:
        return BuscarAlimentoOut(itens=cached)

    demo = [
        ItemAlimento(
            id="demo-frango-grelhado",
            nome="Frango grelhado",
            porcao_padrao="100 g",
            nutricao_por_100g=NutricaoPor100g(
                kcal=165, proteina=31, carbo=0, gordura=3.6, acucar=0.0, fibra=0.0, sal_g=0.1, sodio_mg=40
            ),
        ),
        ItemAlimento(
            id="demo-arroz-cozido",
            nome="Arroz branco cozido",
            porcao_padrao="100 g",
            nutricao_por_100g=NutricaoPor100g(
                kcal=130, proteina=2.4, carbo=28, gordura=0.3, acucar=0.1, fibra=0.2, sal_g=0.0, sodio_mg=1
            ),
        ),
    ]
    q = payload.query.lower()
    itens = [i for i in demo if q in i.nome.lower()][: int(payload.top_k or 10)]
    _cache.set(cache_key, itens)
    return BuscarAlimentoOut(itens=itens)


@app.post("/analisar_barcode", response_model=AnalisarBarcodeOut, dependencies=[Depends(enforce_default_limit)])
def analisar_barcode(payload: AnalisarBarcodeIn):
    # Usa OFF como fonte principal; fallback: demo
    try:
        p = off_by_barcode(payload.barcode)
        if p:
            base = _normalize_off_100g(p)
            serving = _normalize_off_serving(p)
            item = ItemNormalizado(
                id=base.id,
                nome=base.nome,
                nutricao_por_porcao=NutricaoPorPorcao(**serving["nutricao_por_porcao"]),
            )
            return AnalisarBarcodeOut(item=item)
    except Exception:
        pass

    # Fallback demo (cacheado)
    cache_key = f"barcode:{payload.barcode}"
    cached = _cache.get(cache_key)
    if cached is not None:
        return AnalisarBarcodeOut(item=cached)
    item = ItemNormalizado(
        id=f"barcode:{payload.barcode}",
        nome="Produto genérico",
        nutricao_por_porcao=NutricaoPorPorcao(kcal=200, proteina=5, carbo=30, gordura=7, acucar=8.0, fibra=2.5, sal_g=0.6, sodio_mg=240),
    )
    _cache.set(cache_key, item)
    return AnalisarBarcodeOut(item=item)


@app.post("/analisar_foto", response_model=AnalisarFotoOut, dependencies=[Depends(enforce_photo_limit)])
def analisar_foto(payload: AnalisarFotoIn):
    system = (
        "Você é um assistente de nutrição. A partir da imagem de uma refeição, "
        "identifique até 3 candidatos de alimentos presentes. Para cada candidato, "
        "retorne nome comum em pt-BR, uma estimativa simples de porção (ex.: '120 g', '1 xícara'), "
        "e uma confiança entre 0 e 1. Responda somente no JSON solicitado."
    )
    json_instruction = (
        'Responda somente como JSON com a forma: { "candidatos": [ { "nome": string, "porcao": string, "confianca": number } ] }.'
    )

    if not payload.image_base64 and not payload.image_url:
        # Fallback básico se não houver imagem
        return AnalisarFotoOut(
            candidatos=[
                CandidatoFoto(nome="frango grelhado", porcao="120 g", confianca=0.6),
                CandidatoFoto(nome="arroz branco", porcao="150 g", confianca=0.55),
            ]
        )

    try:
        if VISION_PROVIDER == "openai" and OPENAI_API_KEY and OpenAIClient:
            client = OpenAIClient(api_key=OPENAI_API_KEY)
            img_url = (
                f"data:image/jpeg;base64,{payload.image_base64}" if payload.image_base64 else payload.image_url
            )
            resp = client.chat.completions.create(
                model=OPENAI_VISION_MODEL,
                response_format={"type": "json_object"},
                temperature=0.2,
                messages=[
                    {"role": "system", "content": system},
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": json_instruction},
                            {"type": "image_url", "image_url": {"url": img_url}},
                        ],
                    },
                ],
            )
            raw = (resp.choices[0].message.content or "{}").strip()
            data = json.loads(raw)
            cands = [
                CandidatoFoto(nome=c.get("nome"), porcao=c.get("porcao"), confianca=c.get("confianca"))
                for c in (data.get("candidatos") or [])
            ]
            return AnalisarFotoOut(candidatos=cands[:3])

        if VISION_PROVIDER == "gemini" and GEMINI_API_KEY and genai:
            genai.configure(api_key=GEMINI_API_KEY)
            model = genai.GenerativeModel(
                model_name=GEMINI_VISION_MODEL,
                generation_config={"response_mime_type": "application/json"},
            )
            mime = "image/jpeg"
            img_bytes = None
            if payload.image_base64:
                try:
                    img_bytes = base64.b64decode(payload.image_base64)
                except Exception:
                    img_bytes = None
            elif payload.image_url:
                cache_key = f"img:{payload.image_url}"
                cached = _image_cache.get(cache_key)
                if cached is not None:
                    img_bytes = cached.get("data")
                    mime = cached.get("mime", mime)
                else:
                    r = requests.get(payload.image_url, timeout=20)
                    if r.ok:
                        img_bytes = r.content
                        ct = r.headers.get("content-type", "")
                        if ct:
                            mime = ct.split(";")[0]
                        _image_cache.set(cache_key, {"data": img_bytes, "mime": mime})
            if not img_bytes:
                raise RuntimeError("missing_image_bytes")

            prompt = f"{system}\n\n{json_instruction}"
            result = model.generate_content(
                contents=[
                    {
                        "role": "user",
                        "parts": [
                            {"text": prompt},
                            {"inline_data": {"mime_type": mime, "data": img_bytes}},
                        ],
                    }
                ]
            )
            text = getattr(result, "text", None) or getattr(result, "candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "{}")
            data = json.loads(text)
            cands = [
                CandidatoFoto(nome=c.get("nome"), porcao=c.get("porcao"), confianca=c.get("confianca"))
                for c in (data.get("candidatos") or [])
            ]
            return AnalisarFotoOut(candidatos=cands[:3])
    except Exception:
        pass

    # Fallback em caso de erro ou provider não configurado
    return AnalisarFotoOut(
        candidatos=[
            CandidatoFoto(nome="frango grelhado", porcao="120 g", confianca=0.6),
            CandidatoFoto(nome="arroz branco", porcao="150 g", confianca=0.55),
        ]
    )


@app.post("/log_refeicao", response_model=LogRefeicaoOut)
def log_refeicao(payload: LogRefeicaoIn):
    # TODO: calcular com base em itens normalizados no banco
    # Aqui: cálculo fictício por unidade comum
    kcal_total = 0.0
    for it in payload.itens:
        # supõe 100 kcal por unidade como fallback
        kcal_total += it.quantidade * 100 if it.unidade not in ("g", "ml") else (it.quantidade * 1.0)

    return LogRefeicaoOut(
        total=Totais(kcal=round(kcal_total, 1), proteina=0, carbo=0, gordura=0),
        itens=[it.dict() for it in payload.itens],
    )


@app.post("/sugerir_refeicao", response_model=SugerirRefeicaoOut)
def sugerir_refeicao(payload: SugerirRefeicaoIn):
    # TODO: integrar motor de receitas e preferências
    base = [
        Sugestao(
            nome="Bowl frango + arroz + salada",
            kcal=550,
            macros_g={"proteina": 40, "carbo": 60, "gordura": 15},
            passos=["Grelhar frango", "Cozinhar arroz", "Montar bowl"],
        ),
        Sugestao(
            nome="Omelete de claras + aveia",
            kcal=430,
            macros_g={"proteina": 35, "carbo": 40, "gordura": 12},
            passos=["Bater claras", "Refogar", "Servir com aveia e fruta"],
        ),
        Sugestao(
            nome="Iogurte grego + frutas + granola",
            kcal=380,
            macros_g={"proteina": 25, "carbo": 45, "gordura": 10},
            passos=["Montar pote", "Adicionar frutas e granola"],
        ),
    ]
    return SugerirRefeicaoOut(sugestoes=base[:3])


@app.post("/registrar_checkin", response_model=OkOut)
def registrar_checkin(payload: RegistrarCheckinIn):
    # TODO: persistir no banco
    return OkOut(ok=True)


@app.post("/obter_estatisticas_usuario", response_model=ObterEstatisticasOut)
def obter_estatisticas_usuario():
    # TODO: calcular a partir do histórico
    resumo = {
        "semana": {
            "dias_com_log": 4,
            "janelas_concluidas": 3,
            "peso_atual": 72.3,
        },
        "hoje": {
            "kcal_restantes": 820,
            "macros_restantes": {"proteina": 60, "carbo": 110, "gordura": 25},
        },
    }
    return ObterEstatisticasOut(resumo=resumo)


@app.post("/atualizar_preferencias", response_model=OkOut)
def atualizar_preferencias(payload: AtualizarPreferenciasIn):
    # TODO: persistir preferências
    return OkOut(ok=True)


# Execução: `uvicorn main:app --reload --port 8001`
