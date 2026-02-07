import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../boards/domain/entities/board.dart';
import '../../../boards/presentation/providers/boards_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/home_provider.dart';
import '../widgets/board_content_screen.dart';
import '../widgets/for_you_screen.dart';
import '../widgets/keep_alive_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _tabCount = 1;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  /// Build combined boards list: "For you" + user's real boards
  List<Board> _getBoardTabs(List<Board> userBoards) {
    const forYouBoard = Board(
      id: 'for_you',
      name: 'For you',
      userId: '',
      pinCount: 0,
    );
    return [forYouBoard, ...userBoards];
  }

  void _updateTabController(int newCount) {
    if (_tabController == null || _tabCount != newCount) {
      _tabController?.dispose();
      _tabController = TabController(length: newCount, vsync: this);
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          HapticFeedback.selectionClick();
          // Mark tab as visited when user swipes to it (using provider)
          final currentIndex = _tabController!.index;
          ref.read(visitedBoardTabsProvider.notifier).markVisited(currentIndex);
        }
      });
      _tabCount = newCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardsState = ref.watch(boardsProvider);
    ref.watch(visitedBoardTabsProvider);

    // Combine "For you" with real boards
    final allBoardTabs = _getBoardTabs(boardsState.boards);

    // Update tab controller when boards change
    _updateTabController(allBoardTabs.length);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // TabBar with scrollable tabs and sliding indicator
            Container(
              decoration: BoxDecoration(color: AppColors.white),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.black.withAlpha(250),
                unselectedLabelColor: AppColors.black.withAlpha(250),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border(
                    bottom: BorderSide(color: AppColors.black, width: 3),
                  ),
                ),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tabs:
                    allBoardTabs.map((board) {
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(board.name),
                            if (board.isPrivate) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.lock_outline, size: 14),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            // TabBarView for swipeable content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const ClampingScrollPhysics(),
                children:
                    allBoardTabs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final board = entry.value;
                      if (index == 0) {
                        return const KeepAliveTab(child: ForYouFeed());
                      }
                      // Always wrap in KeepAliveTab to preserve state
                      return KeepAliveTab(
                        child: LazyBoardContent(
                          key: ValueKey('board_${board.id}'),
                          board: board,
                          tabIndex: index,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
