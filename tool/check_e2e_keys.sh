#!/usr/bin/env bash
# Consistencia de E2eKeys (job "E2E keys consistency" del CI de PRs).
#
# La dirección "un test usa una key inexistente" ya la atrapa el analyzer.
# Esta guarda cubre la inversa: si alguien elimina o renombra un widget en
# lib/ sin actualizar e2e_keys.dart y los tests, la key queda huérfana y el
# e2e nightly recién fallaría a la noche. Acá el PR falla en el momento.
set -uo pipefail

KEYS_FILE="packages/design_system/lib/testing/e2e_keys.dart"

# Aliases de conveniencia para los tests: en lib/ las keys de tabs se
# construyen con navTab(id), así que estos nombres solo aparecen en tests.
ALIASES="navCatalogTab navCartTab navOrdersTab navProfileTab"

NAMES=$(grep -oE 'static (const|Key) [a-zA-Z0-9_]+' "$KEYS_FILE" | awk '{print $3}' | sort -u)
FAIL=0

for name in $NAMES; do
  case " $ALIASES " in *" $name "*) continue;; esac
  if ! grep -rq "E2eKeys\.$name" lib packages/*/lib packages/*/*/lib 2>/dev/null; then
    echo "❌ E2eKeys.$name está declarada pero ningún widget en lib/ la usa."
    echo "   Si eliminaste o renombraste el elemento de UI, actualizá"
    echo "   e2e_keys.dart y el test de integration_test/ en este mismo PR."
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] && echo "✅ Todas las E2eKeys declaradas están referenciadas en el código de la app."
exit $FAIL
