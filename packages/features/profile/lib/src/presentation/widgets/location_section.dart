import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/domain/entities/user_location.dart';
import 'package:profile/src/presentation/widgets/location_form_sheet.dart';

/// Card que muestra la ubicación guardada y permite editarla. Si no hay
/// ubicación, muestra empty state con CTA.
class LocationSection extends StatelessWidget {
  const LocationSection({
    required this.location,
    required this.onSave,
    super.key,
  });

  final UserLocation? location;
  final Future<void> Function(UserLocation) onSave;

  @override
  Widget build(BuildContext context) {
    return SwCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 18, color: SwColors.text2),
              const SizedBox(width: 8),
              Text(
                'MI UBICACIÓN',
                style: SwText.mono(size: 11, color: SwColors.text3),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _openSheet(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  location == null ? 'Configurar' : 'Editar',
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
          if (location == null)
            _EmptyState(onTap: () => _openSheet(context))
          else
            _Filled(location: location!),
        ],
      ),
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final result = await showModalBottomSheet<UserLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SwColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => LocationFormSheet(initial: location),
    );
    if (result != null) await onSave(result);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'Configurá tu bahía y dirección para que se autocompletten al crear órdenes.',
          style: SwText.body(size: 13, color: SwColors.text3, height: 1.4),
        ),
      ),
    );
  }
}

class _Filled extends StatelessWidget {
  const _Filled({required this.location});
  final UserLocation location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          location.destinationArea,
          style: SwText.display(size: 17),
        ),
        const SizedBox(height: 4),
        Text(
          location.summary,
          style: SwText.body(size: 13, color: SwColors.text2, height: 1.4),
        ),
      ],
    );
  }
}
