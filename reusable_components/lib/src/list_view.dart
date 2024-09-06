import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:reusable_components/src/dimensions.dart';

/// Flutter `ListView` Wrapper with added functionality
class GenericListView extends StatelessWidget {
  /// Flutter ListView wrapper
  GenericListView({
    required List<Widget> children,
    super.key,
    this.header,
    this.bottom,
    this.onRefresh,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.padding = const EdgeInsets.all(d_margin2),
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
  })  : _childDelegate = SliverChildListDelegate(children),
        loop = false;

  /// `ListView.builder` Wrapper
  GenericListView.builder({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    super.key,
    this.header,
    this.bottom,
    this.onRefresh,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.padding = const EdgeInsets.all(d_margin2),
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.loop = false,
  }) : _childDelegate = loop
            ? SliverChildBuilderDelegate((context, i) => itemBuilder(context, i % itemCount))
            : SliverChildBuilderDelegate(itemBuilder, childCount: itemCount);

  /// `ListView.separated` wrapper
  GenericListView.separated({
    required IndexedWidgetBuilder itemBuilder,
    required IndexedWidgetBuilder separatedBuilder,
    required int itemCount,
    super.key,
    this.header,
    this.bottom,
    this.onRefresh,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.padding = const EdgeInsets.all(d_margin2),
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.loop = false,
  }) : _childDelegate = loop
            ? SliverChildBuilderDelegate(
                (context, index) {
                  final itemIndex = (index ~/ 2) % itemCount;
                  return index.isEven ? itemBuilder(context, itemIndex) : separatedBuilder(context, itemIndex);
                },
              )
            : SliverChildBuilderDelegate(
                (context, index) {
                  final itemIndex = index ~/ 2;
                  return index.isEven ? itemBuilder(context, itemIndex) : separatedBuilder(context, itemIndex);
                },
                childCount: math.max(0, itemCount * 2 - 1),
                semanticIndexCallback: (_, index) => index.isEven ? index ~/ 2 : null,
              );
  final SliverChildDelegate _childDelegate;

  /// Widget at the bottom of the list view.
  final Widget? bottom;

  /// Callback for pull to refresh
  final RefreshCallback? onRefresh;

  /// callback to add more item to list
  final VoidCallback? onLoadMore;

  /// Flag to show the loading indicator when item are loading
  final bool isLoadingMore;

  /// Widget at the top of the list view
  final Widget? header;

  /// Padding for the `children`.
  ///
  /// Default is 16.0 on all direction.
  final EdgeInsetsGeometry padding;

  /// shrinkWrap
  final bool shrinkWrap;

  /// ScrollPhysics
  final ScrollPhysics? physics;

  /// ListView scroll direction
  final Axis scrollDirection;

  /// ScrollController
  final ScrollController? controller;

  /// Loops the list view within the bound of the provided itemCount.
  final bool loop;

  @override
  Widget build(BuildContext context) {
    Widget child = CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      scrollDirection: scrollDirection,
      slivers: [
        if (header != null) SliverToBoxAdapter(child: header),
        SliverPadding(
          padding: padding,
          sliver: SliverList(delegate: _childDelegate),
        ),
        if (onLoadMore != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: d_margin2, horizontal: d_margin6),
              child: isLoadingMore
                  ? LinearProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        if (bottom != null)
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: bottom,
            ),
          ),
      ],
    );

    if (onLoadMore != null) {
      child = NotificationListener<ScrollEndNotification>(
        onNotification: (scrollNotification) {
          final scrollMetrics = scrollNotification.metrics;
          final hasReachedEnd = scrollMetrics.pixels >= 0.8 * scrollMetrics.maxScrollExtent;
          if (hasReachedEnd) onLoadMore!();
          return false;
        },
        child: child,
      );
    }

    if (onRefresh == null) return child;

    return RefreshIndicator(onRefresh: onRefresh!, child: child);
  }
}
