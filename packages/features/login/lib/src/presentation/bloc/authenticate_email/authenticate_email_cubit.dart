import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login/src/domain/repositories/login_repository.dart';
import 'package:login/src/presentation/bloc/authenticate_email/authenticate_email_state.dart';
export 'authenticate_email_state.dart';

class AuthenticateEmailCubit extends Cubit<AuthenticateEmailState> {
  AuthenticateEmailCubit(this.repository) : super(const AuthenticateEmailState.initial());

  final LoginRepository repository;

  Future<void> submit(String email) async {
    emit(const AuthenticateEmailState.loading());
    final result = await repository.authenticateEmail(email);
    result.fold(
      () => emit(const AuthenticateEmailState.success()),
      (failure) => emit(AuthenticateEmailState.fail(failure)),
    );
  }

  void reset() => emit(const AuthenticateEmailState.initial());
}
