# Integração Flutter — Chamada das Ferramentas (HTTP)

Exemplos básicos usando `http` para chamar o backend Express/FastAPI.

## Dependência
```yaml
dependencies:
  http: ^1.2.0
```

## Serviço simples (Dart)
Crie `lib/services/ai_coach_api.dart` (ou adapte ao seu padrão):

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiCoachApi {
  final String baseUrl; // ex.: http://localhost:8002
  AiCoachApi(this.baseUrl);

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/$path'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Erro ${resp.statusCode}: ${resp.body}');
  }

  Future<Map<String, dynamic>> calcularMetas({
    required String sexo,
    required num idade,
    required num pesoKg,
    required num alturaCm,
    required String nivelAtividade,
    required String objetivo,
  }) {
    return _post('calcular_metas', {
      'sexo': sexo,
      'idade': idade,
      'peso_kg': pesoKg,
      'altura_cm': alturaCm,
      'nivel_atividade': nivelAtividade,
      'objetivo': objetivo,
    });
  }

  Future<Map<String, dynamic>> planejarJejum({
    required String protocolo,
    String? inicioPreferido,
    int dias = 7,
  }) {
    return _post('planejar_jejum', {
      'protocolo': protocolo,
      if (inicioPreferido != null) 'inicio_preferido': inicioPreferido,
      'dias': dias,
    });
  }

  Future<Map<String, dynamic>> logRefeicao({
    required String refeicaoTipo,
    required List<Map<String, dynamic>> itens,
    String? origem,
    String? hora,
  }) {
    return _post('log_refeicao', {
      'refeicao_tipo': refeicaoTipo,
      'itens': itens,
      if (origem != null) 'origem': origem,
      if (hora != null) 'hora': hora,
    });
  }

  Future<Map<String, dynamic>> obterEstatisticasUsuario() {
    return _post('obter_estatisticas_usuario', {});
  }
}
```

## Uso no app
```dart
final api = AiCoachApi('http://10.0.2.2:8002'); // Android emulador → 10.0.2.2

final metas = await api.calcularMetas(
  sexo: 'm', idade: 32, pesoKg: 78, alturaCm: 178,
  nivelAtividade: 'moderado', objetivo: 'perda',
);

final jejum = await api.planejarJejum(protocolo: '16:8', inicioPreferido: '20:00');

final log = await api.logRefeicao(
  refeicaoTipo: 'jantar',
  itens: [
    { 'nome': 'Frango grelhado', 'quantidade': 150, 'unidade': 'g' },
    { 'nome': 'Arroz branco', 'quantidade': 120, 'unidade': 'g' },
  ],
  origem: 'texto',
);

final stats = await api.obterEstatisticasUsuario();
```

Notas
- Em produção, proteja as rotas (auth) e mova a lógica do coach para o backend.
- Ajuste para Dio/Chopper se já usa no projeto.
- Para foto/voz/barcode, suba endpoints com upload/multipart e integre provedores (Gemini/GPT‑4o ou modelo próprio).

