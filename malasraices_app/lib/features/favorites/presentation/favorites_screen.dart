import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/property_card.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Favoritos')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const LoadingIndicator();
          }

          if (state is FavoritesError) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<FavoritesCubit>().loadFavorites(),
            );
          }

          if (state is FavoritesLoaded) {
            if (state.properties.isEmpty) {
              return const EmptyState(
                icon: Icons.favorite_border,
                title: 'Sin favoritos',
                subtitle:
                    'Guarda propiedades que te interesen para verlas aquí',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.properties.length,
              itemBuilder: (context, index) {
                final property = state.properties[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PropertyCard(
                    property: property,
                    isFavorite: true,
                    onTap: () => context.push('/property/${property.id}'),
                    onFavorite: () => context
                        .read<FavoritesCubit>()
                        .toggleFavorite(property.id),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
