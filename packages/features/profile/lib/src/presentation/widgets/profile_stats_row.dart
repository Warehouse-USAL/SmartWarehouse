import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/domain/entities/profile_user.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({required this.user, super.key});

  final ProfileUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'ÓRDENES ABIERTAS',
            value: user.openOrdersCount.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'GASTADO ESTE MES',
            value: user.formattedSpent,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SwCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: SwText.mono(size: 10, color: SwColors.text3),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: SwText.display(size: 22),
          ),
        ],
      ),
    );
  }
}
