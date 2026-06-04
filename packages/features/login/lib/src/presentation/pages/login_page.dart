import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:login/src/domain/entities/auth_tokens.dart';
import 'package:login/src/presentation/bloc/login/login_cubit.dart';
import 'package:login/src/presentation/bloc/login_form/login_form_cubit.dart';

class LoginPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      body: SafeArea(
        child: BlocConsumer<LoginCubit, LoginState>(
          bloc: loginCubit,
          listener: (context, state) {
            if (state is LoginSuccess) {
              onLoginSuccess(context, state.tokens);
              loginCubit.reset();
            }
          },
          builder: (context, loginState) {
            final isSubmitting = loginState is LoginSubmitting;
            final failureMessage =
                loginState is LoginFailureState ? loginState.failure.message : null;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              child: BlocBuilder<LoginFormCubit, LoginFormState>(
                bloc: formCubit,
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
                      Center(child: Text('Iniciar sesión', style: SwText.display(size: 30))),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Gestioná tus pedidos y entregas.',
                          style: SwText.body(size: 14, color: SwColors.text3),
                        ),
                      ),
                      const SizedBox(height: 26),
                      SwTextField(
                        controller: formCubit.emailController,
                        label: 'Email',
                        placeholder: 'vos@empresa.com',
                        keyboardType: TextInputType.emailAddress,
                        error: formState.showErrors ? formState.emailError : null,
                        prefix: _InputLeadingIcon(asset: 'assets/icons/mail.svg'),
                      ),
                      const SizedBox(height: 14),
                      SwTextField(
                        controller: formCubit.passwordController,
                        label: 'Contraseña',
                        placeholder: '••••••••',
                        obscure: formState.obscurePassword,
                        error: formState.showErrors ? formState.passwordError : null,
                        prefix: _InputLeadingIcon(asset: 'assets/icons/lock.svg'),
                        trailingAction: GestureDetector(
                          onTap: () {},
                          child: Text('¿Olvidaste?', style: SwText.body(size: 14, color: SwColors.link)),
                        ),
                        suffix: _PasswordVisibilityToggle(
                          obscured: formState.obscurePassword,
                          onToggle: formCubit.toggleObscurePassword,
                        ),
                      ),
                      if (failureMessage != null) ...[
                        const SizedBox(height: 12),
                        _ErrorBanner(message: failureMessage),
                      ],
                      const SizedBox(height: 22),
                      SwButton(
                        label: 'Iniciar sesión',
                        isLoading: isSubmitting,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (!formCubit.validate()) return;
                          loginCubit.submit(
                            email: formCubit.state.email,
                            password: formCubit.state.password,
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: SwText.body(size: 12, color: SwColors.text3),
                            children: [
                              const TextSpan(text: 'Al continuar aceptás los '),
                              TextSpan(text: 'Términos', style: SwText.body(size: 12, color: SwColors.link)),
                              const TextSpan(text: ' y la '),
                              TextSpan(text: 'Política de Privacidad', style: SwText.body(size: 12, color: SwColors.link)),
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
      tooltip: obscured ? 'Mostrar contraseña' : 'Ocultar contraseña',
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
