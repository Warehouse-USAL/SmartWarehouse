import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/inputs/custom_text_input.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  TextFormField fieldOf(WidgetTester tester) =>
      tester.widget<TextFormField>(find.byType(TextFormField));

  TextStyle styleOf(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).style!;

  group('error', () {
    testWidgets('pinta el texto de rojo', (tester) async {
      await pumpDs(tester, const CustomTextInput(error: 'invalido'));
      expect(styleOf(tester).color, Colors.red);
    });

    testWidgets('sin error el color lo pone el token del tema', (tester) async {
      // `_getStyle` hace `copyWith(color: error == null ? null : Colors.red)`,
      // y `copyWith(color: null)` **no borra**: conserva el del estilo base.
      // Por eso el caso feliz no es "sin color", es "el color del f18W500".
      late CustomTextStyles styles;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            styles = CustomTextStyles.of(context);
            return const CustomTextInput();
          },
        ),
      );

      expect(styleOf(tester).color, styles.f18W500.value.color);
      expect(styleOf(tester).color, isNot(Colors.red));
    });

    testWidgets('el mensaje llega al decoration', (tester) async {
      await pumpDs(tester, const CustomTextInput(error: 'invalido'));
      expect(find.text('invalido'), findsOneWidget);
    });

    testWidgets('agranda el campo para que entre el mensaje', (tester) async {
      // 85 con error contra 56 sin el. Sin ese alto extra el mensaje queda
      // recortado y el usuario no ve por que no puede seguir.
      await pumpDs(tester, const CustomTextInput());
      final normal = tester.getSize(find.byType(CustomTextInput)).height;

      await pumpDs(tester, const CustomTextInput(error: 'invalido'));
      final withError = tester.getSize(find.byType(CustomTextInput)).height;

      expect(normal, 56);
      expect(withError, 85);
    });

    testWidgets('height explicito le gana al alto por error', (tester) async {
      await pumpDs(
        tester,
        const CustomTextInput(error: 'invalido', height: 120),
      );

      expect(tester.getSize(find.byType(CustomTextInput)).height, 120);
    });
  });

  group('formatters segun el keyboard', () {
    List<TextInputFormatter> formattersOf(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField)).inputFormatters!;

    testWidgets('number solo deja digitos', (tester) async {
      await pumpDs(
        tester,
        const CustomTextInput(textInputType: TextInputType.number),
      );

      expect(formattersOf(tester), hasLength(1));

      await tester.enterText(find.byType(TextField), 'a1b2c3');
      await tester.pump();

      expect(find.text('123'), findsOneWidget);
    });

    testWidgets('phone aplica la mascara 000 000 0000', (tester) async {
      await pumpDs(
        tester,
        const CustomTextInput(textInputType: TextInputType.phone),
      );

      expect(formattersOf(tester).single, isA<MaskedInputFormatter>());
    });

    testWidgets('sin textInputType no agrega ninguno', (tester) async {
      await pumpDs(tester, const CustomTextInput());
      expect(formattersOf(tester), isEmpty);
    });

    testWidgets('los formatters propios se suman a los del tipo', (
      tester,
    ) async {
      // El spread `...inputFormatters!` va **despues** de los del tipo: un
      // formatter propio ve el texto ya filtrado por digitsOnly.
      await pumpDs(
        tester,
        CustomTextInput(
          textInputType: TextInputType.number,
          inputFormatters: [PercentageFormatter()],
        ),
      );

      expect(formattersOf(tester), hasLength(2));
      expect(formattersOf(tester).last, isA<PercentageFormatter>());
    });

    testWidgets('name capitaliza cada palabra', (tester) async {
      await pumpDs(
        tester,
        const CustomTextInput(textInputType: TextInputType.name),
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).textCapitalization,
        TextCapitalization.words,
      );
    });

    testWidgets('los otros tipos no capitalizan', (tester) async {
      await pumpDs(
        tester,
        const CustomTextInput(textInputType: TextInputType.emailAddress),
      );

      expect(
        tester.widget<TextField>(find.byType(TextField)).textCapitalization,
        TextCapitalization.none,
      );
    });
  });

  group('iconos', () {
    testWidgets('sin prefixIcon ni prefix no monta nada adelante', (
      tester,
    ) async {
      await pumpDs(tester, const CustomTextInput());
      expect(
        tester.widget<TextField>(find.byType(TextField)).decoration!.prefixIcon,
        isNull,
      );
    });

    testWidgets('prefixIcon gana sobre prefix', (tester) async {
      // El ternario anidado chequea `prefixIcon` primero. Pasar los dos es
      // legal por firma, y esta es la unica forma de saber cual se dibuja.
      await pumpDs(
        tester,
        const CustomTextInput(
          prefixIcon: CustomIconData.emailOutline,
          prefix: Text('AR'),
        ),
      );

      expect(find.byType(CustomIcon), findsOneWidget);
      expect(find.text('AR'), findsNothing);
    });

    testWidgets('prefix solo se monta si no hay prefixIcon', (tester) async {
      await pumpDs(tester, const CustomTextInput(prefix: Text('AR')));

      expect(find.text('AR'), findsOneWidget);
      expect(find.byType(CustomIcon), findsNothing);
    });

    testWidgets('el suffix se monta cuando se pasa', (tester) async {
      await pumpDs(
        tester,
        const CustomTextInput(suffix: Icon(Icons.visibility)),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('estado y valor', () {
    testWidgets('disabled apaga el campo', (tester) async {
      await pumpDs(tester, const CustomTextInput(disabled: true));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('isObscured tapa el texto', (tester) async {
      await pumpDs(tester, const CustomTextInput(isObscured: true));
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isTrue,
      );
    });

    testWidgets('escribir actualiza el controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpDs(tester, CustomTextInput(controller: controller));

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.pump();

      expect(controller.text, 'hola');
    });

    testWidgets('onChanged nunca se llama: el parametro esta muerto', (
      tester,
    ) async {
      // **No es el comportamiento deseado, es el que hay.** `onChanged` se
      // declara en el constructor y en el campo, y no se cablea al
      // `TextFormField` en ningun lado (`grep onChanged` sobre el archivo da
      // dos hits, los dos declarativos). Un feature que lo pase no recibe
      // nada y el analyzer no dice una palabra.
      //
      // Se documenta en vez de arreglarse porque cablearlo cambia el
      // comportamiento de una API publica del design system, y este issue
      // (#169) es solo de tests. Cuando alguien lo conecte, este caso falla y
      // hay que borrarlo — que es exactamente la senal que se busca.
      final changes = <String?>[];
      await pumpDs(tester, CustomTextInput(onChanged: changes.add));

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.pump();

      expect(changes, isEmpty);
    });

    testWidgets('overrideController en false usa value como initialValue', (
      tester,
    ) async {
      // `initialValue: overrideController ? null : value`. Con el default en
      // true el valor inicial se ignora, porque manda el controller.
      await pumpDs(
        tester,
        const CustomTextInput(value: 'precargado', overrideController: false),
      );

      expect(find.text('precargado'), findsOneWidget);
    });

    testWidgets('con overrideController el value no se muestra', (
      tester,
    ) async {
      await pumpDs(tester, const CustomTextInput(value: 'precargado'));
      expect(find.text('precargado'), findsNothing);
    });

    testWidgets('multiline permite hasta 5 lineas', (tester) async {
      await pumpDs(tester, const CustomTextInput(multiline: true));
      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 5);
    });

    testWidgets('por defecto es de una linea', (tester) async {
      await pumpDs(tester, const CustomTextInput());
      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 1);
    });

    testWidgets('expands suelta el limite de lineas y de alto', (tester) async {
      await pumpDs(tester, const CustomTextInput(expands: true));
      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, isNull);
    });

    testWidgets('el contador de maxLength no se dibuja', (tester) async {
      // `buildCounter` devuelve null a proposito: el "0/10" de Material no
      // entra en el diseno. Es facil perderlo en un refactor del decoration.
      await pumpDs(tester, const CustomTextInput(maxLength: 10));

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();

      expect(find.text('3/10'), findsNothing);
    });

    testWidgets('el label llega al decoration', (tester) async {
      await pumpDs(tester, const CustomTextInput(label: 'Email'));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('el field se monta aunque no reciba nada', (tester) async {
      await pumpDs(tester, const CustomTextInput());
      expect(fieldOf(tester), isNotNull);
    });
  });

  // `PercentageFormatter` es logica pura y no toca el arbol: es el unico
  // archivo de este package que se puede testear con `test` a secas.
  group('PercentageFormatter', () {
    final formatter = PercentageFormatter();

    TextEditingValue format(String oldText, String newText) =>
        formatter.formatEditUpdate(
          TextEditingValue(text: oldText),
          TextEditingValue(text: newText),
        );

    test('agrega el % a un numero valido', () {
      expect(format('', '50').text, '50%');
    });

    test('acepta el 100 justo', () {
      // El limite es `<= 100`, no `< 100`: el 100% tiene que poder escribirse.
      expect(format('', '100').text, '100%');
    });

    test('rechaza arriba de 100 y deja el valor anterior', () {
      expect(format('99%', '101').text, '99%');
    });

    test('rechaza texto que no es numero', () {
      expect(format('50%', 'abc').text, '50%');
    });

    test('vaciar el campo lo deja vacio', () {
      // Sin esta rama, borrar el ultimo digito devolveria el valor viejo y el
      // campo quedaria imposible de limpiar.
      expect(format('50%', '').text, isEmpty);
    });

    test('no acumula % al reeditar', () {
      // Cada pasada empieza sacando los % que ya estaban: sin ese
      // `replaceAll`, tipear un 0 sobre "5%" produciria "5%0%" en vez de
      // "50%".
      expect(format('5%', '5%0').text, '50%');
    });

    test('el % viejo se saca antes de validar el limite', () {
      // Si el `replaceAll` corriera despues del `int.tryParse`, "50%1" no
      // parsearia y el formatter rechazaria una edicion valida.
      expect(format('5%', '5%1').text, '51%');
    });

    test('deja el cursor antes del %', () {
      // Si el cursor quedara al final, el proximo digito se escribiria
      // despues del simbolo y el parseo del texto fallaria.
      final result = format('', '50');
      expect(result.selection.baseOffset, result.text.length - 1);
      expect(result.text[result.selection.baseOffset], '%');
    });

    test('con el campo vacio el cursor queda en 0', () {
      final result = format('50%', '');
      expect(result.selection.baseOffset, 0);
    });
  });
}
