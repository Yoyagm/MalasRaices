import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/property_model.dart';
import '../data/properties_repository.dart';

part 'property_detail_state.dart';

class PropertyDetailCubit extends Cubit<PropertyDetailState> {
  PropertyDetailCubit({required PropertiesRepository propertiesRepository})
      : _propertiesRepository = propertiesRepository,
        super(PropertyDetailInitial());

  final PropertiesRepository _propertiesRepository;

  Future<void> loadProperty(String id) async {
    emit(PropertyDetailLoading());
    try {
      final property = await _propertiesRepository.getById(id);
      emit(PropertyDetailLoaded(property));
    } catch (e) {
      emit(const PropertyDetailError('Error al cargar la propiedad'));
    }
  }
}
