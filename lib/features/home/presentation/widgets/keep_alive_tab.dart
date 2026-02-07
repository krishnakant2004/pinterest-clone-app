
import 'package:flutter/material.dart';

/// Keeps tab content alive to prevent rebuilding on swipe
class KeepAliveTab extends StatefulWidget {
  final Widget child;

  const KeepAliveTab({required this.child , super.key});
  @override
  State<KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(child: widget.child);
  }
}

