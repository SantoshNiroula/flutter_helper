import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:reusable_components/reusable_components.dart';
import 'package:reusable_components/src/dimensions.dart';

// ignore_for_file: no_leading_underscores_for_local_identifiers

/// GridView wrapper
class GenericGridView extends StatelessWidget {
  /// Builds a custom gridView
  ///
  /// Will build en empty box if [crossAxisCount] is less than 1
  const GenericGridView({
    required this.crossAxisCount,
    required this.children,
    super.key,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.all(d_margin2),
    this.mainAxisSpacing = d_margin2,
    this.crossAxisSpacing = d_margin2,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.bottom,
    this.matchTileHeight = false,
    this.onRefresh,
    this.header,
    this.scrollController,
  })  : itemBuilder = null,
        itemMaxWidth = null,
        itemCount = 0,
        mainAxisSize = null,
        _wrapAlignment = null,
        _type = _Type.normal;

  /// Lazily builds a custom gridView
  ///
  /// Will build en empty box if [crossAxisCount] is less than 1
  ///
  /// Will also build an empty box if [itemCount] is less than 1
  const GenericGridView.builder({
    required this.crossAxisCount,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.all(d_margin2),
    this.mainAxisSpacing = d_margin2,
    this.crossAxisSpacing = d_margin2,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.bottom,
    this.matchTileHeight = false,
    this.onRefresh,
    this.header,
    this.scrollController,
  })  : children = null,
        itemMaxWidth = null,
        mainAxisSize = null,
        _wrapAlignment = null,
        _type = _Type.builder;

  /// Builds a custom low cost gridView
  ///
  /// Will build en empty box if [crossAxisCount] is less than 1
  ///
  /// This gridView is not scrollable and hence mush be wrapped
  ///
  /// in a scrollable widget if scrolling is required
  const GenericGridView.simple({
    required this.crossAxisCount,
    required this.children,
    super.key,
    this.padding = const EdgeInsets.all(d_margin2),
    this.mainAxisSpacing = d_margin2,
    this.crossAxisSpacing = d_margin2,
    this.physics,
    this.bottom,
    this.itemMaxWidth,
    this.header,
    this.mainAxisSize,
    this.scrollController,
    WrapAlignment? wrapAlignment,
  })  : itemBuilder = null,
        itemCount = 0,
        matchTileHeight = false,
        shrinkWrap = false,
        scrollDirection = Axis.vertical,
        _type = _Type.simple,
        _wrapAlignment = wrapAlignment,
        onRefresh = null;

  /// crossAxisCount
  final int crossAxisCount;

  ///
  final bool shrinkWrap;

  ///
  final EdgeInsets padding;

  ///
  final double mainAxisSpacing;

  ///
  final double crossAxisSpacing;

  ///
  final ScrollPhysics? physics;

  ///
  final List<Widget>? children;

  ///
  final int itemCount;

  ///
  final IndexedWidgetBuilder? itemBuilder;

  ///
  final Axis scrollDirection;

  ///
  final RefreshCallback? onRefresh;

  ///
  final Widget? header;

  ///
  final MainAxisSize? mainAxisSize;

  ///
  final ScrollController? scrollController;

  /// If item width is fixed
  ///
  /// and should not be calculated
  final double? itemMaxWidth;

  /// Widget to be placed at the end of the main axis
  final Widget? bottom;

  final _Type _type;

  /// When each tile should occupy the same height
  ///
  /// Use with caution
  ///
  /// This is relatively expensive. Avoid using it where possible.
  final bool matchTileHeight;

  final WrapAlignment? _wrapAlignment;

  @override
  Widget build(BuildContext context) {
    if (crossAxisCount <= 0) return const SizedBox.shrink();

    switch (_type) {
      case _Type.normal:
        return _NormalGrid(
          header: header,
          matchTileHeight: matchTileHeight,
          crossAxisCount: crossAxisCount,
          shrinkWrap: shrinkWrap,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          physics: physics,
          scrollDirection: scrollDirection,
          bottom: bottom,
          onRefresh: onRefresh,
          children: children!,
        );
      case _Type.simple:
        return _SimpleGrid(
          header: header,
          crossAxisCount: crossAxisCount,
          wrapAlignment: _wrapAlignment,
          shrinkWrap: shrinkWrap,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          bottom: bottom,
          itemMaxWidth: itemMaxWidth,
          mainAxisSize: mainAxisSize,
          children: children!,
        );
      case _Type.builder:
        return _LazyGrid(
          scrollController: scrollController,
          header: header,
          matchTileHeight: matchTileHeight,
          crossAxisCount: crossAxisCount,
          shrinkWrap: shrinkWrap,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          physics: physics,
          itemCount: itemCount,
          itemBuilder: itemBuilder!,
          scrollDirection: scrollDirection,
          bottom: bottom,
          onRefresh: onRefresh,
        );
    }
  }
}

class _SimpleGrid extends StatelessWidget {
  const _SimpleGrid({
    required this.crossAxisCount,
    required this.children,
    required this.padding,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.shrinkWrap,
    required this.bottom,
    required this.itemMaxWidth,
    required this.header,
    required this.mainAxisSize,
    this.wrapAlignment,
  });

  final int crossAxisCount;
  final bool shrinkWrap;
  final EdgeInsets padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final List<Widget> children;
  final Widget? bottom;
  final double? itemMaxWidth;
  final Widget? header;
  final MainAxisSize? mainAxisSize;
  final WrapAlignment? wrapAlignment;

