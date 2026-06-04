import 'package:email_validator/email_validator.dart';

class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.showErrors = false,
    this.obscurePassword = true,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool showErrors;
  final bool obscurePassword;

  bool get isEmailValid => email.isNotEmpty && EmailValidator.validate(email);
  bool get isPasswordValid => password.length >= 6;
  bool get isValid => isEmailValid && isPasswordValid;

  LoginFormState copyWith({
    String? email,
    String? password,
    Object? emailError = _sentinel,
    Object? passwordError = _sentinel,
    bool? showErrors,
    bool? obscurePassword,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: identical(emailError, _sentinel)
          ? this.emailError
          : emailError as String?,
      passwordError: identical(passwordError, _sentinel)
          ? this.passwordError
          : passwordError as String?,
      showErrors: showErrors ?? this.showErrors,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

const Object _sentinel = Object();
