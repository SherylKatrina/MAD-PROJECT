import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

// --- USER PROFILE ---
class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return UserProfile(
      id: 'u1',
      name: 'Catriona',
      location: 'Velachery, Chennai',
      currentMode: UserMode.buyer,
      itemsOrdered: 12,
      itemsSold: 24,
    );
  }

  void toggleMode() {
    state = state.copyWith(
      currentMode: state.currentMode == UserMode.buyer ? UserMode.seller : UserMode.buyer,
    );
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void incrementOrders() => state = state.copyWith(itemsOrdered: state.itemsOrdered + 1);
  void incrementSold() => state = state.copyWith(itemsSold: state.itemsSold + 1);
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(() => UserProfileNotifier());

// --- SELLER PROFILES ---
class SellerProfilesNotifier extends Notifier<List<SellerProfile>> {
  @override
  List<SellerProfile> build() {
    return MockData.sellers;
  }

  void setProfiles(List<SellerProfile> profiles) {
    state = profiles;
  }

  void updateOrAddProfile(SellerProfile profile) {
    final index = state.indexWhere((s) => s.sellerId == profile.sellerId);
    if (index != -1) {
      state = [...state]..[index] = profile;
    } else {
      state = [...state, profile];
    }
  }
}

final sellerProfilesProvider = NotifierProvider<SellerProfilesNotifier, List<SellerProfile>>(() => SellerProfilesNotifier());

final currentSellerProfileProvider = Provider<SellerProfile?>((ref) {
  final profiles = ref.watch(sellerProfilesProvider);
  if (profiles.isEmpty) return null;
  return profiles.firstWhere((p) => p.sellerId == 's1', orElse: () => profiles.first);
});

final sellerByIdProvider = Provider.family<SellerProfile?, String>((ref, id) {
  final profiles = ref.watch(sellerProfilesProvider);
  try {
    return profiles.firstWhere((p) => p.sellerId == id);
  } catch (_) {
    return null;
  }
});



// --- SERIALIZATION HELPERS ---
Map<String, dynamic> _commentToMap(Comment c) => {
  'id': c.id, 'userId': c.userId, 'userName': c.userName, 'text': c.text, 'timestamp': c.timestamp.toIso8601String(), 'rating': c.rating,
};
Comment _commentFromMap(Map<String, dynamic> m) => Comment(
  id: m['id'], userId: m['userId'], userName: m['userName'], text: m['text'], timestamp: DateTime.parse(m['timestamp']), rating: m['rating']?.toDouble(),
);

Map<String, dynamic> _batchToMap(FoodBatch b) => {
  'id': b.id, 'sellerId': b.sellerId, 'name': b.name, 'description': b.description, 'imageUrl': b.imageUrl, 'price': b.price,
  'quantityRemaining': b.quantityRemaining, 'totalQuantity': b.totalQuantity, 'expiryTime': b.expiryTime.toIso8601String(),
  'ingredients': b.ingredients, 'isLive': b.isLive, 'homemadeNotes': b.homemadeNotes, 'category': b.category, 'isVeg': b.isVeg,
  'isDeliveryAvailable': b.isDeliveryAvailable, 'rating': b.rating, 'pickupTime': b.pickupTime,
  'comments': b.comments.map((c) => _commentToMap(c)).toList(),
};

FoodBatch _batchFromMap(Map<String, dynamic> m) => FoodBatch(
  id: m['id'], sellerId: m['sellerId'], name: m['name'], description: m['description'], imageUrl: m['imageUrl'], price: (m['price'] as num).toDouble(),
  quantityRemaining: m['quantityRemaining'], totalQuantity: m['totalQuantity'], expiryTime: DateTime.parse(m['expiryTime']),
  ingredients: List<String>.from(m['ingredients'] ?? []), isLive: m['isLive'] ?? true, homemadeNotes: m['homemadeNotes'], category: m['category'],
  isVeg: m['isVeg'] ?? true, isDeliveryAvailable: m['isDeliveryAvailable'] ?? false, rating: (m['rating'] as num).toDouble(), pickupTime: m['pickupTime'],
  comments: (m['comments'] as List?)?.map((c) => _commentFromMap(Map<String, dynamic>.from(c))).toList() ?? [],
);

// --- MARKETPLACE ---
class MarketplaceNotifier extends Notifier<List<FoodBatch>> {
  @override
  List<FoodBatch> build() {
    List<FoodBatch> userUploadedBatches = [];
    final box = Hive.box('marketplace');
    
    try {
      final String? storedJson = box.get('user_uploaded_batches_json');
      if (storedJson != null && storedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(storedJson);
        userUploadedBatches = decoded.map((m) => _batchFromMap(Map<String, dynamic>.from(m))).toList();
      }
    } catch (e) {
      print('DEBUG: HIVE READ ERROR $e');
    }
    
    final timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state.isEmpty) return;
      final random = Random();
      final indexToUpdate = random.nextInt(state.length);
      final batch = state[indexToUpdate];
      if (batch.quantityRemaining > 0) {
        updateStock(batch.id, -1);
      }
    });
    ref.onDispose(timer.cancel);

    // HYBRID FEED: Uploaded items first, then static mock data
    return [...userUploadedBatches, ...MockData.foodBatches];
  }

  void _persistUserBatches() {
    // ONLY save user-uploaded batches, never mock data
    final mockIds = MockData.foodBatches.map((b) => b.id).toSet();
    final userBatches = state.where((b) => !mockIds.contains(b.id)).toList();
    
    try {
      final box = Hive.box('marketplace');
      final jsonList = userBatches.map((b) => _batchToMap(b)).toList();
      box.put('user_uploaded_batches_json', jsonEncode(jsonList));
    } catch (e) {
      print('DEBUG: FAILED TO PERSIST USER BATCHES TO HIVE $e');
    }
  }

  void setBatches(List<FoodBatch> batches) {
    state = batches;
    _persistUserBatches();
  }

  void addBatch(FoodBatch batch, SellerProfile seller) {
    // Add to top of state
    state = [batch, ...state];
    _persistUserBatches();
    
    ref.read(sellerProfilesProvider.notifier).updateOrAddProfile(seller);
    
    ref.read(notificationProvider.notifier).addNotification(
      AppNotification(
        id: DateTime.now().toString(),
        title: 'New Kitchen Live!',
        body: '${seller.kitchenName} just dropped ${batch.name} in ${seller.locality}',
        timestamp: DateTime.now(),
        type: 'drop',
      ),
    );
  }

  void updateStock(String id, int change) {
    state = state.map((b) {
      if (b.id == id) {
        final newQty = b.quantityRemaining + change;
        return b.copyWith(quantityRemaining: newQty < 0 ? 0 : newQty);
      }
      return b;
    }).toList();
    _persistUserBatches();
  }

  void toggleLive(String id, bool isLive) {
    state = state.map((b) => b.id == id ? b.copyWith(isLive: isLive) : b).toList();
    _persistUserBatches();
  }
}

