import 'package:flutter/material.dart';

abstract class NavigationHelper {
  void pushNamed(
    BuildContext context, {
    required String routeName,
    Map<String, dynamic>? data,
    bool disableAnimation = false,
    bool replace = false,
  });

  void pop(BuildContext context);

  void popToPreviousRoute(BuildContext context);

  bool isCurrentRoute(BuildContext context, String route);

  String currentPath(BuildContext context);

  bool canPop(BuildContext context);
}
