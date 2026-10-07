import 'package:bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Los cuatro getters son cadenas `maybeWhen` escritas a mano, una por
  // variante. El modo de falla natural es el copy-paste a medio corregir: un
  // getter que responde por la variante del de al lado. Por eso se verifica la
  // matriz completa y no solo el caso positivo de cada uno.
  group('NavigationBarOption', () {
    const options = <String, NavigationBarOption>{
      'products': NavigationBarOption.products(),
      'cart': NavigationBarOption.cart(),
      'orders': NavigationBarOption.orders(),
      'profile': NavigationBarOption.profile(),
    };

    final getters = <String, bool Function(NavigationBarOption)>{
      'products': (o) => o.isProducts,
      'cart': (o) => o.isCart,
      'orders': (o) => o.isOrders,
      'profile': (o) => o.isProfile,
    };

    for (final getterEntry in getters.entries) {
      for (final optionEntry in options.entries) {
        final shouldMatch = getterEntry.key == optionEntry.key;
        test(
          'is${getterEntry.key} es $shouldMatch para ${optionEntry.key}',
          () => expect(
            getterEntry.value(optionEntry.value),
            shouldMatch,
          ),
        );
      }
    }
  });
}