final marketplaceProvider = NotifierProvider<MarketplaceNotifier, List<FoodBatch>>(() => MarketplaceNotifier());

// --- ORDER SERIALIZATION HELPERS ---
Map<String, dynamic> _orderToMap(Order o) => {
  'id': o.id,
  'batchId': o.batchId,
  'buyerId': o.buyerId,
  'sellerId': o.sellerId,
  'quantity': o.quantity,
  'totalAmount': o.totalAmount,
  'orderTime': o.orderTime.toIso8601String(),
  'status': o.status.index,
  'pickupEta': o.pickupEta,
};

Order _orderFromMap(Map<String, dynamic> m) => Order(
  id: m['id'],
  batchId: m['batchId'],
  buyerId: m['buyerId'],
  sellerId: m['sellerId'],
  quantity: m['quantity'],
  totalAmount: (m['totalAmount'] as num).toDouble(),
  orderTime: DateTime.parse(m['orderTime']),
  status: OrderStatus.values[m['status'] ?? 0],
  pickupEta: m['pickupEta'],
);

// --- ORDERS ---
class OrderNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    List<Order> userUploadedOrders = [];
    final box = Hive.box('marketplace');
    
    try {
      final String? storedJson = box.get('user_orders_json');
      if (storedJson != null && storedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(storedJson);
        userUploadedOrders = decoded.map((m) => _orderFromMap(Map<String, dynamic>.from(m))).toList();
      }
    } catch (e) {
      print('DEBUG: HIVE ORDER READ ERROR $e');
    }

    final sampleOrders = [
      Order(
        id: 'o101',
        batchId: 'b1',
        buyerId: 'u1',
        sellerId: 's1',
        quantity: 2,
        totalAmount: 120,
        orderTime: DateTime.now().subtract(const Duration(days: 1)),
        status: OrderStatus.completed,
      ),
      Order(
        id: 'o102',
        batchId: 'b2',
        buyerId: 'u1',
        sellerId: 's2',
        quantity: 1,
        totalAmount: 150,
        orderTime: DateTime.now().subtract(const Duration(hours: 5)),
        status: OrderStatus.readyForPickup,
      ),
      Order(
        id: 'o103',
        batchId: 'b3',
        buyerId: 'u1',
        sellerId: 's4',
        quantity: 1,
        totalAmount: 120,
        orderTime: DateTime.now().subtract(const Duration(minutes: 45)),
        status: OrderStatus.accepted,
      ),
      Order(
        id: 'o104',
        batchId: 'b4',
        buyerId: 'u1',
        sellerId: 's10',
        quantity: 3,
        totalAmount: 300,
        orderTime: DateTime.now().subtract(const Duration(minutes: 15)),
        status: OrderStatus.preparing,
      ),
      Order(
        id: 'o105',
        batchId: 'b5',
        buyerId: 'u1',
        sellerId: 's10',
        quantity: 2,
        totalAmount: 80,
        orderTime: DateTime.now().subtract(const Duration(minutes: 5)),
        status: OrderStatus.pending,
      ),
    ];

    return [...userUploadedOrders, ...sampleOrders];
  }

  void _persistUserOrders() {
    final sampleIds = {'o101', 'o102', 'o103', 'o104', 'o105'};
    final userOrders = state.where((o) => !sampleIds.contains(o.id)).toList();
    
    try {
      final box = Hive.box('marketplace');
      final jsonList = userOrders.map((o) => _orderToMap(o)).toList();
      box.put('user_orders_json', jsonEncode(jsonList));
    } catch (e) {
      print('DEBUG: FAILED TO PERSIST ORDERS TO HIVE $e');
    }
  }

  void placeOrder(Order order) {
    state = [order, ...state];
    ref.read(marketplaceProvider.notifier).updateStock(order.batchId, -order.quantity);
    ref.read(userProfileProvider.notifier).incrementOrders();
    _persistUserOrders();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    state = state.map((o) => o.id == orderId ? o.copyWith(status: status) : o).toList();
    _persistUserOrders();
  }
}

