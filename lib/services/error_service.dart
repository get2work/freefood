import 'package:flutter/material.dart';

class ErrorService {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }

  static Future<T> handleFuture<T>({
    required Future<T> future,
    required BuildContext context,
    String? loadingMessage,
    String? errorMessage,
  }) async {
    try {
      if (loadingMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loadingMessage),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      return await future;
    } catch (e) {
      showError(context, errorMessage ?? getErrorMessage(e));
      rethrow;
    }
  }
} 