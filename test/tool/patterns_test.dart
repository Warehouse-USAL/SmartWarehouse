import 'package:flutter_test/flutter_test.dart';

import '../../tool/coverage/patterns.dart';

void main() {
  group('matchesPattern', () {
    test('matches generated files at any depth', () {
      expect(matchesPattern('lib/a.g.dart', '**/*.g.dart'), isTrue);
      expect(matchesPattern('lib/src/data/dtos/product_dto.g.dart', '**/*.g.dart'), isTrue);
      expect(matchesPattern('lib/src/product.freezed.dart', '**/*.freezed.dart'), isTrue);
    });

    test('does not match non-generated files', () {
      expect(matchesPattern('lib/src/product.dart', '**/*.g.dart'), isFalse);
      expect(matchesPattern('lib/src/gadget.dart', '**/*.g.dart'), isFalse);
    });

    test('matches an exact path', () {
      const p = 'lib/helpers/http/dio_http_helper.dart';
      expect(matchesPattern(p, p), isTrue);
      expect(matchesPattern('lib/helpers/http/http_helper.dart', p), isFalse);
    });

    test('single star does not cross directory separators', () {
      expect(matchesPattern('lib/a.dart', 'lib/*.dart'), isTrue);
      expect(matchesPattern('lib/src/a.dart', 'lib/*.dart'), isFalse);
    });

    test('dots are literal, not wildcards', () {
      expect(matchesPattern('lib/axg.dart', '**/*.g.dart'), isFalse);
    });

    test('matches everything under a pages directory at any depth', () {
      expect(
        matchesPattern('lib/src/presentation/pages/cart_page.dart',
            '**/presentation/pages/**'),
        isTrue,
      );
    });

    test('does not match siblings of a pages directory', () {
      expect(
        matchesPattern('lib/src/presentation/widgets/cart_badge.dart',
            '**/presentation/pages/**'),
        isFalse,
      );
    });

    test('does not match a page-named file outside the pages directory', () {
      expect(
        matchesPattern('lib/src/domain/entities/products_page.dart',
            '**/presentation/pages/**'),
        isFalse,
      );
    });
  });

  group('matchesAny', () {
    test('is true when any pattern matches', () {
      expect(matchesAny('lib/a.g.dart', ['**/*.freezed.dart', '**/*.g.dart']), isTrue);
    });

    test('is false when none match', () {
      expect(matchesAny('lib/a.dart', ['**/*.freezed.dart', '**/*.g.dart']), isFalse);
    });

    test('is false for an empty pattern list', () {
      expect(matchesAny('lib/a.dart', const []), isFalse);
    });
  });
}
