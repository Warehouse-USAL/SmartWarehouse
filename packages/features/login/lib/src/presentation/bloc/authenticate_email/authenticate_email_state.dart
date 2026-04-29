import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:login/src/domain/entities/login_failure.dart';

part 'authenticate_email_state.freezed.dart';

@freezed
sealed class AuthenticateEmailState with _$AuthenticateEmailState {
  const factory AuthenticateEmailState.initial() = InitialAuthenticateEmailState;

  const factory AuthenticateEmailState.loading() = LoadingAuthenticateEmailState;

  const factory AuthenticateEmailState.success() = SuccessAuthenticateEmailState;

  const factory AuthenticateEmailState.fail(LoginFailure failure) = FailAuthenticateEmailState;
}
