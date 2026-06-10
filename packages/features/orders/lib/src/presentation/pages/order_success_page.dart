import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({required this.orderId, super.key});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: SwColors.yellowSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.check, color: SwColors.yellowDark, size: 44),
                ),
              ),
              const SizedBox(height: 20),
              Center(child: Text('¡Pedido creado!', style: SwText.display(size: 26))),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tu pedido fue registrado. Te avisamos cuando esté en camino.',
                  textAlign: TextAlign.center,
                  style: SwText.body(size: 14, color: SwColors.text3),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SwColors.white,
                  border: Border.all(color: SwColors.border),
                  borderRadius: BorderRadius.circular(SwRadii.card),
                  boxShadow: SwShadows.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: SwColors.yellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_long_outlined, color: SwColors.text, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('N° de pedido', style: SwText.body(size: 12, color: SwColors.text3)),
                          const SizedBox(height: 2),
                          Text(orderId, style: SwText.mono(size: 16, color: SwColors.text, letterSpacing: 0.08)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SwButton(
                label: 'Volver al catálogo',
                onPressed: () => Injector.i.resolve<NavigationHelper>().pushNamed(
                      context,
                      routeName: Routes.catalog,
                      replace: true,
                    ),
              ),
              const SizedBox(height: 10),
              SwButton(
                label: 'Ver mis pedidos',
                variant: SwButtonVariant.secondary,
                onPressed: () => Injector.i.resolve<NavigationHelper>().pushNamed(
                  context,
                  routeName: Routes.orders,
                  replace: true,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
