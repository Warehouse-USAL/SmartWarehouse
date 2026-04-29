import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.empty() = EmptyAuthState;

  const factory AuthState.data(AuthData authData, {required bool hasUpdated}) = SuccessAuthState;
}
