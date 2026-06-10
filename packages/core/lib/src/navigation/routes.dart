class Routes {
  static const String login = '/login';
  static const String profile = '/profile';
  static const String catalog = '/catalog';
  static const String catalogDetailPattern = '/catalog/:id';
  static const String cart = '/cart';
  static const String orderSuccessPattern = '/order/:id/success';

  static String catalogDetail(String productId) => '/catalog/$productId';

  static String orderSuccess(String orderId) => '/order/$orderId/success';

  static String orderDetail(String id) => '/orders/$id';
}
