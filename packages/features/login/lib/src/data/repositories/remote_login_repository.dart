import 'dart:async';
import 'dart:developer';

import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';
import 'package:login/src/domain/entities/login_failure.dart';
import 'package:login/src/domain/repositories/login_repository.dart';

class RemoteLoginRepository implements LoginRepository {
  RemoteLoginRepository({required this.httpHelper});

  final HttpHelper httpHelper;
  Completer<void>? _loginCompleter;

  @override
  Future<Option<LoginFailure>> authenticateEmail(String email) async {
    try {
      if (_loginCompleter != null) {
        return Some(LoginFailure(message: 'Cannot send more than 1 code at a time.'));
      }
      _loginCompleter = Completer<void>();
      _loginCompleter?.future.whenComplete(() => _loginCompleter = null);
      final result = await httpHelper.post('/authenticate/email', data: {'email': email.toLowerCase()});
      await _completeAndWaitForCompleter();
      return result.fold(
        (failure) => Some(LoginFailure(message: 'Sorry, there was an error authenticating your email.')),
        (response) => const None(),
      );
    } catch (e) {
      log('$e');
      await _completeAndWaitForCompleter();
      return Some(LoginFailure(message: 'Sorry, there was an error authenticating your email.'));
    }
  }

  Future<void> _completeAndWaitForCompleter() async {
    _loginCompleter?.complete();
    await _loginCompleter?.future;
  }
}
