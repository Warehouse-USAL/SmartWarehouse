import 'package:design_system/buttons/primary_button.dart';
import 'package:design_system/inputs/custom_text_input.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:design_system/widgets/spaces/custom_spacer.dart';
import 'package:design_system/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';

class OtpLayout extends StatelessWidget {
  const OtpLayout({
    required this.onResendCodePressed,
    required this.isLoading,
    required this.controller,
    super.key,
    this.onSubmitPressed,
  });

  final VoidCallback? onSubmitPressed;
  final VoidCallback onResendCodePressed;
  final bool isLoading;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final style = CustomTextStyles.of(context);
    return Column(
      children: [
        const SizedBox(height: 231),
        CustomText(
          'Please enter the OTP send on your E mail address',
          style: style.f20W700.value.copyWith(color: Colors.grey),
        ),
        const CustomSpacer(height: CustomSpace.x5),
        CustomTextInput(
          controller: controller,
          label: 'Enter OTP',
        ),
        const CustomSpacer(height: CustomSpace.x5),
        PrimaryButton(
          text: 'Submit',
          isLoading: isLoading,
          onPressed: onSubmitPressed,
        ),
        const CustomSpacer(height: CustomSpace.x5),
        Align(
          alignment: Alignment.centerRight,
          child: PressableWidget(
            backgroundColor: Colors.transparent,
            onPressed: onResendCodePressed,
            child: CustomText(
              'Resend OTP',
              style: style.f16W600.value.copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }
}
