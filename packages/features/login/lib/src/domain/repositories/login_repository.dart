import 'package:dartz/dartz.dart';
import 'package:login/src/domain/entities/login_failure.dart';

abstract class LoginRepository {
  Future<Option<LoginFailure>> authenticateEmail(String email);
}
