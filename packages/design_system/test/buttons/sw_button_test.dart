import 'package:design_system/buttons/sw_button.dart';
import 'package:design_system/indicators/sw_loading_spinner.dart';
import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required List<int> taps,
    bool isLoading = false,
    bool disabled = false,
    SwButtonVariant variant = SwButtonVariant.primary,
    bool compact = false,
    IconData? icon,
  }) {
    return pumpDs(
      tester,
      SwButton(
        label: 'Guardar',
        onPressed: disabled ? null : () => taps.add(1),
        isLoading: isLoading,
        variant: variant,
        compact: compact,
        icon: icon,
      ),
    );
  }

  InkWell inkOf(WidgetTester tester) => tester.widget<InkWell>(
    find.descendant(of: find.byType(SwButton), matching: find.byType(InkWell)),
  );

  Material materialOf(WidgetTester tester) => tester.widget<Material>(
    find
        .descendant(
          of: find.byType(SwButton),
          matching: find.byType(Material),
        )
        .first,
  );

  double opacityOf(WidgetTester tester) => tester
      .widget<Opacity>(
        find.descendant(
          of: find.byType(SwButton),
          matching: find.byType(Opacity),
        ),
      )
      .opacity;

  group('onPressed', () {
    testWidgets('dispara el callback al tocarse', (tester) async {
      final taps = <int>[];
      await pumpButton(tester, taps: taps);

      await tester.tap(find.byType(SwButton));
      await tester.pump();

      expect(taps, hasLength(1));
    });

    testWidgets('null deshabilita el InkWell', (tester) async {
      await pumpButton(tester, disabled: true, taps: []);
      expect(inkOf(tester).onTap, isNull);
    });

    testWidgets('null baja la opacidad al 50%', (tester) async {
      await pumpButton(tester, disabled: true, taps: []);
      expect(opacityOf(tester), 0.5);
    });

    testWidgets('habilitado se renderiza opaco', (tester) async {
      await pumpButton(tester, taps: []);
      expect(opacityOf(tester), 1.0);
    });
  });

  group('isLoading', () {
    testWidgets('cambia el label por el spinner', (tester) async {
      await pumpButton(tester, isLoading: true, taps: []);

      expect(find.text('Guardar'), findsNothing);
      expect(find.byType(SwLoadingSpinner), findsOneWidget);
    });

    testWidgets('bloquea el tap aunque haya onPressed', (tester) async {
      // `disabled` es `onPressed == null || isLoading`. Un boton que sigue
      // aceptando taps mientras carga dispara la accion dos veces, que es el
      // bug clasico del doble submit.
      final taps = <int>[];
      await pumpButton(tester, isLoading: true, taps: taps);

      expect(inkOf(tester).onTap, isNull);

      await tester.tap(find.byType(SwButton), warnIfMissed: false);
      await tester.pump();

      expect(taps, isEmpty);
    });

    testWidgets('no baja la opacidad mientras carga', (tester) async {
      // La condicion es `disabled && !isLoading`: cargando el boton queda
      // deshabilitado pero se dibuja opaco, porque el spinner ya comunica el
      // estado. Atenuarlo ademas lo haria ilegible.
      await pumpButton(tester, isLoading: true, taps: []);
      expect(opacityOf(tester), 1.0);
    });
  });

  group('variantes', () {
    testWidgets('primary pinta el fondo amarillo de marca', (tester) async {
      await pumpButton(tester, taps: []);
      expect(materialOf(tester).color, SwColors.yellow);
    });

    testWidgets('secondary pinta blanco', (tester) async {
      await pumpButton(
        tester,
        variant: SwButtonVariant.secondary,
        taps: [],
      );
      expect(materialOf(tester).color, SwColors.white);
    });

    testWidgets('ghost es transparente', (tester) async {
      await pumpButton(tester, variant: SwButtonVariant.ghost, taps: []);
      expect(materialOf(tester).color, Colors.transparent);
    });

    testWidgets('solo secondary dibuja borde', (tester) async {
      // El borde vive en el `Container` interno, no en el Material: es lo que
      // separa visualmente la variante secundaria del fondo blanco de la
      // pantalla.
      BoxBorder? currentBorder() {
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(SwButton),
            matching: find.byType(Container),
          ),
        );
        return (container.decoration! as BoxDecoration).border;
      }

      await pumpButton(tester, variant: SwButtonVariant.secondary, taps: []);
      expect(currentBorder(), isNotNull);

      await pumpButton(tester, variant: SwButtonVariant.primary, taps: []);
      expect(currentBorder(), isNull);

      await pumpButton(tester, variant: SwButtonVariant.ghost, taps: []);
      expect(currentBorder(), isNull);
    });
  });

  group('icono', () {
    testWidgets('se renderiza cuando se pasa', (tester) async {
      await pumpButton(tester, icon: Icons.save, taps: []);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('desaparece mientras carga', (tester) async {
      await pumpButton(tester, icon: Icons.save, isLoading: true, taps: []);
      expect(find.byIcon(Icons.save), findsNothing);
    });

    testWidgets('no se renderiza ninguno si no se pasa', (tester) async {
      await pumpButton(tester, taps: []);
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('compact', () {
    double labelSizeOf(WidgetTester tester) => tester
        .widget<Text>(find.text('Guardar'))
        .style!
        .fontSize!;

    testWidgets('baja la tipografia a 14', (tester) async {
      await pumpButton(tester, compact: true, taps: []);
      expect(labelSizeOf(tester), 14);
    });

    testWidgets('el tamano normal es 16', (tester) async {
      await pumpButton(tester, taps: []);
      expect(labelSizeOf(tester), 16);
    });

    testWidgets('sigue disparando el callback', (tester) async {
      final taps = <int>[];
      await pumpButton(tester, compact: true, taps: taps);

      await tester.tap(find.byType(SwButton));
      await tester.pump();

      expect(taps, hasLength(1));
    });
  });
}
