## Qué cambia

<!-- resumen corto -->

## Checklist

- [ ] Los tests unitarios cubren el cambio (el gate de cobertura por paquete debe seguir verde).
- [ ] **Si toqué UI** (pages/widgets): las `E2eKeys` y los tests de `integration_test/` siguen siendo válidos — si renombré/eliminé un elemento con key, actualicé `e2e_keys.dart` y el test correspondiente en este mismo PR (el job "E2E keys consistency" lo verifica).
- [ ] Si cambié un contrato con el backend (DTOs/endpoints), lo verifiqué contra `docs/e2e-data-contract.md`.
