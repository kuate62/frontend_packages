import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Transforme les erreurs Dio en [ApiException].
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final wrapped = err.error;
    if (wrapped is ApiException) {
      handler.next(err);
      return;
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiException.fromDio(err),
        stackTrace: err.stackTrace,
        message: err.message,
      ),
    );
  }
}
