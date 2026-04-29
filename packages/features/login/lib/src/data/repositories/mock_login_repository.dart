import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:login/src/domain/entities/login_failure.dart';
import 'package:login/src/domain/repositories/login_repository.dart';

class MockLoginRepository implements LoginRepository {
  @override
  Future<Option<LoginFailure>> authenticateEmail(String email) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return const None();
    } catch (e) {
      log('$e');
      return Some(LoginFailure(message: 'An error occurred. Please try again later.'));
    }
  }
}
