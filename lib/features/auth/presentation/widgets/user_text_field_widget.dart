import 'package:flutter/material.dart';
import 'package:uicomponents/uicomponents.dart';

class UserTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const UserTextFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return UIFieldText(
      label: "Email",
      suffixIcon: const Icon(Icons.account_circle, size: 20),
      controller: controller,
      maxLength: 100,
      keyboardType: TextInputType.emailAddress,
      validation: UtlValidation(context).validateEmail,
    );
  }
}
