import 'package:catalog/src/data/dtos/price_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceDto.fromJson', () {
    test('lee amount_cents (endpoint de detalle)', () {
      final dto = PriceDto.fromJson(const {'amount_cents': 1250, 'currency': 'ARS'});
      expect(dto.amountCents, 1250);
      expect(dto.currency, 'ARS');
    });

    test('lee amount (endpoint de listado)', () {
      final dto = PriceDto.fromJson(const {'amount': 990, 'currency': 'ars'});
      expect(dto.amountCents, 990);
      expect(dto.currency, 'ARS');
    });

    test('amount_cents tiene prioridad si vienen ambos', () {
      final dto = PriceDto.fromJson(
        const {'amount_cents': 100, 'amount': 999, 'currency': 'ARS'},
      );
      expect(dto.amountCents, 100);
    });

    test('rechaza precio sin monto en vez de caer a 0', () {
      expect(
        () => PriceDto.fromJson(const {'currency': 'ARS'}),
        throwsFormatException,
      );
    });

    test('rechaza precio sin currency en vez de asumir default', () {
      expect(
        () => PriceDto.fromJson(const {'amount_cents': 100}),
        throwsFormatException,
      );
    });
  });
}
