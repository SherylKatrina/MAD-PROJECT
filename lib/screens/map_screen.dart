import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/live_image.dart';
import '../models/models.dart';
import '../services/marketplace_service.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  FoodBatch? _selectedBatch;

  @override
  Widget build(BuildContext context) {
    final liveBatches = ref.watch(buyerBatchesProvider);
    final stats = ref.watch(communityStatsProvider);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(13.0418, 80.2341), // Center T-Nagar
              initialZoom: 12.5,
              onTap: (_, __) => setState(() => _selectedBatch = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              
              // Community Pulse Dots (Simulated active neighborhoods)
              CircleLayer(
                circles: [
                  CircleMarker(point: const LatLng(13.0330, 80.2677), color: AppColors.primary.withValues(alpha: 0.1), borderStrokeWidth: 2, borderColor: AppColors.primary.withValues(alpha: 0.3), useRadiusInMeter: true, radius: 1000),
                  CircleMarker(point: const LatLng(12.9791, 80.2185), color: AppColors.accent.withValues(alpha: 0.1), borderStrokeWidth: 2, borderColor: AppColors.accent.withValues(alpha: 0.3), useRadiusInMeter: true, radius: 1200),
                ],
              ),

              MarkerLayer(
                markers: liveBatches.map((batch) {
                  final seller = ref.watch(sellerByIdProvider(batch.sellerId));
                  if (seller == null) return Marker(point: const LatLng(0,0), child: const SizedBox.shrink());

                  return Marker(
                    point: seller.coordinates,
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedBatch = batch);
                        _mapController.move(seller.coordinates, 14.0);
                      },
                      child: _buildMarker(batch),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          _buildMapHeader(stats),
          _buildNeighborhoodFilter(),

          if (_selectedBatch != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _buildBatchPreview(_selectedBatch!),
            ),
            
          _buildMapControls(),
        ],
      ),
    );
  }

  Widget _buildMapHeader(Map<String, String> stats) {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: GlassCard(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: 24,
        child: Row(
          children: [
            _circleAction(Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hyperlocal Map', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${stats['fresh_drops']} Active Drops in Chennai', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.5)),
                ],
              ),
            ),
            _pulseDot(),
          ],
        ),
      ),
    );
  }

  Widget _buildNeighborhoodFilter() {
    return Positioned(
      top: 140,
      left: 20,
      right: 20,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('Mylapore', true),
            _filterChip('Adyar', false),
            _filterChip('Velachery', false),
            _filterChip('T-Nagar', false),
            _filterChip('Besant Nagar', false),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 16,
        opacity: isSelected ? 0.2 : 0.1,
        child: Text(label, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white70, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 20,
      bottom: 200,
      child: Column(
        children: [
          _mapControlBtn(Icons.add_rounded, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
          const SizedBox(height: 12),
          _mapControlBtn(Icons.remove_rounded, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
          const SizedBox(height: 12),
          _mapControlBtn(Icons.my_location_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _mapControlBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(width: 50, height: 50, borderRadius: 16, padding: EdgeInsets.zero, child: Icon(icon, color: Colors.white, size: 24)),
    );
  }

  Widget _pulseDot() {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat()).scale(end: const Offset(2, 2)).fadeOut();
  }

  Widget _circleAction(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 16)),
    );
  }

  Widget _buildMarker(FoodBatch batch) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary, 
            borderRadius: BorderRadius.circular(12), 
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 2)],
          ),
          child: Text('₹${batch.price.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        CustomPaint(
          size: const Size(20, 10),
          painter: TrianglePainter(color: AppColors.primary),
        ),
      ],
    ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -8, duration: 1500.ms, curve: Curves.easeInOut);
  }

  Widget _buildBatchPreview(FoodBatch batch) {
    final seller = ref.watch(sellerByIdProvider(batch.sellerId));
    if (seller == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/food/${batch.id}'),
      child: GlassCard(
        height: 130,
        padding: const EdgeInsets.all(16),
        borderRadius: 32,
        child: Row(
          children: [
            LiveImage(imageUrl: batch.imageUrl, width: 98, height: 98, borderRadius: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: batch.isVeg ? Colors.green : Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(batch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${seller.kitchenName} • ${seller.locality}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('${batch.quantityRemaining} servings left', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      Text(' ${batch.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 1, end: 0, curve: Curves.easeOutBack, duration: 500.ms),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
