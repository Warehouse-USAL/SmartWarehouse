import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login/src/presentation/bloc/login_form/login_form_state.dart';

export 'login_form_state.dart';

class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit() : super(const LoginFormState()) {
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _onEmailChanged() {
    emit(state.copyWith(email: emailController.text, emailError: null));
  }

  void _onPasswordChanged() {
    emit(state.copyWith(password: passwordController.text, passwordError: null));
  }

  bool validate() {
    final emailError = state.isEmailValid ? null : 'Email inválido';
    final passwordError = state.isPasswordValid ? null : 'Mínimo 6 caracteres';
    emit(state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      showErrors: true,
    ));
    return state.isValid;
  }

  void toggleObscurePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
