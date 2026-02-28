import 'package:equatable/equatable.dart';

import 'property_image_model.dart';

class PropertyModel extends Equatable {
  const PropertyModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    this.latitude,
    this.longitude,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    this.areaSqm,
    required this.status,
    required this.createdAt,
    this.images = const [],
    this.ownerName,
    this.ownerPhone,
  });

  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double price;
  final String address;
  final double? latitude;
  final double? longitude;
  final String propertyType;
  final int bedrooms;
  final int bathrooms;
  final double? areaSqm;
  final String status;
  final DateTime createdAt;
  final List<PropertyImageModel> images;
  final String? ownerName;
  final String? ownerPhone;

  String? get coverImageUrl {
    if (images.isEmpty) return null;
    final cover = images.where((img) => img.isCover).toList();
    return cover.isNotEmpty ? cover.first.imageUrl : images.first.imageUrl;
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    final imagesList = json['images'] as List<dynamic>? ?? [];

    return PropertyModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] is String)
          ? double.parse(json['price'] as String)
          : (json['price'] as num).toDouble(),
      address: json['address'] as String,
      latitude: json['latitude'] != null
          ? (json['latitude'] is String)
              ? double.parse(json['latitude'] as String)
              : (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] is String)
              ? double.parse(json['longitude'] as String)
              : (json['longitude'] as num).toDouble()
          : null,
      propertyType: json['propertyType'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      areaSqm: json['areaSqm'] != null
          ? (json['areaSqm'] is String)
              ? double.parse(json['areaSqm'] as String)
              : (json['areaSqm'] as num).toDouble()
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images: imagesList
          .map((img) =>
              PropertyImageModel.fromJson(img as Map<String, dynamic>))
          .toList(),
      ownerName: owner != null
          ? '${owner['firstName']} ${owner['lastName']}'
          : null,
      ownerPhone: owner?['phone'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, status];
}
