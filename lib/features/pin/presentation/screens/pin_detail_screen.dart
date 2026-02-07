import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/providers/pin_provider.dart';
import '../../../boards/domain/entities/board.dart';
import '../../../boards/presentation/providers/boards_provider.dart';
import '../../../likes/presentation/providers/likes_provider.dart';
import '../../../saved_pins/presentation/providers/saved_pins_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/board_widgets.dart';
import '../../../../core/widgets/bottom_sheet_widgets.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../domain/entities/pin.dart';
import '../widgets/pin_detail_action_bar.dart';
import '../widgets/pin_detail_image.dart';
import '../widgets/pin_info_widgets.dart';
import '../widgets/pin_options_bottom_sheet.dart';
import '../widgets/related_pins_grid.dart';

/// Data class for pin navigation extras
class PinNavigationExtra {
  final Pin pin;
  final String? boardName; // null means "For You" (random pins)

  const PinNavigationExtra({required this.pin, this.boardName});
}

class PinDetailScreen extends ConsumerStatefulWidget {
  final String pinId;
  final dynamic initialPin; // Optional Pin passed during navigation
  final String? boardName; // Board name for related pins context

  const PinDetailScreen({
    super.key,
    required this.pinId,
    this.initialPin,
    this.boardName,
  });

  @override
  ConsumerState<PinDetailScreen> createState() => _PinDetailScreenState();
}

class _PinDetailScreenState extends ConsumerState<PinDetailScreen> {
  Pin? _pin;
  List<Pin> _relatedPins = [];
  bool _isLoadingRelated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeScreen());
  }

  void _initializeScreen() {
    // Get pin from navigation or cache
    if (widget.initialPin != null && widget.initialPin is Pin) {
      _pin = widget.initialPin as Pin;
    } else {
      _pin = _findPinInCache();
    }

    if (_pin != null) {
      setState(() {});
      _loadMoreToExplore();
    }
  }

  Pin? _findPinInCache() {
    final pinState = ref.read(pinProvider);
    return pinState.feedPins.where((p) => p.id == widget.pinId).firstOrNull ??
        pinState.searchResults.where((p) => p.id == widget.pinId).firstOrNull ??
        pinState.relatedPins.where((p) => p.id == widget.pinId).firstOrNull;
  }

  Future<void> _loadMoreToExplore() async {
    if (_isLoadingRelated || _pin == null) return;

    setState(() => _isLoadingRelated = true);

    final notifier = ref.read(pinProvider.notifier);
    List<Pin> pins;

    if (widget.boardName != null) {
      // From Board: search by board name
      pins = await notifier.fetchPinsByKeyword(widget.boardName!);
    } else {
      // From For You: get random curated pins
      pins = await notifier.fetchRandomCuratedPins();
    }

    // Filter out current pin
    _relatedPins = pins.where((p) => p.id != _pin!.id).toList();
    setState(() => _isLoadingRelated = false);
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    if (_pin != null) {
      ref.read(likesProvider.notifier).toggleLike(_pin!.id);
    }
  }

  void _toggleSave(Pin pin) {
    HapticFeedback.mediumImpact();
    final isSaved = ref.read(isPinSavedProvider(pin.id));

    if (isSaved) {
      final boardId = ref
          .read(savedPinsProvider.notifier)
          .getPinBoardId(pin.id);
      if (boardId != null) {
        ref.read(savedPinsProvider.notifier).unsavePin(pin.id, boardId);
        _showSnackBar('Pin removed from board');
      }
    } else {
      _showSaveToBoardSheet(pin);
    }
  }

  void _showSaveToBoardSheet(Pin pin) {
    final boards = ref.read(boardsProvider).boards;

    if (boards.isEmpty) {
      _showSnackBar('Create a board first to save pins');
      return;
    }

    showAppBottomSheet(
      context: context,
      child: SaveToBoardSheet(
        pin: pin,
        boards: boards,
        onBoardSelected: (boardId, boardName) async {
          Navigator.pop(context);
          final success = await ref
              .read(savedPinsProvider.notifier)
              .savePin(pin, boardId);
          if (success && mounted) {
            _showSnackBar('Saved to $boardName');
          }
        },
      ),
    );
  }

  void _showMoreOptions(Pin pin) {
    HapticFeedback.selectionClick();
    PinOptionsBottomSheet.show(
      context: context,
      pin: pin,
      onSave: () => _toggleSave(pin),
    );
  }

  void _showComments() {
    HapticFeedback.selectionClick();
    // TODO: Navigate to comments screen
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final pin = _pin;

    if (pin == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLiked = ref.watch(isPinLikedProvider(pin.id));
    final isSaved = ref.watch(isPinSavedProvider(pin.id));

    final avgColor =
        pin.avgColor != null
            ? Color(int.parse(pin.avgColor!.replaceFirst('#', '0xFF')))
            : AppColors.greyLight;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with visual search button
                  PinDetailImage(
                    imageUrl: pin.imageUrl,
                    pinId: pin.id,
                    avgColor: avgColor,
                    onVisualSearchTap: () {
                      // TODO: Visual search
                    },
                  ),
            
                  // Action bar (like, comment, share, more, save)
                  PinDetailActionBar(
                    isLiked: isLiked,
                    isSaved: isSaved,
                    likeCount: '376',
                    commentCount: '2',
                    onLikeTap: _toggleLike,
                    onCommentTap: _showComments,
                    onShareTap:
                        () => Share.share(
                          'Check out this pin: ${pin.link ?? pin.imageUrl}',
                        ),
                    onMoreTap: () => _showMoreOptions(pin),
                    onSaveTap: () => _toggleSave(pin),
                  ),
            
                  // Photographer info
                  PinPhotographerRow(name: pin.photographer ?? 'Pinterest User'),
            
                  // Comment preview
                  PinCommentPreview(onTap: _showComments),
            
                  // More to explore header
                  const MoreToExploreHeader(),
            
                  // Related pins grid (uses local state)
                  RelatedPinsGrid(
                    pins: _relatedPins,
                    isLoading: _isLoadingRelated,
                    onPinTap: (relatedPin) {
                      // Pass the same board context to related pin
                      context.push(
                        '${RouteNames.pinDetail}/${relatedPin.id}',
                        extra: PinNavigationExtra(
                          pin: relatedPin,
                          boardName: widget.boardName,
                        ),
                      );
                    },
                  ),
            
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            // Back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: AppBackButton(onTap: () => context.pop()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Save to board bottom sheet
class SaveToBoardSheet extends StatelessWidget {
  final Pin pin;
  final List<Board> boards;
  final Function(String boardId, String boardName) onBoardSelected;

  const SaveToBoardSheet({
    super.key,
    required this.pin,
    required this.boards,
    required this.onBoardSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetTitle(title: 'Save to board'),
          const CreateBoardTile(),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];
              return BoardListItem(
                board: board,
                onTap: () => onBoardSelected(board.id, board.name),
              );
            },
          ),
        ],
      ),
    );
  }
}
