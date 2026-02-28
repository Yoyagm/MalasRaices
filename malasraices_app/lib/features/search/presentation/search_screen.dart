import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/property_card.dart';
import '../bloc/search_bloc.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Propiedades'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por título, dirección...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          switch (state.status) {
            case SearchStatus.initial:
              return const EmptyState(
                icon: Icons.search,
                title: 'Busca tu próximo hogar',
                subtitle: 'Ingresa una palabra clave o aplica filtros',
              );
            case SearchStatus.loading:
              if (state.properties.isEmpty) {
                return const LoadingIndicator(message: 'Buscando...');
              }
              return _buildResultsList(context, state, isLoading: true);
            case SearchStatus.success:
              if (state.properties.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'Sin resultados',
                  subtitle: 'Intenta con otros filtros o palabras clave',
                );
              }
              return _buildResultsList(context, state);
            case SearchStatus.failure:
              return ErrorView(
                message: state.errorMessage ?? 'Error al buscar',
                onRetry: () =>
                    context.read<SearchBloc>().add(SearchRefreshRequested()),
              );
          }
        },
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    SearchState state, {
    bool isLoading = false,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          context.read<SearchBloc>().add(SearchNextPageRequested());
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.properties.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.properties.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final property = state.properties[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PropertyCard(
              property: property,
              onTap: () => context.push('/property/${property.id}'),
            ),
          );
        },
      ),
    );
  }
}
