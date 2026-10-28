class Routes {
  static const String login = '/login';
  static const String profile = '/profile';
  static const String profileEditAddress = '/profile/address';
  static const String catalog = '/catalog';
  static const String catalogDetailPattern = '/catalog/:id';
  static const String cart = '/cart';
  static const String orderSuccessPattern = '/order/:id/success';

  static String catalogDetail(String productId) => '/catalog/$productId';

  /// Detalle de producto abierto desde el carrusel de recomendaciones.
  /// El origen viaja como query param (`?from=reco`) porque Beamer rearma la
  /// página desde la URL: cualquier estado fuera de ella se pierde en un
  /// deep-link o un rebuild del router.
  static String catalogDetailFromReco(String productId) =>
      '/catalog/$productId?from=reco';

  static String orderSuccess(String orderId) => '/order/$orderId/success';

  static const String orders = '/orders';
  static const String orderDetailPattern = '/orders/:id';

  static String orderDetail(String id) => '/orders/$id';

  static const String notifications = '/notifications';
}
