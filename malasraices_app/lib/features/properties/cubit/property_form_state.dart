part of 'property_form_cubit.dart';

enum PropertyFormStatus { initial, submitting, success, error }

class PropertyFormState extends Equatable {
  const PropertyFormState({
    this.status = PropertyFormStatus.initial,
    this.title = '',
    this.description = '',
    this.price = '',
    this.address = '',
    this.propertyType = 'APARTMENT',
    this.bedrooms = '0',
    this.bathrooms = '0',
    this.areaSqm = '',
    this.errorMessage,
    this.createdProperty,
  });

  final PropertyFormStatus status;
  final String title;
  final String description;
  final String price;
  final String address;
  final String propertyType;
  final String bedrooms;
  final String bathrooms;
  final String areaSqm;
  final String? errorMessage;
  final PropertyModel? createdProperty;

  PropertyFormState copyWith({
    PropertyFormStatus? status,
    String? title,
    String? description,
    String? price,
    String? address,
    String? propertyType,
    String? bedrooms,
    String? bathrooms,
    String? areaSqm,
    String? errorMessage,
    PropertyModel? createdProperty,
  }) {
    return PropertyFormState(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      address: address ?? this.address,
      propertyType: propertyType ?? this.propertyType,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      areaSqm: areaSqm ?? this.areaSqm,
      errorMessage: errorMessage,
      createdProperty: createdProperty,
    );
  }

  @override
  List<Object?> get props => [
        status,
        title,
        description,
        price,
        address,
        propertyType,
        bedrooms,
        bathrooms,
        areaSqm,
        errorMessage,
      ];
}
