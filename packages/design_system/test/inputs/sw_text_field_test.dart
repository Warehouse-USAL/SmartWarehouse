import 'package:design_system/inputs/sw_text_field.dart';
import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pumpField(
    WidgetTester tester, {
    String? label,
    String? placeholder,
    String? error,
    bool obscure = false,
    Widget? prefix,
    Widget? suffix,
    Widget? trailingAction,
  }) => pumpDs(
    tester,
    SwTextField(
      controller: controller,
      label: label,
      placeholder: placeholder,
      error: error,
      obscure: obscure,
      prefix: prefix,
      suffix: suffix,
      trailingAction: trailingAction,
    ),
  );

  /// El color del borde vive en el `AnimatedContainer` que envuelve al
  /// `TextField`: es lo unico que comunica foco y error.
  Color borderColorOf(WidgetTester tester) {
    final box = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(SwTextField),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = box.decoration! as BoxDecoration;
    return (decoration.border! as Border).top.color;
  }

  List<BoxShadow> shadowOf(WidgetTester tester) {
    final box = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(SwTextField),
        matching: find.byType(AnimatedContainer),
      ),
    );
    return (box.decoration! as BoxDecoration).boxShadow ?? const <BoxShadow>[];
  }

  group('foco', () {
    testWidgets('en reposo el borde es el neutro', (tester) async {
      await pumpField(tester);
      expect(borderColorOf(tester), SwColors.border);
    });

    testWidgets('al enfocarse el borde pasa a amarillo oscuro', (tester) async {
      // El `FocusNode` propio con un listener que hace `setState` es toda la
      // logica del widget. Sin ese listener el borde nunca cambia y el campo
      // enfocado se ve igual que uno en reposo.
      await pumpField(tester);

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(borderColorOf(tester), SwColors.yellowDark);
    });

    testWidgets('enfocado agrega el anillo amarillo', (tester) async {
      await pumpField(tester);
      expect(shadowOf(tester), isEmpty);

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(shadowOf(tester), hasLength(1));
    });
  });

  group('error', () {
    testWidgets('renderiza el mensaje debajo del campo', (tester) async {
      await pumpField(tester, error: 'Email invalido');
      expect(find.text('Email invalido'), findsOneWidget);
    });

    testWidgets('un error vacio no cuenta como error', (tester) async {
      // La condicion es `error != null && error!.isNotEmpty`. Un cubit que
      // emite '' para "sin error" no debe pintar el campo de rojo.
      await pumpField(tester, error: '');

      expect(borderColorOf(tester), SwColors.border);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('el borde pasa a rojo', (tester) async {
      await pumpField(tester, error: 'Email invalido');
      expect(borderColorOf(tester), SwColors.stockOut);
    });

    testWidgets('el error le gana al foco', (tester) async {
      // El ternario evalua `hasError` primero. Si se invirtiera, un campo
      // enfocado con error se veria valido justo mientras lo corrigen.
      await pumpField(tester, error: 'Email invalido');

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(borderColorOf(tester), SwColors.stockOut);
    });

    testWidgets('con error no se dibuja el anillo de foco', (tester) async {
      await pumpField(tester, error: 'Email invalido');

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(shadowOf(tester), isEmpty);
    });
  });

  group('label y trailingAction', () {
    testWidgets('sin label ni accion no se monta la fila de arriba', (
      tester,
    ) async {
      await pumpField(tester);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('renderiza el label', (tester) async {
      await pumpField(tester, label: 'Email');
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renderiza la accion al costado', (tester) async {
      await pumpField(
        tester,
        label: 'Contrasena',
        trailingAction: const Text('Olvide mi contrasena'),
      );

      expect(find.text('Contrasena'), findsOneWidget);
      expect(find.text('Olvide mi contrasena'), findsOneWidget);
    });

    testWidgets('la accion sola tambien monta la fila', (tester) async {
      // La guarda es `label != null || trailingAction != null`, con un
      // `SizedBox.shrink` ocupando el lugar del label ausente para que la
      // accion quede a la derecha.
      await pumpField(tester, trailingAction: const Text('Ayuda'));

      expect(find.byType(Row), findsOneWidget);
      expect(find.text('Ayuda'), findsOneWidget);
    });
  });

  group('opciones del TextField', () {
    TextField fieldOf(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField));

    testWidgets('obscure propaga obscureText', (tester) async {
      await pumpField(tester, obscure: true);
      expect(fieldOf(tester).obscureText, isTrue);
    });

    testWidgets('por defecto el texto se ve', (tester) async {
      await pumpField(tester);
      expect(fieldOf(tester).obscureText, isFalse);
    });

    testWidgets('el placeholder viaja al hintText', (tester) async {
      await pumpField(tester, placeholder: 'nombre@empresa.com');
      expect(fieldOf(tester).decoration!.hintText, 'nombre@empresa.com');
    });

    testWidgets('sin prefix no se monta prefixIcon', (tester) async {
      await pumpField(tester);
      expect(fieldOf(tester).decoration!.prefixIcon, isNull);
    });

    testWidgets('el prefix se monta envuelto en su padding', (tester) async {
      await pumpField(tester, prefix: const Icon(Icons.search));
      expect(fieldOf(tester).decoration!.prefixIcon, isA<Padding>());
    });

    testWidgets('el suffix se monta tal cual', (tester) async {
      await pumpField(tester, suffix: const Icon(Icons.visibility));
      expect(fieldOf(tester).decoration!.suffixIcon, isA<Icon>());
    });

    testWidgets('escribir actualiza el controller', (tester) async {
      await pumpField(tester);

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.pump();

      expect(controller.text, 'hola');
    });
  });
}
