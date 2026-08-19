/// Configuración de los tests e2e, inyectable vía --dart-define.
///
/// Defaults alineados al seed del backend local (ver scripts/*.py).
abstract final class E2eConfig {
  static const email = String.fromEnvironment(
    'E2E_EMAIL',
    defaultValue: 'admin@smartwarehouse.local',
  );

  static const password = String.fromEnvironment(
    'E2E_PASSWORD',
    defaultValue: 'changeme',
  );

  static const invalidEmail = 'nadie@smartwarehouse.local';
  static const invalidPassword = 'incorrecta123';
}
