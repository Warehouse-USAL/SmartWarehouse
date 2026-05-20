import 'package:cart/src/domain/entities/cart.dart';
import 'package:flutter/material.dart';

class CreateOrderConfirmationDialog extends StatelessWidget {
  const CreateOrderConfirmationDialog({required this.cart, super.key});

  final Cart cart;

  static Future<bool> show(BuildContext context, Cart cart) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CreateOrderConfirmationDialog(cart: cart),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final total = cart.total;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Confirmar orden'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${cart.itemCount} ${cart.itemCount == 1 ? 'unidad' : 'unidades'}'),
          if (total != null) ...[
            const SizedBox(height: 4),
            Text(
              'Total: ${total.formatted}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            '¿Querés crear la orden con estos items?',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
