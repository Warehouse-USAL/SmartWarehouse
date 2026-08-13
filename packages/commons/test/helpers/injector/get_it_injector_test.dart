import 'package:commons/helpers/injector/get_it_injector.dart';
import 'package:commons/helpers/injector/injector.dart';
import 'package:flutter_test/flutter_test.dart';

class _Foo {
  _Foo(this.id);

  final int id;
}

class _Bar {
  const _Bar();
}

void main() {
  late Injector injector;

  setUp(() async {
    injector = GetItInjector();
    injector.clear();
    // See the note in the isRegistered/clear test below: clear() does not
    // wait for GetIt's async reset, so pump the event loop before the next
    // test's registrations run.
    await Future<void>.delayed(Duration.zero);
  });

  group('registerFactory / resolve', () {
    test('returns a new instance every resolve', () {
      var created = 0;
      injector.registerFactory<_Foo>(() {
        created++;
        return _Foo(created);
      });

      final first = injector.resolve<_Foo>();
      final second = injector.resolve<_Foo>();

      expect(first.id, 1);
      expect(second.id, 2);
      expect(identical(first, second), isFalse);
    });
  });

  group('registerSingleton / resolve', () {
    test('returns the same instance every resolve', () {
      final instance = _Foo(1);
      injector.registerSingleton<_Foo>(instance);

      expect(identical(injector.resolve<_Foo>(), instance), isTrue);
      expect(
        identical(injector.resolve<_Foo>(), injector.resolve<_Foo>()),
        isTrue,
      );
    });
  });

  group('registerLazySingleton', () {
    test('does not invoke the factory until first resolve, then caches it', () {
      var invocations = 0;
      injector.registerLazySingleton<_Foo>(() {
        invocations++;
        return _Foo(invocations);
      });

      expect(invocations, 0);

      final first = injector.resolve<_Foo>();
      expect(invocations, 1);

      final second = injector.resolve<_Foo>();
      expect(invocations, 1);
      expect(identical(first, second), isTrue);
    });
  });

  group('re-registration', () {
    test('registering an already-registered type replaces it instead of throwing', () {
      injector.registerSingleton<_Foo>(_Foo(1));

      expect(
        () => injector.registerSingleton<_Foo>(_Foo(2)),
        returnsNormally,
      );
      expect(injector.resolve<_Foo>().id, 2);
    });

    test('registering an already-registered factory replaces it instead of throwing', () {
      injector.registerFactory<_Foo>(() => _Foo(1));

      expect(
        () => injector.registerFactory<_Foo>(() => _Foo(2)),
        returnsNormally,
      );
      expect(injector.resolve<_Foo>().id, 2);
    });
  });

  group('registerFactoryByName / resolveByName', () {
    test('keeps two different names distinct', () {
      injector.registerFactoryByName<_Foo>(() => _Foo(1), 'a');
      injector.registerFactoryByName<_Foo>(() => _Foo(2), 'b');

      expect(injector.resolveByName<_Foo>('a').id, 1);
      expect(injector.resolveByName<_Foo>('b').id, 2);
    });
  });

  group('isRegistered', () {
    test('is true after register and false after clear', () async {
      injector.registerSingleton<_Foo>(_Foo(1));
      expect(injector.isRegistered<_Foo>(), isTrue);

      // `clear()` is declared `void` but delegates to GetIt's `reset()`,
      // which is `Future<void>` (it awaits each registration's dispose()
      // before clearing the registry) and whose Future `clear()` discards.
      // Immediately after calling `clear()`, GetIt has not necessarily
      // finished unregistering yet -- pump the event loop so pending
      // microtasks (the disposal chain) run before asserting.
      injector.clear();
      await Future<void>.delayed(Duration.zero);

      expect(injector.isRegistered<_Foo>(), isFalse);
    });
  });

  group('resolveOrNull / resolve', () {
    test('resolveOrNull returns null for an unregistered type while resolve throws', () {
      expect(injector.resolveOrNull<_Bar>(), isNull);
      expect(() => injector.resolve<_Bar>(), throwsException);
    });

    test('resolveOrNull returns the registered instance when present', () {
      final instance = _Foo(7);
      injector.registerSingleton<_Foo>(instance);

      expect(identical(injector.resolveOrNull<_Foo>(), instance), isTrue);
    });
  });

  group('async registration', () {
    test('registerLazySingletonAsync then resolveAsync resolves the value', () async {
      await injector.registerLazySingletonAsync<_Foo>(() async => _Foo(42));

      final result = await injector.resolveAsync<_Foo>();

      expect(result.id, 42);
    });

    test('resolveAsync with ifExist throws for an unregistered type', () {
      expect(
        injector.resolveAsync<_Bar>(ifExist: true),
        throwsException,
      );
    });
  });
}
