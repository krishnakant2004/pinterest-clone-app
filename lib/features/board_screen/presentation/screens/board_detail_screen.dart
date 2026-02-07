import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/pin_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../boards/presentation/providers/boards_provider.dart';
import '../../../pin/domain/entities/pin.dart';
import '../../../pin/presentation/screens/pin_detail_screen.dart';
import '../../../saved_pins/domain/entities/saved_pin.dart';
import '../../../saved_pins/presentation/providers/saved_pins_provider.dart';
import '../widgets/widgets.dart';

class BoardDetailScreen extends ConsumerStatefulWidget {
  final String boardId;

  const BoardDetailScreen({super.key, required this.boardId});

  @override
  ConsumerState<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends ConsumerState<BoardDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  bool _isBoardInfoVisible = true;
  double _lastScrollOffset = 0;

  String _boardName = 'Board';
  int _pinCount = 0;

  List<Pin> _moreIdeasPins = [];
  bool _isLoadingMoreIdeas = false;
  List<SavedPin> _savedPins = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBoardData());
  }

  void _loadBoardData() {
    final boardsState = ref.read(boardsProvider);
    final board = boardsState.boards.where((b) => b.id == widget.boardId).firstOrNull;

    if (board != null) {
      setState(() {
        _boardName = board.name;
        _pinCount = board.pinCount;
      });
    }

    _loadSavedPins();
    _loadMoreIdeas();
  }

  Future<void> _loadSavedPins() async {
    final savedPinsState = ref.read(savedPinsProvider);
    setState(() {
      _savedPins = savedPinsState.pins
          .where((pin) => pin.boardId == widget.boardId)
          .take(20)
          .toList();
    });
  }

  Future<void> _loadMoreIdeas() async {
    setState(() => _isLoadingMoreIdeas = true);

    await ref.read(pinProvider.notifier).searchPins(_boardName);

    final pinState = ref.read(pinProvider);
    setState(() {
      _moreIdeasPins = pinState.searchResults;
      _isLoadingMoreIdeas = false;
    });
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    final scrollDelta = currentOffset - _lastScrollOffset;

    if (scrollDelta > 5 && _isBoardInfoVisible && currentOffset > 50) {
      setState(() => _isBoardInfoVisible = false);
    } else if (scrollDelta < -5 && !_isBoardInfoVisible) {
      setState(() => _isBoardInfoVisible = true);
    }

    _lastScrollOffset = currentOffset;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.black),
              ),
              title: Text(
                _boardName,
                style: const TextStyle(
                  color: AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () => HapticFeedback.selectionClick(),
                  icon: const Icon(Icons.person_add_outlined, color: AppColors.black),
                ),
                IconButton(
                  onPressed: () => HapticFeedback.selectionClick(),
                  icon: const Icon(Icons.share_outlined, color: AppColors.black),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    showBoardMoreOptions(context);
                  },
                  icon: const Icon(Icons.more_horiz, color: AppColors.black),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: BoardInfoHeader(
                boardName: _boardName,
                pinCount: _pinCount,
                isVisible: _isBoardInfoVisible,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: BoardTabBarDelegate(
                tabController: _tabController,
                onFilterTap: _tabController.index == 1 ? () => showFilterOptions(context) : null,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            MoreIdeasTab(
              pins: _moreIdeasPins,
              isLoading: _isLoadingMoreIdeas,
              onPinTap: _onPinTap,
            ),
            AllSavesTab(pins: _savedPins, onPinTap: _onSavedPinTap),
          ],
        ),
      ),
      bottomNavigationBar: BoardBottomActionBar(
        tabController: _tabController,
        onOrganiseTap: () {},
        onAddTap: () => showAddOptions(context),
        onMoreIdeasTap: () => _tabController.animateTo(0),
      ),
    );
  }

  void _onPinTap(Pin pin) {
    context.push(
      '${RouteNames.pinDetail}/${pin.id}',
      extra: PinNavigationExtra(pin: pin, boardName: _boardName),
    );
  }

  void _onSavedPinTap(SavedPin savedPin) {
    final pin = Pin(
      id: savedPin.pinId,
      imageUrl: savedPin.imageUrl,
      thumbnailUrl: savedPin.thumbnailUrl,
      width: savedPin.width,
      height: savedPin.height,
      title: savedPin.title,
      description: savedPin.description,
      photographer: savedPin.photographer,
      avgColor: savedPin.avgColor,
      link: savedPin.link,
    );
    context.push(
      '${RouteNames.pinDetail}/${savedPin.pinId}',
      extra: PinNavigationExtra(pin: pin, boardName: _boardName),
    );
  }


}
