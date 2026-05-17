import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../services/marketplace_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController(text: 'Catriona');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: _buildBlob(AppColors.primary, 300),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: _buildBlob(AppColors.accent, 250),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 34),
                  ).animate().fadeIn().slideX(begin: -0.2),
                  const SizedBox(height: 12),
                  Text(
                    'Join the freshest food community in Chennai.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 48),

                  // Glassmorphism Login Card
                  GlassCard(
                    padding: const EdgeInsets.all(28),
                    borderRadius: 32,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.primary,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                          unselectedLabelColor: AppColors.textSecondary,
                          tabs: const [
                            Tab(text: 'Login'),
                            Tab(text: 'Signup'),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Your Name', Icons.person_outline_rounded),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Email', Icons.email_outlined),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Password', Icons.lock_outline_rounded),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        GlowingButton(
                          onPressed: () {
                            ref.read(userProfileProvider.notifier).updateName(_nameController.text);
                            context.go('/');
                          },
                          text: 'Get Started',
                        ),
                        
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?', 
                            style: TextStyle(color: AppColors.primary.withValues(alpha: 0.8), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 48),
                  
                  // Social Logins
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'OR CONNECT WITH',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton(Icons.g_mobiledata_rounded, 'Google'),
                            const SizedBox(width: 16),
                            _socialButton(Icons.apple_rounded, 'Apple'),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 5.seconds)
     .blur(begin: const Offset(50, 50), end: const Offset(80, 80));
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.7), size: 20),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1),
      ),
    );
  }

  Widget _socialButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
        ],
      ),
    );
  }
}
