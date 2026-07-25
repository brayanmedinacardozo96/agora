import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formatter personalizado que permite paste de múltiples caracteres
class _OtpTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si el texto nuevo tiene más de 1 carácter, es un paste - permitirlo
    if (newValue.text.length > 1) {
      return newValue;
    }

    // Para entrada normal de teclado, permitir solo 1 carácter
    if (newValue.text.length <= 1) {
      return newValue;
    }

    return oldValue;
  }
}

/// Widget reutilizable para campos de entrada OTP
///
/// Características:
/// - Soporta copiar y pegar código completo
/// - Navegación automática entre campos
/// - Validación en tiempo real
/// - Totalmente personalizable
///
/// Ejemplo de uso:
/// ```dart
/// OtpInputField(
///   length: 6,
///   onCompleted: (code) {
///     print('Código completo: $code');
///   },
/// )
/// ```
class OtpInputField extends StatefulWidget {
  /// Número de dígitos del código OTP
  final int length;

  /// Callback ejecutado cuando se completan todos los dígitos
  final Function(String) onCompleted;

  /// Callback opcional ejecutado en cada cambio
  final Function(String)? onChanged;

  /// Ancho de cada campo
  final double fieldWidth;

  /// Alto de cada campo
  final double fieldHeight;

  /// Espacio entre campos
  final double spacing;

  /// Color de fondo de los campos
  final Color? backgroundColor;

  /// Color del borde cuando está inactivo
  final Color? borderColor;

  /// Color del borde cuando está activo (con texto)
  final Color? activeBorderColor;

  /// Color del texto
  final Color? textColor;

  /// Radio de las esquinas
  final double borderRadius;

  /// Ancho del borde
  final double borderWidth;

  const OtpInputField({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.fieldWidth = 56,
    this.fieldHeight = 64,
    this.spacing = 8,
    this.backgroundColor,
    this.borderColor,
    this.activeBorderColor,
    this.textColor,
    this.borderRadius = 12,
    this.borderWidth = 2,
  });

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
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

  /// Obtiene el código completo concatenando todos los campos
  String get currentCode {
    return _controllers.map((controller) => controller.text).join();
  }

  /// Verifica si el código está completo
  bool get isComplete {
    return currentCode.length == widget.length;
  }

  void _notifyChanges() {
    final code = currentCode;
    widget.onChanged?.call(code);

    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  void _handlePaste(int currentIndex, String pastedText) {
    // Limpiar el texto pegado (solo números)
    final cleanText = pastedText.replaceAll(RegExp(r'\D'), '');

    if (cleanText.isEmpty) return;

    // Limpiar el campo actual primero
    _controllers[currentIndex].clear();

    // Distribuir los dígitos en los campos desde el índice actual
    int targetIndex = currentIndex;
    for (
      int i = 0;
      i < cleanText.length && targetIndex < widget.length;
      i++, targetIndex++
    ) {
      _controllers[targetIndex].text = cleanText[i];
    }

    // Mover el foco al último campo llenado o al siguiente vacío
    final lastFilledIndex = currentIndex + cleanText.length;

    if (lastFilledIndex < widget.length) {
      _focusNodes[lastFilledIndex].requestFocus();
    } else {
      _focusNodes[widget.length - 1].unfocus();
    }

    setState(() {});
  }

  /// Limpia todos los campos y devuelve el foco al primero
  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
    setState(() {});
  }

  /// Establece el código en los campos
  void setCode(String code) {
    final cleanCode = code.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < widget.length && i < cleanCode.length; i++) {
      _controllers[i].text = cleanCode[i];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular el espacio total ocupado por los márgenes y bordes
        // Cada campo tiene margin horizontal de spacing/2 en ambos lados
        // Cada campo también tiene borde que ocupa espacio adicional
        final totalSpacing = widget.spacing * widget.length;
        final totalBorderWidth = widget.borderWidth * 2 * widget.length;
        final availableWidth =
            constraints.maxWidth - totalSpacing - totalBorderWidth;
        final calculatedFieldWidth = availableWidth / widget.length;

        // Usar el menor valor entre el ancho especificado y el calculado
        // Asegurar que sea al menos 40 para mantener usabilidad
        final effectiveFieldWidth = calculatedFieldWidth < widget.fieldWidth
            ? calculatedFieldWidth.clamp(40.0, widget.fieldWidth)
            : widget.fieldWidth;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: _buildOtpField(index, theme, effectiveFieldWidth),
            );
          }),
        );
      },
    );
  }

  Widget _buildOtpField(int index, ThemeData theme, double fieldWidth) {
    final hasText = _controllers[index].text.isNotEmpty;

    return Container(
      width: fieldWidth,
      height: widget.fieldHeight,
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            (theme.brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : Colors.grey[100]),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: hasText
              ? (widget.activeBorderColor ?? theme.primaryColor)
              : (widget.borderColor ??
                    (theme.brightness == Brightness.dark
                        ? const Color(0xFF334155)
                        : Colors.grey[300]!)),
          width: widget.borderWidth,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        style: TextStyle(
          color:
              widget.textColor ??
              (theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
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
          if (value.isNotEmpty) {
            // Si pegó múltiples caracteres, manejar el pegado
            if (value.length > 1) {
              _handlePaste(index, value);
              return;
            }

            setState(() {});

            // Mover al siguiente campo si no es el último
            if (index < widget.length - 1) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Si es el último campo, quitar el foco
              _focusNodes[index].unfocus();
            }
          } else {
            setState(() {});
            // Si borró el contenido, mover al campo anterior
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _OtpTextInputFormatter(),
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