  @override
  Widget build(BuildContext context) {
    final bodyWidth = MediaQuery.sizeOf(context).width;
    final totalAvailableWidth = bodyWidth - padding.horizontal - (crossAxisCount - 1) * crossAxisSpacing;
    var _itemWidth = totalAvailableWidth / crossAxisCount;

    if (itemMaxWidth != null && _itemWidth > itemMaxWidth!) {
      _itemWidth = itemMaxWidth!;
    }

    final _resolvedTotalWidth = _itemWidth * crossAxisCount + crossAxisSpacing * (crossAxisCount - 1);

    final child = SizedBox(
      width: _resolvedTotalWidth,
      child: Wrap(
        runSpacing: mainAxisSpacing,
        alignment: wrapAlignment ?? WrapAlignment.start,
        spacing: crossAxisSpacing,
        children: children.map(
          (child) {
            return SizedBox(
              width: _itemWidth,
              child: child,
            );
          },
        ).toList(),
      ),
    );

    return Padding(
      padding: padding,
      child: header != null && bottom != null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: mainAxisSize ?? MainAxisSize.max,
              children: [
                if (header != null) header!,
                child,
                if (bottom != null) bottom!,
              ],
            ),
    );
  }
}

class _NormalGrid extends StatelessWidget {
  const _NormalGrid({
    required this.crossAxisCount,
    required this.children,
    required this.padding,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.shrinkWrap,
    required this.physics,
    required this.scrollDirection,
    required this.bottom,
    required this.matchTileHeight,
    required this.onRefresh,
    required this.header,
  });

  final int crossAxisCount;
  final bool shrinkWrap;
  final EdgeInsets padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final ScrollPhysics? physics;
  final List<Widget> children;
  final Axis scrollDirection;
  final Widget? bottom;
  final bool matchTileHeight;
  final RefreshCallback? onRefresh;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final childrenChunks = partition(children, crossAxisCount).toList();

    return GenericListView.separated(
      header: header,
      itemCount: childrenChunks.length,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      scrollDirection: scrollDirection,
      bottom: bottom,
      onRefresh: onRefresh,
      itemBuilder: (context, index) {
        if (scrollDirection == Axis.vertical) {
          return _GridRow(
            crossAxisCount: crossAxisCount,
            spacing: crossAxisSpacing,
            matchTileHeight: matchTileHeight,
            children: childrenChunks[index],
          );
        }
        return _GridColumn(
          crossAxisCount: crossAxisCount,
          spacing: crossAxisSpacing,
          children: childrenChunks[index],
        );
      },
      separatedBuilder: (context, index) => SizedBox(height: mainAxisSpacing),
    );
  }
}

class _LazyGrid extends StatelessWidget {
  const _LazyGrid({
    required this.crossAxisCount,
    required this.itemBuilder,
    required this.padding,
    required this.itemCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.shrinkWrap,
    required this.physics,
    required this.scrollDirection,
    required this.bottom,
    required this.matchTileHeight,
    required this.onRefresh,
    required this.header,
    this.scrollController,
  });

  final int crossAxisCount;
  final int itemCount;
  final bool shrinkWrap;
  final EdgeInsets padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final ScrollPhysics? physics;
  final IndexedWidgetBuilder itemBuilder;
  final Axis scrollDirection;
  final Widget? bottom;
  final bool matchTileHeight;
  final RefreshCallback? onRefresh;
  final Widget? header;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();
    return GenericListView.separated(
      controller: scrollController,
      header: header,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics,
      itemCount: (itemCount / crossAxisCount).ceil(),
      bottom: bottom,
      onRefresh: onRefresh,
      itemBuilder: (context, index) {
        if (crossAxisCount <= 1) {
          return itemBuilder(context, index);
        }
        final children = [
          for (var i = 0, actualIndex = crossAxisCount * index; i < crossAxisCount; i++, actualIndex++)
            if (actualIndex < itemCount) itemBuilder(context, actualIndex),
        ];

        if (scrollDirection == Axis.vertical) {
          return _GridRow(
            crossAxisCount: crossAxisCount,
            spacing: crossAxisSpacing,
            matchTileHeight: matchTileHeight,
            children: children,
          );
        }

        return _GridColumn(
          crossAxisCount: crossAxisCount,
          spacing: crossAxisSpacing,
          children: children,
        );
      },
      separatedBuilder: (context, index) {
        return scrollDirection == Axis.vertical ? SizedBox(height: mainAxisSpacing) : SizedBox(width: mainAxisSpacing);
      },
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.children,
    required this.crossAxisCount,
    required this.matchTileHeight,
    this.spacing = 0,
  });

  final int crossAxisCount;
  final List<Widget> children;
  final double spacing;
  final bool matchTileHeight;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < crossAxisCount; i++) ...[
          if (i < children.length)
            Expanded(
              child: Container(
                child: children[i],
              ),
            )
          else
            const Spacer(),
          if (i < crossAxisCount - 1) SizedBox(width: spacing),
        ],
      ],
    );
    if (matchTileHeight) {
      return IntrinsicHeight(
        child: row,
      );
    }
    return row;
  }
}

class _GridColumn extends StatelessWidget {
  const _GridColumn({required this.children, required this.crossAxisCount, this.spacing = 0});

  final int crossAxisCount;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < crossAxisCount; i++) ...[
          if (i < children.length)
            Expanded(
              child: Container(
                child: children[i],
              ),
            )
          else
            const Spacer(),
          if (i < crossAxisCount - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

enum _Type { normal, simple, builder }
