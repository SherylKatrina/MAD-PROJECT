import 'package:latlong2/latlong.dart';

enum UserMode { buyer, seller }

enum OrderStatus { pending, accepted, preparing, readyForPickup, completed, cancelled }

class FoodCategory {
  final String id;
  final String name;
  final String icon;

  const FoodCategory({required this.id, required this.name, required this.icon});
}

class SellerProfile {
  final String sellerId;
  final String kitchenName;
  final String ownerName;
  final String phoneNumber;
  final String address;
  final String locality;
  final String profileInitials;
  final String pickupTime;
  final String bio;
  final LatLng coordinates;
  bool isSellerMode;
  final double rating;
  final int reviewCount;

  SellerProfile({
    required this.sellerId,
    required this.kitchenName,
    required this.ownerName,
    required this.phoneNumber,
    required this.address,
    required this.locality,
    required this.profileInitials,
    required this.pickupTime,
    this.bio = 'Neighborhood Home Chef',
    required this.coordinates,
    this.isSellerMode = false,
    this.rating = 5.0,
    this.reviewCount = 0,
  });

  SellerProfile copyWith({
    String? kitchenName,
    String? ownerName,
    String? phoneNumber,
    String? address,
    String? locality,
    String? pickupTime,
    String? bio,
    bool? isSellerMode,
  }) {
    return SellerProfile(
      sellerId: sellerId,
      kitchenName: kitchenName ?? this.kitchenName,
      ownerName: ownerName ?? this.ownerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      locality: locality ?? this.locality,
      profileInitials: profileInitials,
      pickupTime: pickupTime ?? this.pickupTime,
      bio: bio ?? this.bio,
      coordinates: coordinates,
      isSellerMode: isSellerMode ?? this.isSellerMode,
      rating: rating,
      reviewCount: reviewCount,
    );
  }
}

class FoodBatch {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final String? imageUrl;
  final double price;
  int quantityRemaining;
  final int totalQuantity;
  DateTime expiryTime;
  final List<String> ingredients;
  bool isLive;
  final String? homemadeNotes;
  final String? category;
  final bool isVeg;
  final bool isDeliveryAvailable;
  final List<Comment> comments;
  final double rating;
  final String pickupTime; // Linked to listing state

  FoodBatch({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.price,
    required this.quantityRemaining,
    required this.totalQuantity,
    required this.expiryTime,
    required this.ingredients,
    this.isLive = true,
    this.homemadeNotes,
    this.category,
    this.isVeg = true,
    this.isDeliveryAvailable = false,
    this.comments = const [],
    this.rating = 5.0,
    required this.pickupTime,
  });

  FoodBatch copyWith({
    int? quantityRemaining,
    bool? isLive,
    List<Comment>? comments,
  }) {
    return FoodBatch(
      id: id,
      sellerId: sellerId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      quantityRemaining: quantityRemaining ?? this.quantityRemaining,
      totalQuantity: totalQuantity,
      expiryTime: expiryTime,
      ingredients: ingredients,
      isLive: isLive ?? this.isLive,
      homemadeNotes: homemadeNotes,
      category: category,
      isVeg: isVeg,
      isDeliveryAvailable: isDeliveryAvailable,
      comments: comments ?? this.comments,
      rating: rating,
      pickupTime: pickupTime,
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
  final double? rating;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    this.rating,
  });
}

class Order {
  final String id;
  final String batchId;
  final String buyerId;
  final String sellerId;
  final int quantity;
  final double totalAmount;
  final DateTime orderTime;
  final OrderStatus status;
  final String? pickupEta;

  Order({
    required this.id,
    required this.batchId,
    required this.buyerId,
    required this.sellerId,
    required this.quantity,
    required this.totalAmount,
    required this.orderTime,
    this.status = OrderStatus.pending,
    this.pickupEta,
  });

  Order copyWith({OrderStatus? status, String? pickupEta}) {
    return Order(
      id: id,
      batchId: batchId,
      buyerId: buyerId,
      sellerId: sellerId,
      quantity: quantity,
      totalAmount: totalAmount,
      orderTime: orderTime,
      status: status ?? this.status,
      pickupEta: pickupEta ?? this.pickupEta,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String location;
  final String? avatarUrl;
  final UserMode currentMode;
  final int itemsOrdered;
  final int itemsSold;

  UserProfile({
    required this.id,
    required this.name,
    required this.location,
    this.avatarUrl,
    this.currentMode = UserMode.buyer,
    this.itemsOrdered = 0,
    this.itemsSold = 0,
  });

  UserProfile copyWith({
    String? name,
    String? location,
    UserMode? currentMode,
    int? itemsOrdered,
    int? itemsSold,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      avatarUrl: avatarUrl,
      currentMode: currentMode ?? this.currentMode,
      itemsOrdered: itemsOrdered ?? this.itemsOrdered,
      itemsSold: itemsSold ?? this.itemsSold,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String? type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type,
  });
}
