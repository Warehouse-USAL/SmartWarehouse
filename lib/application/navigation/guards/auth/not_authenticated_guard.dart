import 'package:beamer/beamer.dart';
import 'package:commons/commons.dart';
import 'package:core/core.dart';
import 'package:smart_warehouse/application/navigation/guards/custom_beamer_guard.dart';

class NotAuthenticatedGuard implements CustomBeamerGuard {
  @override
  BeamGuard get guard => BeamGuard(
        pathPatterns: [
          Routes.login,
        ],
        guardNonMatching: true,
        check: (context, __) {
          final authCubit = Injector.i.resolveOrNull<AuthCubit>();
          if (authCubit == null) {
            return false;
          }
          return authCubit.state.maybeWhen(orElse: () => false, data: (_, __) => true);
        },
        onCheckFailed: (context, __) {
          Injector.i.resolve<NavigationHelper>().pushNamed(context, routeName: Routes.login, replace: true);
        },
      );
}
