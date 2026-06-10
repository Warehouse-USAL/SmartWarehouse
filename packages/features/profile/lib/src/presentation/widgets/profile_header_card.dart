import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/domain/entities/profile_user.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({required this.user, super.key});

  final ProfileUser user;

  @override
  Widget build(BuildContext context) {
    return SwCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _Avatar(initials: user.avatarInitials),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: SwText.display(size: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: SwText.body(size: 13, color: SwColors.text3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _RoleBadge(role: user.role, bay: user.bay),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: SwColors.yellowSoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: SwText.display(size: 18, color: SwColors.yellowDark),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.bay});

  final String role;
  final String bay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: SwColors.yellowSoft,
        borderRadius: BorderRadius.circular(SwRadii.pill),
        border: Border.all(color: SwColors.yellowSoftAlt),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 13,
            color: SwColors.yellow,
          ),
          const SizedBox(width: 4),
          Text(
            '${role.toUpperCase()} · ${bay.toUpperCase()}',
            style: SwText.label(
              size: 11,
              color: SwColors.yellowDark,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
