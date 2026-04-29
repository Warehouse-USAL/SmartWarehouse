import 'package:commons/helpers/http/http_helper.dart';
import 'package:commons/helpers/injector/injector.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:login/src/data/repositories/remote_login_repository.dart';
import 'package:login/src/domain/entities/login_failure.dart';
import 'package:login/src/domain/repositories/login_repository.dart';
import 'package:login/src/presentation/bloc/authenticate_email/authenticate_email_cubit.dart';
import 'package:login/src/presentation/bloc/email_form/email_form_cubit.dart';
import 'package:login/src/presentation/pages/login_view.dart';

class LoginFeatureBuilder {
  static const path = '/login';

  static Future<Option<LoginFailure>> authenticateEmail(String email) async {
    final repository = _remoteLoginRepository();
    final result = await repository.authenticateEmail(email);
    return result;
  }

  static LoginRepository _remoteLoginRepository() {
    return RemoteLoginRepository(
      httpHelper: Injector.i.resolve<HttpHelper>(),
    );
  }

  static Widget buildPage() {
    final emailFormCubit = EmailFormCubit();
    final repository = _remoteLoginRepository();
    final authenticateEmailCubit = AuthenticateEmailCubit(repository);
    return LoginView(
      emailFormCubit: emailFormCubit,
      // TODO: Implement OTP navigation when feature is added
      onSubmitMailSuccess: (context, email) {},
      // TODO: Implement sign up navigation when feature is added
      onSignUpPressed: (context) {},
      authenticateEmailCubit: authenticateEmailCubit,
      onContinueWithGooglePressed: (context) {},
    );
  }
}
