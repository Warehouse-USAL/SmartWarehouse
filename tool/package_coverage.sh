#!/bin/sh
# Corre los tests de UN package con cobertura.
#
# `flutter test` devuelve 79 ("No tests were found") en packages que todavia no
# tienen tests propios. El archivo generado por gen_coverage_imports.dart igual
# instrumenta todo lib/, asi que el package cuenta 0% en el denominador y 79 es
# benigno. Cualquier otro codigo distinto de 0 es una falla real.
#
# Esto vive en un script y no inline en melos.yaml a proposito: `melos exec`
# reconstruye y evalua el comando, y su forma de agrupar comillas cambia entre
# versiones de melos. Un script no depende de eso.
flutter test --coverage --no-pub
code=$?
if [ "$code" -eq 0 ] || [ "$code" -eq 79 ]; then
  exit 0
fi
exit "$code"
