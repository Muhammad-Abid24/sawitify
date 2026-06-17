import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // 🔐 Unauthorized
      if (kDebugMode) {
        print("Unauthorized! Redirect to login");
      }
    }

    if (err.response?.statusCode == 500) {
      if (kDebugMode) {
        print("Server error");
      }
    }

    handler.next(err);
  }
}