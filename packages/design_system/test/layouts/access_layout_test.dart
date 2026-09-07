import 'package:design_system/buttons/primary_button.dart';
import 'package:design_system/inputs/custom_text_input.dart';
import 'package:design_system/layouts/access_layout.dart';
import 'package:design_system/widgets/custom_text_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pumpLayout(
    WidgetTester tester, {
    bool isLoading = false,
    String? textInputError,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onBottomTextPressed,
  }) => pumpDs(
    tester,
    AccessLayout(
      title: 'Ingresar',
      textInputLabel: 'Email',
      controller: controller,
      primaryTextButton: 'Continuar',
      bottomText: 'Crear cuenta',
      isLoading: isLoading,
      textInputError: textInputError,
      onPrimaryButtonPressed: onPrimaryButtonPressed,
      onBottomTextPressed: onBottomTextPressed,
      onContinueWithGooglePressed: () {},
      onContinueWithApplePressed: () {},
    ),
  );

  testWidgets('renderiza titulo, campo y botones', (tester) async {
    await pumpLayout(tester);

    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('el boton primario dispara su callback', (tester) async {
    var taps = 0;
    await pumpLayout(tester, onPrimaryButtonPressed: () => taps++);

    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('el texto de abajo dispara su callback', (tester) async {
    var taps = 0;
    await pumpLayout(tester, onBottomTextPressed: () => taps++);

    await tester.tap(find.text('Crear cuenta'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('isLoading llega al boton primario', (tester) async {
    await pumpLayout(tester, isLoading: true, onPrimaryButtonPressed: () {});

    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).isLoading,
      isTrue,
    );
    expect(find.text('Continuar'), findsNothing);
  });

  testWidgets('el error del campo llega al CustomTextInput', (tester) async {
    await pumpLayout(tester, textInputError: 'Email invalido');

    expect(
      tester.widget<CustomTextInput>(find.byType(CustomTextInput)).error,
      'Email invalido',
    );
    expect(find.text('Email invalido'), findsOneWidget);
  });

  testWidgets('el campo usa teclado de email y comparte el controller', (
    tester,
  ) async {
    await pumpLayout(tester);

    final input = tester.widget<CustomTextInput>(find.byType(CustomTextInput));
    expect(input.textInputType, TextInputType.emailAddress);
    expect(input.controller, same(controller));

    await tester.enterText(find.byType(TextField), 'a@b.com');
    await tester.pump();

    expect(controller.text, 'a@b.com');
  });

  testWidgets('el bloque social esta oculto', (tester) async {
    // El `Visibility(visible: false)` envuelve el separador "OR" y los dos
    // botones de login social. Es una feature apagada, no codigo muerto: el
    // caso deja registrado que hoy no se muestra, para que reactivarla sea un
    // cambio deliberado y no un accidente de layout.
    await pumpLayout(tester);

    expect(find.text('OR'), findsNothing);
    expect(find.text('Continue with Google'), findsNothing);
    expect(find.text('Continue with Apple'), findsNothing);
    expect(
      tester.widget<Visibility>(find.byType(Visibility)).visible,
      isFalse,
    );
  });

  testWidgets('el separador no se construye mientras esta oculto', (
    tester,
  ) async {
    await pumpLayout(tester);
    expect(find.byType(CustomTextSeparator), findsNothing);
  });

  testWidgets('sin callbacks los botones quedan deshabilitados', (
    tester,
  ) async {
    await pumpLayout(tester);

    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
    );
  });
}
