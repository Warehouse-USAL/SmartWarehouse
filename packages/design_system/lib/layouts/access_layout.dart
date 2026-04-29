import 'package:design_system/buttons/primary_button.dart';
import 'package:design_system/design_system.dart';
import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/inputs/custom_text_input.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/widgets/custom_text_separator.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:flutter/material.dart';

class AccessLayout extends StatelessWidget {
  const AccessLayout({
    required this.title,
    required this.textInputLabel,
    required this.controller,
    required this.primaryTextButton,
    required this.bottomText,
    required this.onContinueWithGooglePressed,
    required this.onContinueWithApplePressed,
    this.isLoading = false,
    super.key,
    this.onPrimaryButtonPressed,
    this.onBottomTextPressed,
    this.textInputError,
  });

  final String title, textInputLabel, primaryTextButton, bottomText;
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onContinueWithApplePressed, onContinueWithGooglePressed;
  final VoidCallback? onPrimaryButtonPressed, onBottomTextPressed;
  final String? textInputError;

  @override
  Widget build(BuildContext context) {
    final style = CustomTextStyles.of(context);
    final theme = CustomThemeExtension.of(context);
    return Column(
      children: [
        const CustomSpacer(height: CustomSpace.x6),
        CustomText(title, styleBuilder: (style) => style.f24W500),
        const CustomSpacer(height: CustomSpace.x6),
        CustomTextInput(
          prefixIcon: CustomIconData.emailOutline,
          controller: controller,
          label: textInputLabel,
          error: textInputError,
          textInputType: TextInputType.emailAddress,
        ),
        const CustomSpacer(height: CustomSpace.x7),
        PrimaryButton(
          baseButtonTheme: BaseButtonTheme.primary(context),
          text: primaryTextButton,
          onPressed: onPrimaryButtonPressed,
          isLoading: isLoading,
        ),
        Visibility(
          visible: false,
          child: Column(
            children: [
              const SizedBox(height: 37),
              const CustomTextSeparator(text: 'OR'),
              const CustomSpacer(height: CustomSpace.x7),
              PrimaryButton(
                baseButtonTheme: BaseButtonTheme.secondary(context),
                text: 'Continue with Google',
                leadingIconData: CustomIconData.googleIcon,
                onPressed: onContinueWithGooglePressed,
              ),
              const CustomSpacer(height: CustomSpace.x3),
              PrimaryButton(
                baseButtonTheme: BaseButtonTheme.secondary(context),
                text: 'Continue with Apple',
                leadingIconData: CustomIconData.appleIcon,
                onPressed: onContinueWithApplePressed,
              ),
            ],
          ),
        ),
        const CustomSpacer(height: CustomSpace.x2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PressableWidget(
              onPressed: onBottomTextPressed,
              child: CustomText(bottomText, style: style.f14W600.value.copyWith(color: theme.black70)),
            ),
          ],
        ),
      ],
    );
  }
}
