import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    // FORCE REMOVE ALL IMAGES AS PER REQUEST
    return PremiumPatternBox(
      seed: imageUrl ?? 'default',
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}
