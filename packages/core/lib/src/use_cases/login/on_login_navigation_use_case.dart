import 'package:commons/helpers/injector/injector.dart';
import 'package:commons/helpers/navigation_helper/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:login/login.dart';

class OnLoginNavigationUseCase {
  static void call(BuildContext context) {
    Injector.i.resolve<NavigationHelper>().pushNamed(context, routeName: LoginFeatureBuilder.path, replace: true);
  }
}
