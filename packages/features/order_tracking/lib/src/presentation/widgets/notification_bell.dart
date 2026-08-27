import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Icono de campana con badge de no-leídas. Tap navega a /notifications.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderNotificationCubit, OrderNotificationState>(
      bloc: Injector.i.resolve<OrderNotificationCubit>(),
      builder: (context, state) {
        final unread = state.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            SwIconButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notificaciones',
              // disableAnimation: false → evita el NoAnimationTransitionDelegate
              // de Beamer, que tiene un bug interactuando con DialogRoutes
              // (UpgradeAlert) y dispara asserts del navigator.
              onPressed: () =>
                  Injector.i.resolve<NavigationHelper>().pushNamed(
                        context,
                        routeName: Routes.notifications,
                        disableAnimation: false,
                      ),
            ),
            if (unread > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: BoxDecoration(
                    color: SwColors.stockOut,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: SwText.body(
                        size: 10,
                        weight: FontWeight.w700,
                        color: SwColors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
