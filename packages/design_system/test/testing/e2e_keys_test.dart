import 'package:design_system/testing/e2e_keys.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// `E2eKeys` es el contrato entre los widgets y los finders de la suite Patrol
/// (`integration_test/`). Los cuatro generadores son los unicos con logica —
/// interpolan un id — y los alias constantes tienen que dar exactamente lo
/// mismo que el generador para el mismo id.
///
/// Si un alias y su generador se separan, los widget tests siguen verdes y la
/// suite e2e falla en otro repo de archivos. Estos casos lo atrapan acá.
void main() {
  group('generadores', () {
    test('productCard interpola el id', () {
      expect(E2eKeys.productCard('42'), const Key('e2e_product_card_42'));
    });

    test('productCardPrice no colisiona con productCard', () {
      // Un prefijo compartido con `productCard` haria que el finder del precio
      // matcheara la card entera.
      expect(
        E2eKeys.productCardPrice('42'),
        isNot(E2eKeys.productCard('42')),
      );
    });

    test('cartItem y cartItemSubtotal se distinguen', () {
      expect(
        E2eKeys.cartItemSubtotal('p-1'),
        isNot(E2eKeys.cartItem('p-1')),
      );
    });

    test('orderCard interpola el id', () {
      expect(E2eKeys.orderCard('o-9'), const Key('e2e_order_card_o-9'));
    });

    test('ids distintos dan keys distintas', () {
      expect(E2eKeys.navTab('cart'), isNot(E2eKeys.navTab('orders')));
    });
  });

  group('alias de los tabs', () {
    const aliases = <String, Key>{
      'products': E2eKeys.navCatalogTab,
      'cart': E2eKeys.navCartTab,
      'orders': E2eKeys.navOrdersTab,
      'profile': E2eKeys.navProfileTab,
    };

    for (final entry in aliases.entries) {
      test('el alias de ${entry.key} coincide con navTab', () {
        expect(entry.value, E2eKeys.navTab(entry.key));
      });
    }
  });
}
