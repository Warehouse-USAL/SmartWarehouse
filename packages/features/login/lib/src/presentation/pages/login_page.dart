import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:login/src/domain/entities/auth_tokens.dart';
import 'package:login/src/presentation/bloc/login/login_cubit.dart';
import 'package:login/src/presentation/bloc/login_form/login_form_cubit.dart';
import 'package:login/src/presentation/widgets/sw_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.formCubit,
    required this.loginCubit,
    required this.onLoginSuccess,
    super.key,
  });

  final LoginFormCubit formCubit;
  final LoginCubit loginCubit;
  final void Function(BuildContext context, AuthTokens tokens) onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          bloc: widget.loginCubit,
          listener: _onLoginStateChanged,
          builder: (context, loginState) {
            final isSubmitting = loginState is LoginSubmitting;
            final failureMessage =
                loginState is LoginFailureState ? loginState.failure.message : null;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              child: BlocBuilder<LoginFormCubit, LoginFormState>(
                bloc: widget.formCubit,
                builder: (context, formState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const Center(child: SwLogo(size: 40)),
                      const SizedBox(height: 16),
                      Center(
                        child: Image.asset(
                          'assets/images/login_hero.png',
                          height: 200,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(child: Text('Sign in', style: SwText.display(size: 30))),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Manage your orders and deliveries.',
                          style: SwText.body(size: 14, color: SwColors.text3),
                        ),
                      ),
                      const SizedBox(height: 26),
                      SwTextField(
                        controller: widget.formCubit.emailController,
                        label: 'Email',
                        placeholder: 'you@company.com',
                        keyboardType: TextInputType.emailAddress,
                        error: formState.showErrors ? formState.emailError : null,
                        prefix: _InputLeadingIcon(asset: 'assets/icons/mail.svg'),
                      ),
                      const SizedBox(height: 14),
                      SwTextField(
                        controller: widget.formCubit.passwordController,
                        label: 'Password',
                        placeholder: '••••••••',
                        obscure: _obscurePassword,
                        error: formState.showErrors ? formState.passwordError : null,
                        prefix: _InputLeadingIcon(asset: 'assets/icons/lock.svg'),
                        trailingAction: GestureDetector(
                          onTap: () {},
                          child: Text('Forgot?', style: SwText.body(size: 14, color: SwColors.link)),
                        ),
                        suffix: _PasswordVisibilityToggle(
                          obscured: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      if (failureMessage != null) ...[
                        const SizedBox(height: 12),
                        _ErrorBanner(message: failureMessage),
                      ],
                      const SizedBox(height: 22),
                      SwButton(
                        label: 'Sign in',
                        isLoading: isSubmitting,
                        onPressed: () => _onSubmit(context),
                      ),
                      const SizedBox(height: 10),
                      SwButton(
                        label: 'Continue with SSO',
                        variant: SwButtonVariant.secondary,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 22),
                      const _NewToContextBlock(),
                      const SizedBox(height: 28),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: SwText.body(size: 12, color: SwColors.text3),
                            children: [
                              const TextSpan(text: 'By continuing you agree to our '),
                              TextSpan(text: 'Terms', style: SwText.body(size: 12, color: SwColors.link)),
                              const TextSpan(text: ' and '),
                              TextSpan(text: 'Privacy Policy', style: SwText.body(size: 12, color: SwColors.link)),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!widget.formCubit.validate()) return;
    widget.loginCubit.submit(
      email: widget.formCubit.state.email,
      password: widget.formCubit.state.password,
    );
  }

  void _onLoginStateChanged(BuildContext context, LoginState state) {
    if (state is LoginSuccess) {
      widget.onLoginSuccess(context, state.tokens);
      widget.loginCubit.reset();
    }
  }
}

class _NewToContextBlock extends StatelessWidget {
  const _NewToContextBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwColors.yellowSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: SwColors.yellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 16, color: SwColors.text),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: SwText.body(size: 13, color: SwColors.text2, height: 1.45),
                children: [
                  TextSpan(
                    text: 'New to SmartWarehouse? ',
                    style: SwText.body(size: 13, color: SwColors.text, weight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: 'Request access',
                    style: SwText.body(size: 13, color: SwColors.yellowDark, weight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' from your account manager.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputLeadingIcon extends StatelessWidget {
  const _InputLeadingIcon({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(SwColors.text3, BlendMode.srcIn),
    );
  }
}

class _PasswordVisibilityToggle extends StatelessWidget {
  const _PasswordVisibilityToggle({required this.obscured, required this.onToggle});

  final bool obscured;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      splashRadius: 20,
      tooltip: obscured ? 'Show password' : 'Hide password',
      icon: SvgPicture.asset(
        obscured ? 'assets/icons/eye_closed.svg' : 'assets/icons/eye_open.svg',
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(SwColors.text3, BlendMode.srcIn),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x14B91C1C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x4DB91C1C)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: SwColors.stockOut, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: SwText.body(size: 13, color: SwColors.stockOut))),
        ],
      ),
    );
  }
}
