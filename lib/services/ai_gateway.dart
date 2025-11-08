// AiGateway: ponto único para integrar diferentes provedores de IA
// (OpenAI, Gemini, backend próprio de coach, visão computacional, etc.).
// Nesta fase é um wrapper fino em cima do CoachApiService existente,
// sem alterar comportamento atual das telas.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'coach_api_service.dart' as coach;

/// Representa uma resposta genérica do coach de IA usada pelas camadas de UI.
class CoachReply {
  final String reply;
  final List<Map<String, dynamic>> toolEvents;

  const CoachReply({
    required this.reply,
    this.toolEvents = const [],
  });

  factory CoachReply.fromCoach(coach.CoachReply src) => CoachReply(
        reply: src.reply,
        toolEvents: src.toolEvents,
      );
}

/// Contrato de mensagem para histórico/contexto do coach.
/// Wrapper fino sobre [coach.CoachMessage] para permitir evolução futura
/// sem forçar telas a conhecerem a implementação concreta.
class CoachMessage {
  final String role; // 'user' | 'assistant'
  final String content;

  const CoachMessage(this.role, this.content);

  coach.CoachMessage toCoach() => coach.CoachMessage(role, content);
}

/// Ponto de entrada único para chamadas de IA do app.
///
/// Objetivos:
/// - Encapsular detalhes do backend atual (CoachApiService);
/// - Facilitar troca de provedor (OpenAI, Gemini, backend próprio, etc.);
/// - Permitir logging, métricas e fallbacks centralizados.
///
/// Nesta fase:
/// - Usa diretamente `coach.CoachApiService.instance` por baixo.
/// - Não altera a semântica das chamadas existentes; opt-in pelas telas.
class AiGateway {
  AiGateway._internal();

  static final AiGateway instance = AiGateway._internal();

  /// Envia uma mensagem para o coach de IA usando o backend atual.
  Future<CoachReply> sendCoachMessage({
    required String message,
    required List<CoachMessage> history,
    required Map<String, dynamic> context,
  }) async {
    final coachHistory = history.map((m) => m.toCoach()).toList();
    final reply = await coach.CoachApiService.instance.sendMessage(
      message: message,
      history: coachHistory,
      context: context,
    );
    return CoachReply.fromCoach(reply);
  }

  /// Analisa foto de alimento usando o backend atual do CoachApiService.
  /// Mantém compatibilidade com a API existente (`analyzePhoto`) mas expõe
  /// via gateway para facilitar troca futura (ex.: outro modelo/fornecedor).
  Future<List<Map<String, dynamic>>> analyzePhoto({
    String? imageBase64,
    String? imageUrl,
  }) async {
    final list = await coach.CoachApiService.instance.analyzePhoto(
      imageBase64: imageBase64,
      imageUrl: imageUrl,
    );
    // Garante saída tipada consistente.
    return list
        .map<Map<String, dynamic>>(
          (e) => (e as Map).map(
            (k, v) => MapEntry(k.toString(), v),
          ),
        )
        .toList();
  }
}