import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/models.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class PostFoodModal extends ConsumerStatefulWidget {
  const PostFoodModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PostFoodModal(),
    );
  }

  @override
  ConsumerState<PostFoodModal> createState() => _PostFoodModalState();
}

class _PostFoodModalState extends ConsumerState<PostFoodModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Kitchen Details
  final _kitchenNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _localityController = TextEditingController();
  
  // Food Details
  final _foodNameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isVeg = true;
  bool _isDelivery = false;
  String _pickupTime = '15-20 mins';

  @override
  void initState() {
    super.initState();
    // Pre-populate with existing profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentSellerProfileProvider);
      if (profile != null) {
        _kitchenNameController.text = profile.kitchenName;
        _ownerNameController.text = profile.ownerName;
        _phoneController.text = profile.phoneNumber;
        _addressController.text = profile.address;
        _localityController.text = profile.locality;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Kitchen Identity'),
                    const SizedBox(height: 16),
                    _buildTextField(_kitchenNameController, 'Kitchen Name (e.g. Kate\'s Bakes)', Icons.storefront_rounded),
                    const SizedBox(height: 12),
                    _buildTextField(_ownerNameController, 'Your Name (Chef Name)', Icons.person_outline_rounded),
                    const SizedBox(height: 12),
                    _buildTextField(_phoneController, 'Phone Number (Real Contact)', Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    _buildTextField(_localityController, 'Locality (e.g. Velachery)', Icons.map_outlined),
                    const SizedBox(height: 12),
                    _buildTextField(_addressController, 'Exact Pickup Address', Icons.location_on_outlined, maxLines: 2),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle('Food Details'),
                    const SizedBox(height: 16),
                    _buildTextField(_foodNameController, 'What are you cooking?', Icons.restaurant_menu_rounded),
                    const SizedBox(height: 12),
                    _buildTextField(_descController, 'Description (Tastes like...)', Icons.description_outlined, maxLines: 2),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_priceController, 'Price (₹)', Icons.currency_rupee_rounded, keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_qtyController, 'Servings', Icons.inventory_2_outlined, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildToggles(),
                    const SizedBox(height: 24),
                    _buildTextField(_notesController, 'Homemade Notes (e.g. Less spicy)', Icons.edit_note_rounded),
                    
                    const SizedBox(height: 40),
                    GlowingButton(
                      onPressed: _submit,
                      text: 'GO LIVE NOW',
                      icon: Icons.flash_on_rounded,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Post Homemade Food', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5));
  }

  Widget _buildToggles() {
    return Row(
      children: [
        _toggleItem('Veg Only', _isVeg, (val) => setState(() => _isVeg = val)),
        const SizedBox(width: 12),
        _toggleItem('Delivery', _isDelivery, (val) => setState(() => _isDelivery = val)),
      ],
    );
  }

  Widget _toggleItem(String label, bool value, Function(bool) onChanged) {
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: value ? AppColors.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: value ? AppColors.primary : Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(value ? Icons.check_circle_rounded : Icons.circle_outlined, size: 16, color: value ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: value ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.7), size: 18),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final sellerId = 's1'; // Persistent seller ID for this user
      
      final sellerProfile = SellerProfile(
        sellerId: sellerId,
        kitchenName: _kitchenNameController.text,
        ownerName: _ownerNameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        locality: _localityController.text,
        profileInitials: _getInitials(_kitchenNameController.text),
        pickupTime: _pickupTime,
        coordinates: const LatLng(13.0827, 80.2707), // Default Chennai
        isSellerMode: true,
      );

      final newBatch = FoodBatch(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sellerId: sellerId,
        name: _foodNameController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        quantityRemaining: int.parse(_qtyController.text),
        totalQuantity: int.parse(_qtyController.text),
        expiryTime: DateTime.now().add(const Duration(hours: 6)),
        ingredients: ['Freshly Homemade'],
        homemadeNotes: _notesController.text,
        isVeg: _isVeg,
        isDeliveryAvailable: _isDelivery,
        category: 'Drop',
        pickupTime: _pickupTime,
      );

      ref.read(marketplaceProvider.notifier).addBatch(newBatch, sellerProfile);
      ref.read(userProfileProvider.notifier).toggleMode(); // Switch to seller mode to see it
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔥 ${_kitchenNameController.text} is now LIVE in ${_localityController.text}!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
