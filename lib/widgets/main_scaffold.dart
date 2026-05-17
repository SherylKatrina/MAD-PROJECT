import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/marketplace_service.dart';
import '../models/models.dart';
import 'post_food_modal.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final isSeller = user.currentMode == UserMode.seller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: navigationShell,
      ),
      bottomNavigationBar: _buildBottomNav(context, isSeller),
      floatingActionButton: _buildFAB(context, isSeller),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isSeller) {
    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.grid_view_rounded, 'Home', 0),
            _navItem(Icons.explore_outlined, 'Map', 1),
            const SizedBox(width: 48), // Space for FAB
            _navItem(Icons.receipt_long_outlined, 'Orders', 2),
            _navItem(Icons.person_2_outlined, 'Profile', 3),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, delay: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool active = navigationShell.currentIndex == index;
    return InkWell(
      onTap: () => _onTap(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ).animate(target: active ? 1 : 0)
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, bool isSeller) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isSeller) {
              PostFoodModal.show(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Join the community as a Seller to post food!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.accent,
                ),
              );
            }
          },
          customBorder: const CircleBorder(),
          child: Icon(isSeller ? Icons.add_rounded : Icons.flash_on_rounded, size: 30, color: Colors.white),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds);
  }
}
