import 'package:core/src/navigation/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds a catalog detail path from a product id', () {
    expect(Routes.catalogDetail('p-1'), '/catalog/p-1');
  });

  test('builds a catalog detail path tagged as coming from a reco', () {
    // El `?from=reco` es el contrato con beamer_config_helper: el detalle
    // lee ese query param para atribuir el agregado al carrusel.
    expect(Routes.catalogDetailFromReco('p-1'), '/catalog/p-1?from=reco');
  });

  test('builds an order success path from an order id', () {
    expect(Routes.orderSuccess('o-9'), '/order/o-9/success');
  });

  test('builds an order detail path from an order id', () {
    expect(Routes.orderDetail('o-9'), '/orders/o-9');
  });

  test('builders line up with their patterns', () {
    expect(Routes.catalogDetailPattern, '/catalog/:id');
    expect(Routes.orderDetailPattern, '/orders/:id');
    expect(Routes.orderSuccessPattern, '/order/:id/success');
  });

  test('static routes are stable', () {
    expect(Routes.login, '/login');
    expect(Routes.catalog, '/catalog');
    expect(Routes.cart, '/cart');
    expect(Routes.orders, '/orders');
    expect(Routes.profile, '/profile');
    expect(Routes.profileEditAddress, '/profile/address');
    expect(Routes.notifications, '/notifications');
  });
}
