import 'package:flutter/widgets.dart';

/// Keys estables para los tests e2e (Patrol). Centralizados acá para que los
/// finders de `integration_test/` y los widgets usen exactamente los mismos.
abstract final class E2eKeys {
  // Login
  static const loginEmailField = Key('e2e_login_email');
  static const loginPasswordField = Key('e2e_login_password');
  static const loginSubmitButton = Key('e2e_login_submit');
  static const loginErrorBanner = Key('e2e_login_error');

  // Catálogo
  static const catalogSearchField = Key('e2e_catalog_search');
  static Key productCard(String id) => Key('e2e_product_card_$id');
  static Key productCardPrice(String id) => Key('e2e_product_card_price_$id');

  // Detalle de producto
  static const productDetailPrice = Key('e2e_product_detail_price');
  static const productDetailAddToCart = Key('e2e_product_detail_add_to_cart');
  static const productDetailQtyIncrement = Key('e2e_product_detail_qty_inc');
  static const productDetailQtyDecrement = Key('e2e_product_detail_qty_dec');

  // Carrito
  static Key cartItem(String productId) => Key('e2e_cart_item_$productId');
  static Key cartItemSubtotal(String productId) => Key('e2e_cart_item_subtotal_$productId');
  static const cartTotal = Key('e2e_cart_total');
  static const cartCheckoutButton = Key('e2e_cart_checkout');

  // Confirmación de orden
  static const orderConfirmDialogTotal = Key('e2e_order_confirm_total');
  static const orderConfirmAccept = Key('e2e_order_confirm_accept');
  static const orderConfirmCancel = Key('e2e_order_confirm_cancel');

  // Órdenes
  static Key orderCard(String id) => Key('e2e_order_card_$id');

  // Perfil
  static const profileLogoutButton = Key('e2e_profile_logout');

  // Bottom nav — ids: products, cart, orders, profile
  static Key navTab(String id) => Key('e2e_nav_tab_$id');
  static const navCatalogTab = Key('e2e_nav_tab_products');
  static const navCartTab = Key('e2e_nav_tab_cart');
  static const navOrdersTab = Key('e2e_nav_tab_orders');
  static const navProfileTab = Key('e2e_nav_tab_profile');
}
