import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/live_image.dart';
import '../services/marketplace_service.dart';
import '../models/models.dart';

class FoodDetailScreen extends ConsumerWidget {
  final String foodId;

  const FoodDetailScreen({super.key, required this.foodId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(marketplaceProvider);
    final batch = batches.firstWhere((b) => b.id == foodId, orElse: () => batches.first);
    final seller = ref.watch(sellerByIdProvider(batch.sellerId));

    if (seller == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(batch, context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _vegBadge(batch.isVeg),
                              const SizedBox(width: 8),
                              _badgeChip('Fast Delivery', Icons.bolt_rounded, AppColors.primary),
                            ],
                          ),
                          _etaBadge('12 mins'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(batch.name, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, height: 1.1)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _ratingBadge(batch.rating),
                                    const SizedBox(width: 8),
                                    Text('${seller.reviewCount} Reviews', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    const SizedBox(width: 8),
                                    Text('• ${batch.totalQuantity - batch.quantityRemaining + 42} Neighbors Ordered', style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildPriceCard(batch.price),
                        ],
                      ).animate().fadeIn().slideY(begin: 0.1),
                      
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          _tag('Homemade'),
                          const SizedBox(width: 8),
                          _tag('Fresh Drop'),
                          const SizedBox(width: 8),
                          _tag('Velachery Local'),
                          const Spacer(),
                          const Icon(Icons.near_me_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          const Text('1.2 km away', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader('Chef\'s Note'),
                      Text(batch.description, style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6)),
                      
                      if (batch.homemadeNotes != null && batch.homemadeNotes!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                          child: Text('👨‍🍳 Tip: ${batch.homemadeNotes}', style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      _buildSellerCard(context, seller),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader('Safety & Trust'),
                      _buildTrustBadges(),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader('Pickup Information'),
                      _buildPickupDetails(seller, batch),
                      
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          _buildTopButtons(context),
          _buildBottomAction(context, ref, batch, seller),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(FoodBatch batch, BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'food_image_${batch.id}',
          child: LiveImage(imageUrl: batch.name, width: double.infinity, borderRadius: 0),
        ),
      ),
    );
  }

  Widget _buildTopButtons(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIcon(context, Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
          _circleIcon(context, Icons.share_rounded),
        ],
      ),
    );
  }

  Widget _circleIcon(BuildContext context, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        width: 48,
        height: 48,
        borderRadius: 24,
        padding: EdgeInsets.zero,
        child: Center(child: Icon(icon, color: Colors.white, size: 20)),
      ),
    );
  }

  Widget _buildPriceCard(double price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
      child: Column(
        children: [
          const Text('PER PORTION', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
          Text('₹${price.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSellerCard(BuildContext context, SellerProfile seller) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      child: Row(
        children: [
          InitialsAvatar(name: seller.kitchenName, size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seller.kitchenName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text('By ${seller.ownerName} • ${seller.locality}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 20),
        ],
      ),
    );
  }

  Widget _buildPickupDetails(SellerProfile seller, FoodBatch batch) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(
        children: [
          _infoRow(Icons.location_on_rounded, seller.address, 'Pickup Address'),
          const Divider(height: 32, color: Colors.white10),
          _infoRow(Icons.phone_android_rounded, seller.phoneNumber, 'Contact Chef'),
          const Divider(height: 32, color: Colors.white10),
          _infoRow(Icons.access_time_rounded, 'Ready in ${batch.pickupTime}', 'Preparation Time'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      children: [
        Expanded(child: _trustItem(Icons.clean_hands_rounded, 'Hygienic')),
        Expanded(child: _trustItem(Icons.verified_user_rounded, 'ID Verified')),
        Expanded(child: _trustItem(Icons.star_rounded, 'Top Chef')),
        Expanded(child: _trustItem(Icons.eco_rounded, 'Sustainable')),
      ],
    );
  }

  Widget _trustItem(IconData icon, String label) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle), child: Icon(icon, size: 20, color: AppColors.primary.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, WidgetRef ref, FoodBatch batch, SellerProfile seller) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.background.withValues(alpha: 0.0), AppColors.background.withValues(alpha: 0.95), AppColors.background])),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${batch.quantityRemaining} portions left', style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const Text('Hyper-Local Pickup', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: GlowingButton(
                onPressed: () {
                  final user = ref.read(userProfileProvider);
                  final newOrder = Order(
                    id: 'o${DateTime.now().millisecondsSinceEpoch}',
                    batchId: batch.id,
                    buyerId: user.id,
                    sellerId: seller.sellerId,
                    quantity: 1,
                    totalAmount: batch.price,
                    orderTime: DateTime.now(),
                    status: OrderStatus.pending,
                    pickupEta: batch.pickupTime,
                  );

                  ref.read(orderProvider.notifier).placeOrder(newOrder);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.flash_on_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Order for ${batch.name} placed successfully!'),
                        ],
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  context.go('/orders');
                },
                text: 'PLACE ORDER',
                icon: Icons.flash_on_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _etaBadge(String eta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 12),
          const SizedBox(width: 4),
          Text(eta, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _ratingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.withValues(alpha: 0.2))),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(rating.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _vegBadge(bool isVeg) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8), border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1)),
      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: isVeg ? Colors.green : Colors.red, shape: BoxShape.circle)),
    );
  }
}
