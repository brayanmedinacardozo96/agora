import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final double fieldWidth;
  final double fieldHeight;
  final double spacing;

  const OtpInputField({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.fieldWidth = 56,
    this.fieldHeight = 64,
    this.spacing = 8,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());

    // Agregar listeners para detectar cambios
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].addListener(() {
        _notifyChanges();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _currentCode {
    return _controllers.map((controller) => controller.text).join();
  }

  void _notifyChanges() {
    final code = _currentCode;
    widget.onChanged?.call(code);

    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  void _handlePaste(String pastedText) {
    // Limpiar el texto pegado (solo números)
    final cleanText = pastedText.replaceAll(RegExp(r'\D'), '');

    if (cleanText.isEmpty) return;

    // Distribuir los dígitos en los campos
    for (int i = 0; i < widget.length && i < cleanText.length; i++) {
      _controllers[i].text = cleanText[i];
    }

    // Mover el foco al último campo llenado o al siguiente vacío
    final lastFilledIndex = cleanText.length < widget.length
        ? cleanText.length
        : widget.length - 1;

    if (lastFilledIndex < widget.length) {
      _focusNodes[lastFilledIndex].requestFocus();
    } else {
      _focusNodes[widget.length - 1].unfocus();
    }

    setState(() {});
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: _buildOtpField(index),
        );
      }),
    );
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: widget.fieldWidth,
      height: widget.fieldHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? Colors.blue[400]!
              : const Color(0xFF334155),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        autofocus: index == 0,
        onTap: () {
          // Si hay texto, seleccionarlo para facilitar el reemplazo
          if (_controllers[index].text.isNotEmpty) {
            _controllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[index].text.length,
            );
          }
        },
        onChanged: (value) {
          setState(() {});

          if (value.isNotEmpty) {
            // Si pegó múltiples caracteres, manejar el pegado
            if (value.length > 1) {
              _handlePaste(value);
              return;
            }

            // Mover al siguiente campo si no es el último
            if (index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Si es el último campo, quitar el foco
              _focusNodes[index].unfocus();
            }
          } else {
            // Si borró el contenido, mover al campo anterior
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
