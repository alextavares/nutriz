#!/usr/bin/env bash
set -euo pipefail
SCREEN="${1:-home}"; OUT_DIR="docs/compare"; SRC_DIR="pr_captures/${SCREEN}"
mkdir -p "$OUT_DIR"

gen_screen() {
  local s="$1"
  local out="${OUT_DIR}/${s}.html"
  cat > "$out" <<HTML
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"/>
<title>Comparação — ${s}</title>
<style>
body{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;background:#111;color:#eee;margin:0;padding:20px}
.grid{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:28px}
.card{background:#1b1b1b;border-radius:10px;padding:12px}
.title{margin:0 0 8px 0;font-weight:600}
img{width:100%;height:auto;border-radius:8px;background:#000}
.meta{color:#aaa;font-size:12px;margin-top:6px}
.split{display:grid;grid-template-columns:1fr;gap:16px;margin-top:8px}
.slider-wrap{position:relative;background:#000;border-radius:8px;overflow:hidden}
.slider-wrap img{display:block;width:100%;height:auto}
.slider-wrap .overlay{position:absolute;inset:0;clip-path:inset(0 calc(100% - var(--split, 50%)) 0 0)}
.slider-ctrl{display:flex;align-items:center;gap:8px;margin-top:8px}
.slider-ctrl input[type=range]{width:100%}
.small{color:#aaa;font-size:12px}
</style></head><body>
<h1>${s^}: YAZIO (ref) vs NutriTracker</h1>
<div class="grid">
  <div class="card"><p class="title">YAZIO — Dark</p><img src="../../${SRC_DIR}/yazio_${s}_dark.png"/><div class="meta">${SRC_DIR}/yazio_${s}_dark.png</div></div>
  <div class="card"><p class="title">NutriTracker — Dark</p><img src="../../${SRC_DIR}/nutri_${s}_dark.png"/><div class="meta">${SRC_DIR}/nutri_${s}_dark.png</div></div>
  <div class="card"><p class="title">YAZIO — Light</p><img src="../../${SRC_DIR}/yazio_${s}_light.png"/><div class="meta">${SRC_DIR}/yazio_${s}_light.png</div></div>
  <div class="card"><p class="title">NutriTracker — Light</p><img src="../../${SRC_DIR}/nutri_${s}_light.png"/><div class="meta">${SRC_DIR}/nutri_${s}_light.png</div></div>
</div></body></html>
<h2>Comparador interativo</h2>
<div class="split">
  <div class="card">
    <p class="title">Dark — slider (YAZIO ←→ Nutri)</p>
    <div class="slider-wrap" id="wrap-dark" style="--split:50%">
      <img src="../../${SRC_DIR}/yazio_${s}_dark.png" alt="YAZIO dark">
      <img class="overlay" src="../../${SRC_DIR}/nutri_${s}_dark.png" alt="Nutri dark">
    </div>
    <div class="slider-ctrl"><span class="small">YAZIO</span>
      <input type="range" id="range-dark" min="0" max="100" value="50">
      <span class="small">Nutri</span></div>
  </div>
  <div class="card">
    <p class="title">Light — slider (YAZIO ←→ Nutri)</p>
    <div class="slider-wrap" id="wrap-light" style="--split:50%">
      <img src="../../${SRC_DIR}/yazio_${s}_light.png" alt="YAZIO light">
      <img class="overlay" src="../../${SRC_DIR}/nutri_${s}_light.png" alt="Nutri light">
    </div>
    <div class="slider-ctrl"><span class="small">YAZIO</span>
      <input type="range" id="range-light" min="0" max="100" value="50">
      <span class="small">Nutri</span></div>
  </div>
</div>
<script>
  function bindSlider(rangeId, wrapId){
    const r = document.getElementById(rangeId);
    const w = document.getElementById(wrapId);
    if(!r||!w) return;
    const set = v => w.style.setProperty('--split', v+'%');
    r.addEventListener('input', e => set(e.target.value));
    set(r.value);
  }
  bindSlider('range-dark','wrap-dark');
  bindSlider('range-light','wrap-light');
</script>
</body></html>
HTML
  echo "$out"
}

gen_index() {
  cat > "${OUT_DIR}/index.html" <<HTML
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"/>
<title>Comparações — Índice</title>
<style>
body{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;margin:16px}
.legend{color:#555;margin:6px 0 16px}
ul{line-height:1.9}
</style></head>
<body>
<h1>Comparações — YAZIO vs NutriTracker</h1>
<div class="legend">Ordem das imagens: YAZIO à esquerda • NutriTracker à direita (dark em cima, light embaixo).</div>
<ul>
<li><a href="./home.html">Home / Diário</a></li>
<li><a href="./search.html">Busca / Logging</a></li>
<li><a href="./progress.html">Progresso / Analytics</a></li>
<li><a href="./profile.html">Perfil / Metas</a></li>
</ul>
</body></html>
HTML
}

# Generate current screen and placeholders for others if missing
gen_screen "$SCREEN" >/dev/null
for s in search progress profile; do
  [[ -f "${OUT_DIR}/${s}.html" ]] || gen_screen "$s" >/dev/null
done

gen_index
