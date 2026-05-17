import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/live_image.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final orders = ref.watch(orderProvider);
    final isSeller = user.currentMode == UserMode.seller;

    // Filter orders based on mode
    final relevantOrders = isSeller 
        ? orders.where((o) => o.sellerId == 's1').toList() // Demo seller ID
        : orders.where((o) => o.buyerId == user.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isSeller ? 'Incoming Requests' : 'Order Tracking', 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.history_rounded), onPressed: () {}),
        ],
      ),
      body: relevantOrders.isEmpty 
          ? _buildEmptyState(context, isSeller)
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: relevantOrders.length,
              itemBuilder: (context, index) {
                final order = relevantOrders[index];
                return _buildOrderCard(context, ref, order, isSeller);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSeller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                isSeller ? Icons.receipt_long_rounded : Icons.shopping_bag_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(duration: 2.seconds, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05)),
            const SizedBox(height: 32),
            Text(
              isSeller ? 'No Live Requests' : 'No Active Orders',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            Text(
              isSeller 
                  ? 'Your kitchen is active, but no one has placed an order yet. Share your kitchen link!' 
                  : 'Chennai home kitchens are cooking nearby. Place your first hyper-local order!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            GlowingButton(
              onPressed: () {
                if (isSeller) {
                  context.go('/profile');
                } else {
                  context.go('/');
                }
              },
              text: isSeller ? 'KITCHEN PROFILE' : 'EXPLORE KITCHENS',
              icon: isSeller ? Icons.storefront_rounded : Icons.explore_rounded,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, Order order, bool isSeller) {
    final batches = ref.watch(marketplaceProvider);
    final batch = batches.firstWhere(
      (b) => b.id == order.batchId,
      orElse: () => FoodBatch(
        id: order.batchId,
        sellerId: order.sellerId,
        name: 'Unknown Dish',
        description: '',
        price: order.totalAmount / (order.quantity > 0 ? order.quantity : 1),
        quantityRemaining: 0,
        totalQuantity: 0,
        expiryTime: DateTime.now(),
        ingredients: [],
        pickupTime: '15 mins',
      ),
    );

    final displayId = order.id.length >= 6 
        ? order.id.substring(order.id.length - 6) 
        : order.id;

    final seller = ref.watch(sellerByIdProvider(order.sellerId));
    final sellerName = seller?.kitchenName ?? 'Local Chef';
    final pickupAddress = seller?.address ?? 'Velachery, Chennai';

    final bool isLiveOrder = order.status != OrderStatus.completed && order.status != OrderStatus.cancelled;

    return GlassCard(
      borderRadius: 24,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('ID: $displayId', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                  if (isLiveOrder) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.redAccent, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          const Text('LIVE', style: TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .fadeIn(duration: 1.seconds),
                  ],
                ],
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              LiveImage(imageUrl: batch.imageUrl, width: 60, height: 60, borderRadius: 16),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Chef: $sellerName', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pickupAddress,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {}, // Open Chat
                icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary, size: 20),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Qty: ${order.quantity} • ₹${order.totalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              if (isLiveOrder)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('Ready in ${batch.pickupTime}', style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          if (isLiveOrder || order.status == OrderStatus.readyForPickup) ...[
            const SizedBox(height: 16),
            _buildActionSection(ref, order, isSeller),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSection(WidgetRef ref, Order order, bool isSeller) {
    if (isSeller) {
      if (order.status == OrderStatus.pending) {
        return Row(
          children: [
            Expanded(child: _miniButton('Decline', Colors.redAccent, () => ref.read(orderProvider.notifier).updateOrderStatus(order.id, OrderStatus.cancelled))),
            const SizedBox(width: 12),
            Expanded(child: _miniButton('Accept & Cook', AppColors.primary, () => ref.read(orderProvider.notifier).updateOrderStatus(order.id, OrderStatus.accepted))),
          ],
        );
      }
      if (order.status == OrderStatus.accepted) {
        return _miniButton('Pack Food', AppColors.accent, () => ref.read(orderProvider.notifier).updateOrderStatus(order.id, OrderStatus.preparing));
      }
      if (order.status == OrderStatus.preparing) {
        return _miniButton('Mark Ready', Colors.green, () => ref.read(orderProvider.notifier).updateOrderStatus(order.id, OrderStatus.readyForPickup));
      }
    } else {
      // Buyer view
      if (order.status == OrderStatus.readyForPickup) {
        return Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text('Food is ready! Head to seller address.', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            _miniButton('Confirm Pickup', Colors.green, () => ref.read(orderProvider.notifier).updateOrderStatus(order.id, OrderStatus.completed)),
          ],
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _miniButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String label;
    switch (status) {
      case OrderStatus.pending: color = Colors.orange; label = 'Order Placed'; break;
      case OrderStatus.accepted: color = Colors.blue; label = 'Cooking'; break;
      case OrderStatus.preparing: color = Colors.purple; label = 'Packed'; break;
      case OrderStatus.readyForPickup: color = Colors.green; label = 'Ready'; break;
      case OrderStatus.completed: color = Colors.grey; label = 'Delivered'; break;
      case OrderStatus.cancelled: color = Colors.red; label = 'Cancelled'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