final orderProvider = NotifierProvider<OrderNotifier, List<Order>>(() => OrderNotifier());

// --- NOTIFICATIONS ---
class NotificationNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    return [
      AppNotification(
        id: 'n1',
        title: 'Welcome Back, Catriona!',
        body: '3 new home kitchens just went live in Velachery.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        type: 'info',
      ),
      AppNotification(
        id: 'n2',
        title: 'Order Ready!',
        body: 'Your brownies from Velachery Brownie House are ready for pickup.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'status',
      ),
    ];
  }

  void addNotification(AppNotification n) => state = [n, ...state];
  void markAllRead() => state = state.map((n) => AppNotification(id: n.id, title: n.title, body: n.body, timestamp: n.timestamp, isRead: true, type: n.type)).toList();
}

final notificationProvider = NotifierProvider<NotificationNotifier, List<AppNotification>>(() => NotificationNotifier());

// --- REALTIME FEED ---
final homeFeedProvider = StreamProvider<String>((ref) async* {
  final updates = [
    '🔥 Lakshmi\'s Kitchen just cooked fresh Mini Idli',
    '🥘 Aunty Priya\'s Bakery dropped Hot Brownies in Besant Nagar',
    '⏳ Only 2 portions of Kari Dosa left at Amma Samayal!',
    '🍰 A new homemade cake batch just dropped',
    '🥟 5 neighbors just ordered from Velachery Idli Spot',
    '🥤 Fresh Filter Coffee ready near Velachery',
    '✨ Adyar Snacks House is LIVE',
    '🚨 Midnight Dosa Corner is selling out fast!',
    '🏡 Kitchen active nearby in Mylapore',
  ];
  int i = 0;
  while (true) {
    await Future.delayed(const Duration(seconds: 4));
    yield updates[i % updates.length];
    i++;
  }
});

// --- ANALYTICS (POLISH) ---
final communityStatsProvider = Provider((ref) => {
  'live_kitchens': '42',
  'fresh_drops': '158',
  'active_buyers': '1.2k',
  'total_impact': 'Hyperlocal',
});

// --- HELPER PROVIDERS ---
final sellerBatchesProvider = Provider<List<FoodBatch>>((ref) {
  final batches = ref.watch(marketplaceProvider);
  return batches.where((b) => b.sellerId == 's1').toList();
});

final buyerBatchesProvider = Provider<List<FoodBatch>>((ref) {
  final batches = ref.watch(marketplaceProvider);
  return batches.where((b) => b.isLive && b.quantityRemaining > 0).toList();
});
