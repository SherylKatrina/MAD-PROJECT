import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/post_food_modal.dart';
import '../services/marketplace_service.dart';
import '../models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final sellerProfile = ref.watch(currentSellerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(context, user, sellerProfile),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildStatsGrid(user),
                  const SizedBox(height: 32),
                  _buildModeToggle(ref, user),
                  
                  if (user.currentMode == UserMode.seller) ...[
                    _buildSectionHeader('Kitchen Management'),
                    _settingsTile(Icons.storefront_rounded, 'My Kitchen Profile', trailing: 'Active', onTap: () => sellerProfile != null ? _showEditProfile(context, ref, sellerProfile) : null),
                    _settingsTile(Icons.insights_rounded, 'Sales Analytics', trailing: '₹12,450'),
                    _settingsTile(Icons.local_shipping_rounded, 'Pickup Locations', trailing: '2 Active'),
                    const SizedBox(height: 32),
                  ],

                  _buildSectionHeader('Community & Perks'),
                  _settingsTile(Icons.stars_rounded, 'Neighborhood Star Status', trailing: 'LVL 12', color: Colors.amber),
                  _settingsTile(Icons.favorite_rounded, 'Saved Home Kitchens', trailing: '8'),
                  _settingsTile(Icons.chat_bubble_rounded, 'Neighborhood Conversations', trailing: '3 New'),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Neighborhood Badges'),
                  _buildBadgesRow(),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Hyper-Local Settings'),
                  _settingsTile(Icons.location_on_rounded, 'Discovery Radius', trailing: '5 km'),
                  _settingsTile(Icons.notifications_active_rounded, 'Flash Drop Alerts'),
                  _settingsTile(Icons.verified_user_rounded, 'Identity Verification', trailing: 'Verified'),
                  _settingsTile(Icons.help_outline_rounded, 'Community Guidelines'),
                  
                  const SizedBox(height: 40),
                  _settingsTile(Icons.logout_rounded, 'Sign Out', color: Colors.redAccent),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile user, SellerProfile? seller) {
    return Container(
      height: 340,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Hero(
              tag: 'profile_avatar',
              child: InitialsAvatar(name: user.currentMode == UserMode.seller ? (seller?.kitchenName ?? user.name) : user.name, size: 100),
            ),
            const SizedBox(height: 20),
            Text(user.currentMode == UserMode.seller ? (seller?.kitchenName ?? 'New Kitchen') : user.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(user.currentMode == UserMode.seller ? '${seller?.locality ?? 'Chennai'}, India' : user.location, style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5)),
    );
  }

  Widget _buildStatsGrid(UserProfile user) {
    return Row(
      children: [
        Expanded(child: _statItem('Orders', user.itemsOrdered.toString())),
        Expanded(child: _statItem('Reviews', '42')),
        Expanded(child: _statItem('Community', 'Top 5%')),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildModeToggle(WidgetRef ref, UserProfile user) {
    final isSeller = user.currentMode == UserMode.seller;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      margin: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(isSeller ? Icons.storefront_rounded : Icons.shopping_bag_outlined, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isSeller ? 'Kitchen Dashboard' : 'Explore Mode', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(isSeller ? 'Switch to start buying' : 'Switch to post food', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: isSeller, 
            onChanged: (val) => ref.read(userProfileProvider.notifier).toggleMode(),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, {String? trailing, Color? color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: 24,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary, size: 22),
            const SizedBox(width: 20),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: color ?? Colors.white)),
            const Spacer(),
            if (trailing != null) 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: (color ?? AppColors.primary).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(trailing, style: TextStyle(color: color ?? AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            else const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildBadge('Neighborhood Star', Icons.star_rounded, Colors.amber),
          _buildBadge('Mylapore King', Icons.auto_awesome_rounded, AppColors.primary),
          _buildBadge('Filter Coffee Pro', Icons.coffee_rounded, Colors.brown),
          _buildBadge('Early Bird', Icons.sunny, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildBadge(String name, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(28), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32), 
          const SizedBox(height: 12), 
          Text(name, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, SellerProfile profile) {
    final nameController = TextEditingController(text: profile.kitchenName);
    final addressController = TextEditingController(text: profile.address);
    final phoneController = TextEditingController(text: profile.phoneNumber);
    final localityController = TextEditingController(text: profile.locality);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Edit Kitchen Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              _buildEditField(nameController, 'Kitchen Name', Icons.storefront_rounded),
              _buildEditField(localityController, 'Locality (e.g. Adyar)', Icons.map_rounded),
              _buildEditField(addressController, 'Pickup Address', Icons.location_on_rounded, maxLines: 2),
              _buildEditField(phoneController, 'Contact Phone', Icons.phone_android_rounded),
              const SizedBox(height: 40),
              GlowingButton(
                onPressed: () {
                  ref.read(sellerProfilesProvider.notifier).updateOrAddProfile(
                    profile.copyWith(
                      kitchenName: nameController.text,
                      address: addressController.text,
                      phoneNumber: phoneController.text,
                      locality: localityController.text,
                    ),
                  );
                  Navigator.pop(context);
                },
                text: 'SAVE CHANGES',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
