import 'package:cart/src/data/repositories/in_memory_cart_repository.dart';
import 'package:cart/src/presentation/bloc/cart_cubit.dart';
import 'package:cart/src/presentation/widgets/cart_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_support/test_support.dart';

void main() {
  testWidgets('renders only the child when the cart is empty', (tester) async {
    final cubit = CartCubit(InMemoryCartRepository());
    addTearDown(cubit.close);

    await tester.pumpWidget(MaterialApp(
      home: CartBadge(cubit: cubit, child: const Icon(Icons.shopping_cart)),
    ));

    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('shows the item count as a badge once the cart has items', (tester) async {
    final cubit = CartCubit(InMemoryCartRepository());
    addTearDown(cubit.close);

    await tester.pumpWidget(MaterialApp(
      home: CartBadge(cubit: cubit, child: const Icon(Icons.shopping_cart)),
    ));

    cubit.add(aProduct(id: 'p-1'), quantity: 3);
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('caps the badge at 99+', (tester) async {
    final cubit = CartCubit(InMemoryCartRepository());
    addTearDown(cubit.close);

    await tester.pumpWidget(MaterialApp(
      home: CartBadge(cubit: cubit, child: const Icon(Icons.shopping_cart)),
    ));

    cubit.add(aProduct(id: 'p-1'), quantity: 150);
    await tester.pump();

    expect(find.text('99+'), findsOneWidget);
  });
}
