import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/live_image.dart';
import '../services/marketplace_service.dart';
import '../models/models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _HomeScreenContent();
  }
}

class _HomeScreenContent extends ConsumerStatefulWidget {
  const _HomeScreenContent();

  @override
  ConsumerState<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends ConsumerState<_HomeScreenContent> with TickerProviderStateMixin {
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);
    final isSeller = user.currentMode == UserMode.seller;

    return Scaffold(
      body: Stack(
        children: [
          // Live floating premium background lights
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _BackgroundAmbientPainter(
                    animationValue: _bgAnimationController.value,
                  ),
                );
              },
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, ref, user),
              if (isSeller) _buildSellerDashboard(context, ref)
              else _buildBuyerHome(context, ref, user),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, UserProfile user) {
    final sellerProfile = ref.watch(currentSellerProfileProvider);

    return SliverAppBar(
      expandedHeight: 140.0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.background.withOpacity(0.9),
      elevation: 0,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
          onPressed: () {},
        ),
        _buildActiveUsersCounter(),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Row(
          children: [
            InitialsAvatar(
              name: user.currentMode == UserMode.seller 
                  ? (sellerProfile?.kitchenName ?? user.name) 
                  : user.name, 
              size: 40,
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.currentMode == UserMode.seller 
                      ? (sellerProfile?.kitchenName ?? 'My Kitchen') 
                      : 'Namaste, ${user.name}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 10, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      user.currentMode == UserMode.seller 
                          ? (sellerProfile?.locality ?? 'Chennai') 
                          : user.location,
                      style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUsersCounter() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ).animate(onPlay: (c) => c.repeat()).scale(end: const Offset(1.5, 1.5)).fadeOut(),
          const SizedBox(width: 8),
          const Text('1.2k Live', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBuyerHome(BuildContext context, WidgetRef ref, UserProfile user) {
    final liveBatches = ref.watch(marketplaceProvider);
    final stats = ref.watch(communityStatsProvider);
    final sellers = ref.watch(sellerProfilesProvider);
    
    final freshNearYou = liveBatches.take(6).toList();
    final justCooked = liveBatches.skip(6).take(4).toList();
    final sellingFast = liveBatches.skip(10).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildLiveActivityTicker(ref),
        
        _buildHeroGreeting(user)
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOutBack),
            
        _buildDeliveryChips()
            .animate()
            .fadeIn(duration: 700.ms, delay: 100.ms)
            .slideX(begin: 0.1, end: 0),
            
        _buildCommunityStats(stats)
            .animate()
            .fadeIn(duration: 800.ms, delay: 200.ms)
            .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1), curve: Curves.easeOutBack),
        
        _buildSectionHeader('Fresh Near You', 'Picked for you in ${user.location.split(',').first}')
            .animate()
            .fadeIn(duration: 500.ms),
        _buildLiveBatchesCarousel(context, ref, freshNearYou),
        
        _buildCuisineCategories(),
        
        _buildSectionHeader('Just Cooked', 'Hot and ready for pickup'),
        _buildGridList(context, ref, justCooked),
        
        _buildSectionHeader('Selling Fast', 'Grab them before they run out!'),
        _buildLiveBatchesCarousel(context, ref, sellingFast),
        
        _buildSectionHeader('Trending in Chennai', 'Community Picks'),
        _buildTrendingList(context, ref, sellers),
        
        _buildSectionHeader('New Home Cooks', 'Just Joined'),
        _buildSimpleList(context, ref),
        
        const SizedBox(height: 120),
      ]),
    );
  }

  Widget _buildLiveActivityTicker(WidgetRef ref) {
    final update = ref.watch(homeFeedProvider);
    return update.when(
      data: (text) => Container(
        height: 36,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: AppColors.primary.withOpacity(0.05),
        child: Marquee(text: '🔔 $text  •  🔥 New Batch in Adyar  •  🥘 12 people just ordered Biryani'),
      ),
      loading: () => const SizedBox(height: 36),
      error: (_, __) => const SizedBox(height: 36),
    );
  }

  Widget _buildHeroGreeting(UserProfile user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.accent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 100,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'HYPER-LOCAL BATCHES',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Steaming Hot\nHomemade Meals',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Straight from your neighbor\'s kitchen to your table. Real ingredients, authentic recipes.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _badgeChip('Fast Delivery', Icons.bolt_rounded, AppColors.primary),
          _badgeChip('Top Rated', Icons.star_rounded, Colors.amber),
          _badgeChip('Pure Veg', Icons.eco_rounded, Colors.green),
          _badgeChip('Nearby', Icons.near_me_rounded, Colors.blueAccent),
          _badgeChip('New Drops', Icons.fiber_new_rounded, Colors.pinkAccent),
        ],
      ),
    );
  }

  Widget _badgeChip(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCommunityStats(Map<String, String> stats) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(child: _statBlock('Kitchens', stats['live_kitchens']!, Icons.restaurant_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _statBlock('Portions', '8.4k', Icons.local_fire_department_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _statBlock('Neighbors', stats['active_buyers']!, Icons.people_rounded)),
        ],
      ),
    );
  }

  Widget _statBlock(String label, String val, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary.withOpacity(0.5), size: 16),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildCuisineCategories() {
    final List<Map<String, dynamic>> cuisines = [
      {'name': 'Traditional', 'icon': Icons.rice_bowl_rounded, 'color': Colors.orangeAccent},
      {'name': 'Bakes', 'icon': Icons.cake_rounded, 'color': Colors.pinkAccent},
      {'name': 'Healthy', 'icon': Icons.eco_rounded, 'color': Colors.greenAccent},
      {'name': 'Continental', 'icon': Icons.restaurant_rounded, 'color': Colors.blueAccent},
      {'name': 'South Indian', 'icon': Icons.breakfast_dining_rounded, 'color': Colors.amberAccent},
      {'name': 'Street Food', 'icon': Icons.fastfood_rounded, 'color': Colors.redAccent},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Hyper-Local Cuisines',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: cuisines.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, dynamic> c = entry.value;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: c['color'].withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: c['color'].withOpacity(0.15), width: 1.5),
                        ),
                        child: Icon(c['icon'], color: c['color'], size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c['name'],
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ).animate()
                 .fadeIn(duration: 400.ms, delay: (index * 80).ms)
                 .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const Text('See All', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildLiveBatchesCarousel(BuildContext context, WidgetRef ref, List<FoodBatch> batches) {
    if (batches.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: batches.length,
        itemBuilder: (context, index) => _buildFoodCard(context, ref, batches[index])
            .animate()
            .fadeIn(duration: 500.ms, delay: (index * 100).ms)
            .slideX(begin: 0.15, end: 0, curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, WidgetRef ref, FoodBatch batch) {
    final seller = ref.watch(sellerByIdProvider(batch.sellerId));
    if (seller == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/food/${batch.id}'),
      child: Container(
        width: 290,
        margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'food_image_${batch.id}',
                      child: LiveImage(imageUrl: batch.name, height: 180, width: 290, borderRadius: 32),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16, 
                      left: 16, 
                      child: Row(
                        children: [
                          _vegBadge(batch.isVeg),
                          const SizedBox(width: 8),
                          _liveBadge(),
                        ],
                      ),
                    ),
                    Positioned(top: 16, right: 16, child: _etaBadge('${batch.pickupTime}')),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Text('₹${batch.price.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(batch.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          InitialsAvatar(name: seller.kitchenName, size: 24),
                          const SizedBox(width: 8),
                          Expanded(child: Text(seller.kitchenName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          Text(batch.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                          const SizedBox(width: 8),
                          Text('• ${batch.totalQuantity - batch.quantityRemaining} orders', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _tag('Homemade'),
                          const SizedBox(width: 8),
                          _tag('Fresh'),
                          const Spacer(),
                          const Icon(Icons.near_me_rounded, size: 10, color: AppColors.primary),
                          const SizedBox(width: 4),
                          const Text('1.2 km away', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(
       begin: const Offset(1, 1),
       end: const Offset(1.01, 1.01),
       duration: 3.seconds,
       curve: Curves.easeInOut,
     );
  }

  Widget _etaBadge(String eta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_filled_rounded, color: Colors.amber, size: 12),
          const SizedBox(width: 4),
          Text(eta, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.1));
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _vegBadge(bool isVeg) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8), border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1)),
      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: isVeg ? Colors.green : Colors.red, shape: BoxShape.circle)),
    );
  }

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ).animate(onPlay: (c) => c.repeat()).fadeOut(duration: 800.ms).scale(end: const Offset(1.8, 1.8)),
          const SizedBox(width: 4),
          const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1.2.seconds);
  }

  Widget _buildGridList(BuildContext context, WidgetRef ref, List<FoodBatch> batches) {
    if (batches.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        childAspectRatio: 0.75, 
        crossAxisSpacing: 16, 
        mainAxisSpacing: 16,
      ),
      itemCount: batches.length,
      itemBuilder: (context, index) => _buildGridCard(context, ref, batches[index])
          .animate()
          .fadeIn(duration: 500.ms, delay: (index * 80).ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildGridCard(BuildContext context, WidgetRef ref, FoodBatch batch) {
    return GestureDetector(
      onTap: () => context.push('/food/${batch.id}'),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'food_image_${batch.id}',
                    child: LiveImage(imageUrl: batch.name, width: double.infinity, borderRadius: 24),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _liveBadge(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(batch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('₹${batch.price.toInt()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 10),
                      Text(' ${batch.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingList(BuildContext context, WidgetRef ref, List<SellerProfile> sellers) {
    if (sellers.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: sellers.length,
      itemBuilder: (context, index) {
        final seller = sellers[index];
        return GlassCard(
          borderRadius: 24,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              InitialsAvatar(name: seller.kitchenName, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(seller.kitchenName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${seller.locality} • ${seller.reviewCount} reviews', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              _miniBadge('TOP', Colors.amber),
            ],
          ),
        ).animate()
         .fadeIn(duration: 500.ms, delay: (index * 80).ms)
         .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
      },
    );
  }

  Widget _buildSimpleList(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(marketplaceProvider);
    final allComments = batches.expand((b) => b.comments).toList();
    allComments.shuffle();
    final recentComments = allComments.take(3).toList();

    if (recentComments.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: recentComments.length,
      itemBuilder: (context, index) {
        final comment = recentComments[index];
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          child: Row(
            children: [
              InitialsAvatar(name: comment.userName, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${comment.userName} left a review', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('"${comment.text}"', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                      Text(comment.rating.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Just now', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ).animate()
         .fadeIn(duration: 500.ms, delay: (index * 80).ms)
         .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
      },
    );
  }

  Widget _miniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSellerDashboard(BuildContext context, WidgetRef ref) {
    final myBatches = ref.watch(sellerBatchesProvider);
    final profile = ref.watch(currentSellerProfileProvider);

    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('KITCHEN ANALYTICS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2)),
              const SizedBox(height: 12),
              Text(profile?.kitchenName ?? 'Initializing...', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
        _buildSellerStats()
            .animate()
            .fadeIn(duration: 600.ms, delay: 100.ms)
            .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1), curve: Curves.easeOutBack),
        _buildSectionHeader('Live Drops', 'Active in neighborhood'),
        ...myBatches.map((batch) => _buildSellerFoodItem(context, ref, batch)),
        const SizedBox(height: 120),
      ]),
    );
  }

  Widget _buildSellerStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _statBlock('Total Sales', '₹12,450', Icons.payments_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _statBlock('Portions', '420', Icons.check_circle_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _statBlock('Rating', '4.9/5', Icons.star_rounded)),
        ],
      ),
    );
  }

  Widget _buildSellerFoodItem(BuildContext context, WidgetRef ref, FoodBatch batch) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Row(
        children: [
          LiveImage(imageUrl: batch.name, width: 64, height: 64, borderRadius: 16),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(batch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${batch.quantityRemaining}/${batch.totalQuantity} servings available', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: batch.isLive, 
            onChanged: (val) => ref.read(marketplaceProvider.notifier).toggleLive(batch.id, val),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

// Custom Painter for warm flowing ambient background blur lights
class _BackgroundAmbientPainter extends CustomPainter {
  final double animationValue;

  _BackgroundAmbientPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    // Glowing purple light bubble shifting top right
    final double purpleX = size.width * 0.8 + (animationValue * 40 - 20);
    final double purpleY = size.height * 0.2 + (animationValue * 60 - 30);
    paint.color = AppColors.primary.withOpacity(0.08);
    canvas.drawCircle(Offset(purpleX, purpleY), 160, paint);

    // Glowing pink/accent light bubble shifting bottom left
    final double pinkX = size.width * 0.1 - (animationValue * 30 - 15);
    final double pinkY = size.height * 0.7 - (animationValue * 50 - 25);
    paint.color = AppColors.accent.withOpacity(0.06);
    canvas.drawCircle(Offset(pinkX, pinkY), 180, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundAmbientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Simple Marquee for Activity Ticker
class Marquee extends StatefulWidget {
  final String text;
  const Marquee({super.key, required this.text});
  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _animate());
  }

  void _animate() async {
    while (_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset + 1);
        if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40), 
          child: Text(
            widget.text, 
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
