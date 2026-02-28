import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/property_card.dart';
import '../cubit/property_list_cubit.dart';
import '../cubit/property_list_state.dart';

class MyPropertiesScreen extends StatelessWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Propiedades')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/properties/new'),
        icon: const Icon(Icons.add),
        label: const Text('Publicar'),
      ),
      body: BlocBuilder<PropertyListCubit, PropertyListState>(
        builder: (context, state) {
          if (state is PropertyListLoading) {
            return const LoadingIndicator();
          }

          if (state is PropertyListError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<PropertyListCubit>().loadProperties(),
            );
          }

          if (state is PropertyListLoaded) {
            if (state.properties.isEmpty) {
              return EmptyState(
                icon: Icons.home_outlined,
                title: 'No tienes propiedades publicadas',
                subtitle: 'Publica tu primera propiedad',
                actionLabel: 'Publicar',
                onAction: () => context.push('/properties/new'),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<PropertyListCubit>().loadProperties(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.properties.length,
                itemBuilder: (context, index) {
                  final property = state.properties[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PropertyCard(
                      property: property,
                      onTap: () =>
                          context.push('/property/${property.id}'),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
