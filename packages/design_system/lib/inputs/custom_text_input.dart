import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class CustomTextInput extends StatelessWidget {
  const CustomTextInput({
    this.controller,
    super.key,
    this.error,
    this.multiline = false,
    this.textInputType,
    this.height,
    this.textAlign,
    this.onPressed,
    this.disabled = false,
    this.isObscured = false,
    this.expands = false,
    this.onToggleObscureText,
    this.onChanged,
    this.value,
    this.prefixIcon,
    this.label,
    this.floatingLabelBehavior,
    this.suffix,
    this.focusNode,
    this.borderColor,
    this.styleBuilder,
    this.prefix,
    this.maxLength,
    this.inputFormatters,
    this.overrideController = true,
  });

  final TextEditingController? controller;
  final VoidCallback? onPressed, onToggleObscureText;
  final bool multiline, disabled, isObscured, expands, overrideController;
  final TextAlign? textAlign;
  final TextInputType? textInputType;
  final double? height;
  final String? error, value, label;
  final Function(String? text)? onChanged;
  final Color? borderColor;
  final CustomIconData? prefixIcon;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final Widget? prefix, suffix;
  final int? maxLength;
  final FocusNode? focusNode;
  final Function(CustomTextStyles style)? styleBuilder;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    final style = CustomTextStyles.of(context);
    final borderData = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: error != null ? theme.negative300 : borderColor ?? theme.black50),
    );
    const boxConstraints = BoxConstraints(maxHeight: 100, maxWidth: 100);
    const iconPadding = EdgeInsets.only(left: 12, right: 12);
    return SizedBox(
      height: expands ? null : height ?? (error != null ? 85 : 56),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              focusNode: focusNode,
              obscureText: isObscured,
              controller: controller,
              initialValue: overrideController ? null : value,
              maxLength: maxLength,
              maxLines: expands ? null : (multiline ? 5 : 1),
              style: _getStyle(style: style),
              inputFormatters: [
                if (textInputType == TextInputType.number) FilteringTextInputFormatter.digitsOnly,
                if (textInputType == TextInputType.phone) MaskedInputFormatter('000 000 0000'),
                if (inputFormatters != null) ...inputFormatters!,
              ],
              keyboardType: textInputType,
              textCapitalization:
                  textInputType == TextInputType.name ? TextCapitalization.words : TextCapitalization.none,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              decoration: InputDecoration(
                filled: true,
                prefixIconConstraints: boxConstraints,
                suffixIconConstraints: boxConstraints,
                suffixIcon: suffix == null ? null : Padding(padding: iconPadding, child: suffix),
                prefixIcon: prefixIcon == null
                    ? prefix == null
                        ? null
                        : Padding(padding: iconPadding, child: prefix)
                    : Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: CustomIcon(
                          data: prefixIcon!,
                          size: const Size(24, 24),
                          color: error == null ? null : Colors.red,
                        ),
                      ),
                border: borderData,
                disabledBorder: borderData,
                enabledBorder: borderData,
                focusedErrorBorder: borderData,
                alignLabelWithHint: true,
                labelText: label,
                labelStyle: _getStyle(style: style, fontWeight: FontWeight.w400),
                floatingLabelBehavior: floatingLabelBehavior ?? FloatingLabelBehavior.auto,
                errorText: error,
                focusColor: theme.white80,
                errorBorder: borderData,
                focusedBorder: borderData,
                fillColor: theme.white80,
                isCollapsed: false,
                isDense: true,
              ),
              enabled: !disabled,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _getStyle({required CustomTextStyles style, FontWeight? fontWeight}) {
    return styleBuilder == null
        ? style.f18W500.value.copyWith(
            fontWeight: fontWeight,
            color: error == null ? null : Colors.red,
          )
        : styleBuilder!(style).value.copyWith(
              fontWeight: fontWeight,
              color: error == null ? null : Colors.red,
            );
  }
}

class PercentageFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Remove any "%" symbol from the new value
    var newText = newValue.text.replaceAll('%', '');

    // Append "%" if there's a valid number entered
    if (newText.isNotEmpty && int.tryParse(newText) != null && int.parse(newText) <= 100) {
      newText = '$newText%';
    } else if (newText.isEmpty) {
      newText = '';
    } else {
      newText = oldValue.text;
    }

    final hasPercent = newText.contains('%');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: hasPercent ? newText.length - 1 : newText.length),
    );
  }
}
