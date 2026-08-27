import 'package:design_system/indicators/sw_loading_spinner.dart';
import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:design_system/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    this.baseButtonTheme,
    this.onPressed,
    this.isLoading = false,
    this.styleBuilder,
    this.showBorder = false,
    this.padding,
    this.backgroundColor,
    this.height,
    this.width,
    super.key,
    this.border,
    this.trailingIconData,
    this.textColor,
    this.leadingIconData,
    this.leading,
    this.trailing,
  });

  final BaseButtonTheme? baseButtonTheme;
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final CustomTextStyle Function(CustomTextStyles)? styleBuilder;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor, textColor;
  final BoxBorder? border;
  final bool showBorder;
  final double? height;
  final double? width;
  final CustomIconData? trailingIconData, leadingIconData;
  final Widget? leading, trailing;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    final borderRadius = BorderRadius.circular(16);
    return SizedBox(
      height: height,
      width: width,
      child: PressableWidget(
        onPressed: isLoading ? null : onPressed,
        disabledColor: baseButtonTheme?.disabledBackgroundColor,
        backgroundColor: baseButtonTheme?.backgroundColor ?? backgroundColor,
        borderRadius: borderRadius,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: border ??
                (baseButtonTheme?.borderColor != null ? Border.all(color: baseButtonTheme!.borderColor!) : null),
            borderRadius: borderRadius,
            color: baseButtonTheme?.backgroundColor ?? backgroundColor,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIconData != null && !isLoading) ...[
                CustomIcon(data: leadingIconData!, size: const Size(24, 24)),
                const Spacer(),
              ],
              if (leading != null && !isLoading && leadingIconData == null) ...[
                leading!,
                const Spacer(),
              ],
              isLoading
                  ? const SwLoadingSpinner(size: 24, strokeWidth: 2)
                  : CustomText(
                      text,
                      style: styleBuilder == null ? baseButtonTheme?.textButtonStyle : null,
                      styleBuilder: styleBuilder ??
                          (baseButtonTheme?.textButtonStyle != null ? null : (styles) => styles.f18W500),
                      color: baseButtonTheme?.textColor ?? textColor ?? theme.primaryWhite,
                      textAlign: TextAlign.center,
                    ),
              if (trailingIconData != null && !isLoading) CustomIcon(data: trailingIconData!, size: const Size(24, 24)),
              if (trailing != null && !isLoading && trailingIconData == null) ...[
                trailing!,
                const Spacer(),
              ],
              if ((leading != null || leadingIconData != null) && !isLoading) ...[
                const SizedBox(width: 24),
                const Spacer(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BaseButtonTheme {
  const BaseButtonTheme._({
    required this.backgroundColor,
    required this.pressedColor,
    required this.disabledBackgroundColor,
    required this.textColor,
    this.borderColor,
    this.textButtonStyle,
  });

  factory BaseButtonTheme.primary(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    return BaseButtonTheme._(
      backgroundColor: theme.primaryBlack,
      pressedColor: theme.primaryBlack,
      disabledBackgroundColor: theme.primaryBlack,
      textColor: theme.primaryWhite,
    );
  }

  factory BaseButtonTheme.secondary(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    final style = CustomTextStyles.of(context);
    return BaseButtonTheme._(
      backgroundColor: theme.primaryWhite,
      borderColor: theme.black50,
      pressedColor: theme.black50.withValues(alpha: 0.1),
      disabledBackgroundColor: theme.primaryWhite.withValues(alpha: 0.5),
      textColor: theme.primaryBlack,
      textButtonStyle: style.f18W500.value.copyWith(fontWeight: FontWeight.w700),
    );
  }

  final Color backgroundColor, pressedColor, disabledBackgroundColor, textColor;
  final Color? borderColor;
  final TextStyle? textButtonStyle;

  bool get hasBorder => borderColor != null;

  BaseButtonTheme copyWith({
    Color? backgroundColor,
    Color? pressedColor,
    Color? disabledBackgroundColor,
    Color? textColor,
    Color? borderColor,
    TextStyle? textButtonStyle,
  }) {
    return BaseButtonTheme._(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pressedColor: pressedColor ?? this.pressedColor,
      disabledBackgroundColor: disabledBackgroundColor ?? this.disabledBackgroundColor,
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
      textButtonStyle: textButtonStyle ?? this.textButtonStyle,
    );
  }
}
