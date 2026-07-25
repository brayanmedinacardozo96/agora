import 'package:flutter/material.dart';

class CustomAlert {
  static void top({
    required BuildContext ctx,
    required String message,
    SnackBarBehavior? behavior,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: behavior ?? SnackBarBehavior.floating,
        duration: duration,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void error({required BuildContext ctx, required String message}) {
    top(ctx: ctx, message: message, behavior: SnackBarBehavior.floating);
  }

  static void success({required BuildContext ctx, required String message}) {
    top(ctx: ctx, message: message, behavior: SnackBarBehavior.floating);
  }
}
