import 'package:dio/dio.dart';

/// Erreur HTTP normalisée pour l'interface.
class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final payload = _readErrorPayload(response?.data);
    return ApiException(
      message: payload?.message ?? _fallbackMessage(error),
      statusCode: response?.statusCode,
      code: payload?.code,
    );
  }

  @override
  String toString() => message;
}

class _ErrorPayload {
  const _ErrorPayload({required this.message, this.code});

  final String message;
  final String? code;
}

_ErrorPayload? _readErrorPayload(Object? data) {
  if (data is! Map) {
    return null;
  }
  final error = data['error'];
  if (error is! Map) {
    return null;
  }
  final message = error['message'];
  if (message is! String || message.trim().isEmpty) {
    return null;
  }
  final code = error['code'];
  return _ErrorPayload(
    message: message.trim(),
    code: code is String ? code : null,
  );
}

String _fallbackMessage(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Le serveur met trop de temps à répondre.';
    case DioExceptionType.connectionError:
      return 'Connexion au serveur impossible.';
    case DioExceptionType.cancel:
      return 'La requête a été annulée.';
    case DioExceptionType.badCertificate:
      return 'Le certificat du serveur n’est pas fiable.';
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      if (code != null) {
        return 'Le serveur a répondu avec le code $code.';
      }
      return 'La réponse du serveur est invalide.';
    case DioExceptionType.unknown:
    case DioExceptionType.transformTimeout:
      return 'Une erreur réseau inattendue s’est produite.';
  }
}
