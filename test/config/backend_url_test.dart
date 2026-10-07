import 'package:flutter_test/flutter_test.dart';
import 'package:smart_warehouse/config/backend_url.dart';

void main() {
  final serverBase = Uri.parse('http://warehouse.local/mobile/app/');

  group('resolveBackendUrl', () {
    test('API_BASE_URL absoluta gana sobre todo', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: serverBase,
          fullOverride: 'https://api.example.com',
          hostOverride: '1.2.3.4',
        ),
        'https://api.example.com',
      );
    });

    test('API_HOST/API_PORT arma http://host:port', () {
      expect(
        resolveBackendUrl(
          isWeb: false,
          isAndroid: true,
          base: serverBase,
          hostOverride: '192.168.1.10',
          port: '9090',
        ),
        'http://192.168.1.10:9090',
      );
    });

    test('web en localhost conserva localhost:port (flutter run -d chrome)', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('http://localhost:54321/'),
        ),
        'http://localhost:8080',
      );
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('http://127.0.0.1:54321/'),
          port: '9000',
        ),
        'http://localhost:9000',
      );
    });

    test('web en otro host usa el origen de la página (mismo origen, sin CORS)', () {
      expect(
        resolveBackendUrl(isWeb: true, isAndroid: false, base: serverBase),
        'http://warehouse.local',
      );
    });

    test('web conserva el puerto del origen', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('http://192.168.0.10:8080/mobile/app/'),
        ),
        'http://192.168.0.10:8080',
      );
    });

    test('web con https devuelve origen https', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('https://warehouse.usal.edu/mobile/app/'),
        ),
        'https://warehouse.usal.edu',
      );
    });

    test('web con scheme no http cae a localhost sin lanzar', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('file:///Users/x/index.html'),
        ),
        'http://localhost:8080',
      );
    });

    test('Android emulator usa 10.0.2.2', () {
      expect(
        resolveBackendUrl(isWeb: false, isAndroid: true, base: serverBase),
        'http://10.0.2.2:8080',
      );
    });

    test('sameOrigin fuerza el origen en web aunque sea localhost (build para el proxy)', () {
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: Uri.parse('http://localhost:8088/mobile/app/'),
          sameOrigin: true,
        ),
        'http://localhost:8088',
      );
    });

    test('sameOrigin no afecta a Android ni a los overrides', () {
      expect(
        resolveBackendUrl(isWeb: false, isAndroid: true, base: serverBase, sameOrigin: true),
        'http://10.0.2.2:8080',
      );
      expect(
        resolveBackendUrl(
          isWeb: true,
          isAndroid: false,
          base: serverBase,
          sameOrigin: true,
          fullOverride: 'https://api.example.com',
        ),
        'https://api.example.com',
      );
    });

    test('iOS/desktop usa localhost', () {
      expect(
        resolveBackendUrl(isWeb: false, isAndroid: false, base: serverBase),
        'http://localhost:8080',
      );
    });
  });
}
