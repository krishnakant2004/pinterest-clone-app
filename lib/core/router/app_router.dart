import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinterest_clone/features/inbox/presentation/inbox_page.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/pin/domain/entities/pin.dart';
import '../../features/pin/presentation/screens/pin_detail_screen.dart';
import '../../features/pin/presentation/screens/create_pin_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/board_screen/presentation/screens/board_detail_screen.dart';
import '../../features/board_screen/presentation/screens/create_board_screen.dart';
import '../widgets/main_navigation_shell.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SplashScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
      ),

      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const LoginScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                );
              },
            ),
      ),

      // Main Navigation Shell
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          // Home Tab
          GoRoute(
            path: RouteNames.home,
            name: RouteNames.home,
            pageBuilder:
                (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),

          // Search Tab
          GoRoute(
            path: RouteNames.search,
            name: RouteNames.search,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: SearchScreen()),
          ),

          // Profile Tab
          GoRoute(
            path: RouteNames.profile,
            name: RouteNames.profile,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
          ),
          // Inbox Tab
          GoRoute(
            path: RouteNames.inbox,
            name: RouteNames.inbox,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: InboxScreen()),
          ),
        ],
      ),

      // Pin Detail
      GoRoute(
        path: '${RouteNames.pinDetail}/:pinId',
        name: RouteNames.pinDetail,
        pageBuilder: (context, state) {
          final pinId = state.pathParameters['pinId']!;
          final extra = state.extra;

          // Handle both PinNavigationExtra and direct Pin object for backwards compatibility
          Pin? pin;
          String? boardName;

          if (extra is PinNavigationExtra) {
            pin = extra.pin;
            boardName = extra.boardName;
          } else if (extra is Pin) {
            pin = extra;
            boardName = null; // "For You" context
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: PinDetailScreen(
              pinId: pinId,
              initialPin: pin,
              boardName: boardName,
            ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),

      // Create Pin
      GoRoute(
        path: RouteNames.createPin,
        name: RouteNames.createPin,
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CreatePinScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                );
              },
            ),
      ),

      // Board Detail
      GoRoute(
        path: '${RouteNames.boardDetail}/:boardId',
        name: RouteNames.boardDetail,
        pageBuilder: (context, state) {
          final boardId = state.pathParameters['boardId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BoardDetailScreen(boardId: boardId),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              );
            },
          );
        },
      ),

      // Create Board
      GoRoute(
        path: RouteNames.createBoard,
        name: RouteNames.createBoard,
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CreateBoardScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                );
              },
            ),
      ),

      // Settings
      GoRoute(
        path: RouteNames.settings,
        name: RouteNames.settings,
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                );
              },
            ),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Page not found: ${state.uri.path}')),
        ),
  );
});
