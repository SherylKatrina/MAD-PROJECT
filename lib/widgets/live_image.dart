import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/premium_widgets.dart';

class LiveImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;

  const LiveImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 24,
  });

  String _getFoodUrl(String? name) {
    if (name == null) return '';
    final String clean = name.toLowerCase();
    
    if (clean.contains('dosa')) {
      return 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&q=80&w=600';
    }
    if (clean.contains('idli')) {
      return 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&q=80&w=600';
    }
    if (clean.contains('biryani') || clean.contains('pulav') || clean.contains('rice') || clean.contains('meal')) {
      return 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?auto=format&fit=crop&q=80&w=600';
    }
    if (clean.contains('brownie') || clean.contains('chocolate') || clean.contains('fudge')) {
      return 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&q=80&w=600';
    }
    if (clean.contains('coffee') || clean.contains('tea') || clean.contains('filter')) {
      return 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&q=80&w=600';
    }
    if (clean.contains('parotta') || clean.contains('roti') || clean.contains('bread') || clean.contains('naan')) {
      return 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?auto=format&fit=crop&q=80&w=600';
    }
    if (clean.contains('paniyaram') || clean.contains('appam') || clean.contains('samosa') || clean.contains('snack')) {
      return 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?auto=format&fit=crop&q=80&w=600';
    }
    if (clean.contains('cake') || clean.contains('cupcake') || clean.contains('pastry') || clean.contains('bake')) {
      return 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&q=80&w=600';
    }
    if (clean.contains('jigarthanda') || clean.contains('shake') || clean.contains('juice') || clean.contains('lassi') || clean.contains('drink')) {
      return 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&q=80&w=600';
    }
    
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final String foodUrl = _getFoodUrl(imageUrl);
    
    if (foodUrl.isEmpty) {
      return PremiumPatternBox(
        seed: imageUrl ?? 'default',
        width: width,
        height: height,
        borderRadius: borderRadius,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: foodUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            width: width,
            height: height,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => PremiumPatternBox(
          seed: imageUrl ?? 'default',
          width: width,
          height: height,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
