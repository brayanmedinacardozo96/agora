import 'package:flutter/material.dart';
import 'package:uicomponents/uicomponents.dart';

class PasswordFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? Function(String?)? customValidator;

  const PasswordFieldWidget({
    super.key,
    required this.controller,
    this.labelText,
    this.customValidator,
  });

  @override
  Widget build(BuildContext context) {
    return FildPassword(
      containerColor: const Color(0xFF1E293B),
      labelText: labelText ?? "Password",
      validation: customValidator ?? UtlValidation(context).requiered,
      controller: controller,
      textColor: Colors.white,
    );
  }
}
