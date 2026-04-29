import 'package:commons/commons.dart';
import 'package:core/src/navigation/routes.dart';
import 'package:flutter/material.dart';

class OnUserAuthenticatedUseCase {
  static void call(BuildContext context) {
    Injector.i.resolve<NavigationHelper>().pushNamed(
          context,
          routeName: Routes.home,
          replace: true,
        );
  }
}
