import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../di/injection_container.dart' as di;
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/favorites/cubit/favorites_cubit.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/properties/cubit/property_detail_cubit.dart';
import '../../features/properties/cubit/property_form_cubit.dart';
import '../../features/properties/cubit/property_list_cubit.dart';
import '../../features/properties/presentation/create_property_screen.dart';
import '../../features/properties/presentation/my_properties_screen.dart';
import '../../features/properties/presentation/property_detail_screen.dart';
import '../../features/search/bloc/search_bloc.dart';
import '../../features/search/presentation/search_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuth = authState is AuthAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // Property detail (outside ShellRoute — no bottom nav)
      GoRoute(
        path: '/property/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => di.sl<PropertyDetailCubit>()..loadProperty(id),
            child: const PropertyDetailScreen(),
          );
        },
      ),

      // Create property (outside ShellRoute — no bottom nav)
      GoRoute(
        path: '/properties/new',
        builder: (_, __) => BlocProvider(
          create: (_) => di.sl<PropertyFormCubit>(),
          child: const CreatePropertyScreen(),
        ),
      ),

      // Edit profile (outside ShellRoute — no bottom nav)
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => BlocProvider.value(
          value: di.sl<ProfileCubit>(),
          child: const EditProfileScreen(),
        ),
      ),

      // Main app with bottom navigation
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => BlocProvider(
              create: (_) =>
                  di.sl<SearchBloc>()..add(SearchRefreshRequested()),
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/favorites',
            builder: (_, __) => BlocProvider(
              create: (_) =>
                  di.sl<FavoritesCubit>()..loadFavorites(),
              child: const FavoritesScreen(),
            ),
          ),
          GoRoute(
            path: '/my-properties',
            builder: (_, __) => BlocProvider(
              create: (_) =>
                  di.sl<PropertyListCubit>()..loadProperties(),
              child: const MyPropertiesScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => BlocProvider.value(
              value: di.sl<ProfileCubit>()..loadProfile(),
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Mis Propiedades',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location == '/favorites') return 1;
    if (location == '/my-properties') return 2;
    if (location == '/profile') return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/favorites');
      case 2:
        context.go('/my-properties');
      case 3:
        context.go('/profile');
    }
  }
}
