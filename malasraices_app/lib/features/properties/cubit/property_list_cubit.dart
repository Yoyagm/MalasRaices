import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/properties_repository.dart';
import 'property_list_state.dart';

class PropertyListCubit extends Cubit<PropertyListState> {
  PropertyListCubit({required PropertiesRepository propertiesRepository})
      : _propertiesRepository = propertiesRepository,
        super(PropertyListInitial());

  final PropertiesRepository _propertiesRepository;

  Future<void> loadProperties() async {
    emit(PropertyListLoading());
    try {
      final properties = await _propertiesRepository.getMyProperties();
      emit(PropertyListLoaded(properties));
    } catch (e) {
      emit(const PropertyListError('Error al cargar propiedades'));
    }
  }

  Future<void> deactivateProperty(String id) async {
    try {
      await _propertiesRepository.deactivate(id);
      await loadProperties();
    } catch (e) {
      emit(const PropertyListError('Error al desactivar propiedad'));
    }
  }
}
