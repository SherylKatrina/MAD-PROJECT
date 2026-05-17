import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Stack(
          children: [
            // Background particles (Animated)
            ...List.generate(15, (index) {
              return Positioned(
                left: (index * 50.0) % MediaQuery.of(context).size.width,
                top: (index * 80.0) % MediaQuery.of(context).size.height,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .moveY(begin: 0, end: -100, duration: (2000 + index * 100).ms, curve: Curves.easeInOut)
                .fadeOut(duration: (2000 + index * 100).ms);
            }),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ).animate()
                   .scale(duration: 800.ms, curve: Curves.elasticOut)
                   .shimmer(delay: 1.seconds, duration: 2.seconds),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'BatchLive',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      letterSpacing: 4,
                      fontSize: 40,
                    ),
                  ).animate()
                   .fadeIn(delay: 500.ms, duration: 800.ms)
                   .slideY(begin: 0.5, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'HYPER-LOCAL • FRESH • LIVE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ).animate()
                   .fadeIn(delay: 1200.ms, duration: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
