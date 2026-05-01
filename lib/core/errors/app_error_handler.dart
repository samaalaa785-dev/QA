import 'package:flutter/material.dart';

class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class AppErrorHandler {
  static Future<T?> guard<T>(
    BuildContext context,
    Future<T> Function() action, {
    String fallbackMessage = 'Something went wrong.',
  }) async {
    try {
      return await action();
    } on AppException catch (error) {
      if (context.mounted) showMessage(context, error.message);
      return null;
    } catch (_) {
      if (context.mounted) showMessage(context, fallbackMessage);
      return null;
    }
  }

  static void showMessage(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }
}
