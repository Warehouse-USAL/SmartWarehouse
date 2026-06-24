import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/domain/entities/user_address.dart';

/// Card que muestra la dirección guardada en el back y abre la edit page al tap.
///
/// El back es source of truth — la edición vive en /profile/edit y se persiste
/// con `PATCH /users/me`.
class AddressSection extends StatelessWidget {
  const AddressSection({required this.address, super.key});

  final UserAddress? address;

  @override
  Widget build(BuildContext context) {
    return SwCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18, color: SwColors.text2),
              const SizedBox(width: 8),
              Text(
                'DIRECCIÓN DE ENTREGA',
                style: SwText.mono(size: 11, color: SwColors.text3),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Injector.i
                    .resolve<NavigationHelper>()
                    .pushNamed(context, routeName: Routes.profileEditAddress),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  address == null ? 'Configurar' : 'Editar',
                  style: SwText.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: SwColors.link,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (address == null)
            Text(
              'Configurá tu dirección para que se autocomplete al crear órdenes.',
              style: SwText.body(size: 13, color: SwColors.text3, height: 1.4),
            )
          else ...[
            Text(address!.street, style: SwText.display(size: 17)),
            const SizedBox(height: 4),
            Text(
              _details(address!),
              style: SwText.body(size: 13, color: SwColors.text2, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  String _details(UserAddress a) {
    final parts = <String>[];
    if (a.department != null && a.department!.trim().isNotEmpty) {
      parts.add('Dpto ${a.department!}');
    }
    if (a.floor != null && a.floor!.trim().isNotEmpty) {
      parts.add('Piso ${a.floor!}');
    }
    parts.add('CP ${a.postalCode}');
    return parts.join(' · ');
  }
}
