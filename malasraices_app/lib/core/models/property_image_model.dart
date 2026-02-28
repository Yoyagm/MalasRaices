import 'package:equatable/equatable.dart';

class PropertyImageModel extends Equatable {
  const PropertyImageModel({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
    required this.isCover,
  });

  final String id;
  final String imageUrl;
  final int displayOrder;
  final bool isCover;

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    return PropertyImageModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      displayOrder: json['displayOrder'] as int,
      isCover: json['isCover'] as bool,
    );
  }

  @override
  List<Object> get props => [id, imageUrl];
}
