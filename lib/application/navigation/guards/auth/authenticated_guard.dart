import 'package:beamer/beamer.dart';
import 'package:commons/commons.dart';
import 'package:core/core.dart';
import 'package:smart_warehouse/application/navigation/guards/custom_beamer_guard.dart';

class AuthenticatedGuard implements CustomBeamerGuard {
  @override
  BeamGuard get guard => BeamGuard(
        pathPatterns: [Routes.login],
        check: (context, __) {
          final authCubit = Injector.i.resolve<AuthCubit>();
          return authCubit.state.maybeWhen(orElse: () => true, data: (_, __) => false);
        },
        onCheckFailed: (context, __) {
          Injector.i.resolve<NavigationHelper>().pushNamed(context, routeName: Routes.home, replace: true);
        },
      );
}
