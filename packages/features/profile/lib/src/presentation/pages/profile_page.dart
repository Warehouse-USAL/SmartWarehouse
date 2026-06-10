import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/src/presentation/bloc/profile_cubit.dart';
import 'package:profile/src/presentation/widgets/order_history_section.dart';
import 'package:profile/src/presentation/widgets/profile_header_card.dart';
import 'package:profile/src/presentation/widgets/profile_stats_row.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.cubit, super.key});

  final ProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit.state is! ProfileReady) {
      Future.microtask(cubit.load);
    }
    return Scaffold(
      backgroundColor: SwColors.surface,
      bottomNavigationBar: BottomNavigationBarFeatureBuilder.build(
        context,
        const NavigationBarOption.profile(),
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          bloc: cubit,
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError) {
              return _ErrorView(message: state.message, onRetry: cubit.load);
            }
            final ready = state as ProfileReady;
            return _ProfileContent(state: ready);
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.state});

  final ProfileReady state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _ProfileAppBar(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ProfileHeaderCard(user: state.user),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ProfileStatsRow(user: state.user),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: OrderHistorySection(orders: state.orders),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: SwButton(
              label: 'Cerrar sesión',
              variant: SwButtonVariant.secondary,
              icon: Icons.logout_rounded,
              onPressed: () => AuthFeatureBuilder.logout(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
            child: Center(
              child: Text(
                'SmartWarehouse · v2.6.0',
                style: SwText.body(size: 12, color: SwColors.text3),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Perfil',
            style: SwText.display(size: 26),
          ),
        ),
        SwIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Configuración',
          onPressed: () {},
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: SwColors.stockOut, size: 40),
          const SizedBox(height: 12),
          Text(message, style: SwText.body(size: 14)),
          const SizedBox(height: 16),
          SwButton(
            label: 'Reintentar',
            variant: SwButtonVariant.secondary,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
