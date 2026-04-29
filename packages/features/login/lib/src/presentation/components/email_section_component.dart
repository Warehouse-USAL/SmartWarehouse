import 'package:design_system/layouts/access_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login/src/domain/entities/form_data.dart';
import 'package:login/src/presentation/bloc/email_form/email_form_cubit.dart';

class EmailSectionComponent extends StatelessWidget {
  const EmailSectionComponent({
    required this.formCubit,
    required this.onSignUpPressed,
    required this.onContinuePressed,
    required this.onContinueWithGooglePressed,
    this.isPrimaryButtonLoading = false,
    super.key,
  });

  final EmailFormCubit formCubit;
  final VoidCallback onSignUpPressed, onContinueWithGooglePressed;
  final Function(String email) onContinuePressed;
  final bool isPrimaryButtonLoading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmailFormCubit, FormData>(
      bloc: formCubit,
      builder: (context, state) {
        return AccessLayout(
          title: 'Log in to Your Account',
          primaryTextButton: 'Sign in',
          isLoading: isPrimaryButtonLoading,
          onPrimaryButtonPressed: () => state.isValid ? onContinuePressed(state.text!) : formCubit.displayError(),
          onContinueWithGooglePressed: () {},
          textInputLabel: 'Email',
          controller: formCubit.textController,
          bottomText: "Don't have an account? Sign up",
          onBottomTextPressed: onSignUpPressed,
          onContinueWithApplePressed: () {},
          textInputError: state.error,
        );
      },
    );
  }
}
