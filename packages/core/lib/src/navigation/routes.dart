class Routes {
  static const String login = '/login';
  static const String profile = '/profile';
  static const String catalog = '/catalog';
  static const String catalogDetailPattern = '/catalog/:id';
  static const String cart = '/cart';
  static const String orderSuccessPattern = '/order/:id/success';

  static String catalogDetail(String productId) => '/catalog/$productId';

  static String orderSuccess(String orderId) => '/order/$orderId/success';

  static const String orders = '/orders';
  static const String orderDetailPattern = '/orders/:id';

  static String orderDetail(String id) => '/orders/$id';
}
