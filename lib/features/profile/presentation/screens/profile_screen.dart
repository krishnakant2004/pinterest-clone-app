import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../saved_pins/presentation/providers/saved_pins_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/boards_tab_content.dart';
import '../widgets/collages_tab_content.dart';
import '../widgets/pins_tab_content.dart';
import '../widgets/profile_app_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Filter states
  String _pinsFilter = 'all';
  String _boardsSort = 'custom';
  bool _showBoardsGroup = false;

  // Collages placeholder data
  final List<Collage> _collages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final savedPinsState = ref.watch(savedPinsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: ProfileAppBarAvatar(profile: profileState),
        ),
        title: ProfileTabBar(
          tabController: _tabController,
          onTabChanged: (_) => setState(() {}),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ProfileSearchBar(
            controller: _searchController,
            onAddTap: () {
              HapticFeedback.mediumImpact();
              if (_tabController.index == 0) {
                context.push(RouteNames.createPin);
              } else if (_tabController.index == 1) {
                context.push(RouteNames.createBoard);
              }
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PinsTabContent(
                  savedPinsState: savedPinsState,
                  filter: _pinsFilter,
                  onFilterChanged: (f) => setState(() => _pinsFilter = f),
                ),
                BoardsTabContent(
                  sortBy: _boardsSort,
                  showGroup: _showBoardsGroup,
                  onSortChanged: (s) => setState(() => _boardsSort = s),
                  onGroupToggle:
                      () =>
                          setState(() => _showBoardsGroup = !_showBoardsGroup),
                  savedPinsState: savedPinsState,
                ),
                CollagesTabContent(
                  collages: _collages,
                  onCreateTap: () {
                    HapticFeedback.mediumImpact();
                    // TODO: Navigate to create collage
                  },
                  onCollageTap: (collage) {
                    // TODO: Navigate to collage detail
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
