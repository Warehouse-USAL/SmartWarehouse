import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:order_tracking/src/data/repositories/mock_order_tracking_repository.dart';
import 'package:order_tracking/src/data/repositories/remote_order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/pages/order_detail_page.dart';
import 'package:order_tracking/src/presentation/pages/order_list_page.dart';

class OrderTrackingFeatureBuilder {
  static void injectDependencies({required String baseUrl}) {
    Injector.i
      ..registerLazySingleton<OrderTrackingRepository>(
        () => Injector.i.resolve<AppDataSource>().isMock
            ? MockOrderTrackingRepository()
            : RemoteOrderTrackingRepository(
                httpHelper: Injector.i.resolve<HttpHelper>(),
                getToken: OnGetTokenUseCase.call,
                baseUrl: baseUrl,
              ),
      )
      ..registerLazySingleton<OrderListCubit>(
        () => OrderListCubit(
          Injector.i.resolve<OrderTrackingRepository>(),
        ),
      );
  }

  static Widget buildOrderListPage() =>
      OrderListPage(cubit: Injector.i.resolve<OrderListCubit>());

  static Widget buildOrderDetailPage(String orderId) {
    final cubit = OrderDetailCubit(Injector.i.resolve<OrderTrackingRepository>())
      ..load(orderId);
    return OrderDetailPage(cubit: cubit, orderId: orderId);
  }
}
