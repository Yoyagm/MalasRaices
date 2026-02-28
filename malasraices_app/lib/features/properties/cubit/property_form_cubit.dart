import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/property_model.dart';
import '../data/properties_repository.dart';

part 'property_form_state.dart';

class PropertyFormCubit extends Cubit<PropertyFormState> {
  PropertyFormCubit({required PropertiesRepository propertiesRepository})
      : _propertiesRepository = propertiesRepository,
        super(const PropertyFormState());

  final PropertiesRepository _propertiesRepository;

  void updateField({
    String? title,
    String? description,
    String? price,
    String? address,
    String? propertyType,
    String? bedrooms,
    String? bathrooms,
    String? areaSqm,
  }) {
    emit(state.copyWith(
      title: title,
      description: description,
      price: price,
      address: address,
      propertyType: propertyType,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      areaSqm: areaSqm,
    ));
  }

  Future<void> submit() async {
    if (!_validate()) return;

    emit(state.copyWith(status: PropertyFormStatus.submitting));

    try {
      final data = <String, dynamic>{
        'title': state.title.trim(),
        'description': state.description.trim(),
        'price': double.parse(state.price),
        'address': state.address.trim(),
        'propertyType': state.propertyType,
        'bedrooms': int.parse(state.bedrooms),
        'bathrooms': int.parse(state.bathrooms),
      };

      if (state.areaSqm.isNotEmpty) {
        data['areaSqm'] = double.parse(state.areaSqm);
      }

      final property = await _propertiesRepository.create(data);
      emit(state.copyWith(
        status: PropertyFormStatus.success,
        createdProperty: property,
      ));
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Error al crear propiedad';
      emit(state.copyWith(
        status: PropertyFormStatus.error,
        errorMessage: message is List ? message.first : message.toString(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PropertyFormStatus.error,
        errorMessage: 'Error inesperado: $e',
      ));
    }
  }

  bool _validate() {
    final errors = <String>[];

    if (state.title.trim().isEmpty) errors.add('El título es requerido');
    if (state.description.trim().isEmpty) {
      errors.add('La descripción es requerida');
    }
    if (state.price.isEmpty || double.tryParse(state.price) == null) {
      errors.add('El precio debe ser un número válido');
    }
    if (state.address.trim().isEmpty) {
      errors.add('La dirección es requerida');
    }
    if (state.bedrooms.isEmpty || int.tryParse(state.bedrooms) == null) {
      errors.add('Habitaciones debe ser un número');
    }
    if (state.bathrooms.isEmpty || int.tryParse(state.bathrooms) == null) {
      errors.add('Baños debe ser un número');
    }

    if (errors.isNotEmpty) {
      emit(state.copyWith(
        status: PropertyFormStatus.error,
        errorMessage: errors.first,
      ));
      return false;
    }
    return true;
  }
}
