import 'package:flutter_test/flutter_test.dart';
import 'package:orders/src/data/dtos/create_order_request_dto.dart';

void main() {
  group('CreateOrderItemDto', () {
    test('serializa from_recommendation en snake_case', () {
      const dto = CreateOrderItemDto(
        productId: 'p-1',
        quantity: 2,
        fromRecommendation: true,
      );

      expect(dto.toJson(), {
        'product_id': 'p-1',
        'quantity': 2,
        'from_recommendation': true,
      });
    });

    test('sin flag manda false explícito (el back lo acepta opcional)', () {
      // Decisión: false explícito en vez de omitir el campo — un bool
      // siempre presente es más simple de consumir en métricas que
      // distinguir "ausente" de "false".
      const dto = CreateOrderItemDto(productId: 'p-1', quantity: 1);

      expect(dto.toJson()['from_recommendation'], isFalse);
    });

    test('fromJson tolera el campo ausente (default false)', () {
      final dto = CreateOrderItemDto.fromJson(const {
        'product_id': 'p-1',
        'quantity': 3,
      });

      expect(dto.fromRecommendation, isFalse);
      expect(dto.quantity, 3);
    });

    test('round-trip conserva el flag', () {
      const dto = CreateOrderItemDto(
        productId: 'p-9',
        quantity: 4,
        fromRecommendation: true,
      );

      expect(CreateOrderItemDto.fromJson(dto.toJson()), dto);
    });
  });

  group('CreateOrderRequestDto', () {
    test('el body completo incluye el flag dentro de items', () {
      const request = CreateOrderRequestDto(
        items: [
          CreateOrderItemDto(productId: 'a', quantity: 1),
          CreateOrderItemDto(
            productId: 'b',
            quantity: 2,
            fromRecommendation: true,
          ),
        ],
        destinationArea: 'Bay 14',
        address: AddressDto(street: 'Av. Siempre Viva 742', postalCode: '1414'),
      );

      final items = request.toJson()['items'] as List<dynamic>;
      expect((items[0] as Map)['from_recommendation'], isFalse);
      expect((items[1] as Map)['from_recommendation'], isTrue);
    });
  });
}
