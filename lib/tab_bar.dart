library flutter_custom_tab_bar;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tabs/library.dart';

import '../indicator/custom_indicator.dart';
import 'models.dart';

final Duration animDuration = Duration(milliseconds: 300);

typedef IndexedTabBarItemBuilder = Widget Function(
    BuildContext context, int index);

class CustomTabBar extends StatefulWidget {
  final IndexedTabBarItemBuilder builder;
  final int itemCount;
  final int initialIndex;
  final PageController pageController;
  final CustomIndicator? indicator;
  final Color backgroundColor;
  final ValueChanged<int> onTapItem;
  final double? height;
  final double? width;
  final Alignment alignment;
  final ScrollPhysics physics;

  const CustomTabBar(
      {required this.builder,
      required this.itemCount,
      required this.pageController,
      required this.onTapItem,
      this.indicator,
      this.backgroundColor = Colors.transparent,
      this.initialIndex = 0,
      this.width,
      this.height,
      this.alignment = Alignment.center,
      this.physics = const AlwaysScrollableScrollPhysics(),
      Key? key})
      : assert((physics is NeverScrollableScrollPhysics && height == null) ||
            !(physics is NeverScrollableScrollPhysics) && height != null),
        super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late List<Size> sizeList =
      List.generate(widget.itemCount, (index) => Size(0, 0));
  ScrollController? _scrollController;
  CustomTabBarController _tabBarController = CustomTabBarController();
  late int currentIndex = widget.initialIndex;
  ValueNotifier<IndicatorPosition> positionNotifier =
      ValueNotifier(IndicatorPosition(0, 0));
  late ValueNotifier<ScrollProgressInfo>? progressNotifier =
      TabsContext.of(context)?.progressNotifier;
  double get getCurrentPage => widget.pageController.page ?? 0;

  double indicatorLeft = 0;
  double indicatorRight = 0;
  bool isJumpPage = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      progressNotifier?.value = ScrollProgressInfo(currentIndex: currentIndex);
    });

    positionNotifier.addListener(() {
      setState(() {
        indicatorLeft = positionNotifier.value.left;
        indicatorRight = positionNotifier.value.right;
      });
    });

    if (!(widget.physics is NeverScrollableScrollPhysics)) {
      _scrollController = ScrollController();
    }

    widget.pageController.addListener(() {
      if (isJumpPage) return;
      if (currentIndex == getCurrentPage) return;
      currentIndex = getCurrentPage.toInt();

      _tabBarController.scrollByPageView(getViewportWidth() / 2, sizeList,
          _scrollController, widget.pageController);

      ScrollProgressInfo? scrollProgressInfo = _tabBarController
          .updateScrollProgressByPageView(currentIndex, widget.pageController);
      if (scrollProgressInfo != null) {
        progressNotifier?.value = scrollProgressInfo;
      }

      widget.indicator?.updateScrollIndicator(
          getCurrentPage, sizeList, animDuration, positionNotifier);
    });
  }

  double getViewportWidth() {
    if (widget.width != null) {
      return widget.width!;
    }

    if (_viewportWidth == 0) {
      return MediaQuery.of(context).size.width;
    }
    return _viewportWidth;
  }

  double _viewportWidth = 0;
  double? getViewportHeight() {
    if (widget.physics is NeverScrollableScrollPhysics) {
      return null;
    }
    return widget.height;
  }

  @override
  void dispose() {
    super.dispose();
    progressAnimationController?.stop(canceled: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: widget.alignment,
        height: getViewportHeight(),
        width: getViewportWidth(),
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: widget.physics is NeverScrollableScrollPhysics
            ? _buildTabBarItemRow()
            : MeasureSizeBox(
                onSizeCallback: (size) {
                  _viewportWidth = size.width;
                },
                child: Scrollable(
                  controller: _scrollController,
                  viewportBuilder: _buildViewport,
                  axisDirection: AxisDirection.right,
                  physics: widget.physics,
                )));
  }

  Widget _buildViewport(BuildContext context, ViewportOffset offset) {
    return Viewport(
      offset: offset,
      axisDirection: AxisDirection.right,
      slivers: [_buildSlivers()],
    );
  }

  ///点击tabbar Item
  void _onTapItem(int index) {
    if (currentIndex == index) return;
    widget.onTapItem(index);
    isJumpPage = true;
    updateProgressByAnimation(currentIndex, index);

    _tabBarController.scrollTargetToCenter(getViewportWidth() / 2, index,
        sizeList, _scrollController, animDuration);

    widget.indicator?.indicatorScrollToIndex(
        index, sizeList, animDuration, this, positionNotifier);

    currentIndex = index;
  }

  AnimationController? progressAnimationController;
  Animation? progressAnimation;

  ///通过动画更新进度
  void updateProgressByAnimation(int currentIndex, int targetIndex) {
    progressAnimationController =
        AnimationController(vsync: this, duration: animDuration);
    Animation animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(progressAnimationController!);

    animation.addListener(() {
      if (!mounted) return null;
      progressNotifier!.value = ScrollProgressInfo(
          progress: animation.value,
          currentIndex: currentIndex,
          targetIndex: targetIndex);
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isJumpPage = false;
      }
    });
    progressAnimationController?.forward();
  }

  ///是否已经测量TabBarItem的size
  bool isMeasureTabBarItemSize() {
    for (int i = 0; i < sizeList.length; i++) {
      if (sizeList[i].width == 0) {
        return false;
      }
    }

    return true;
  }

  //构建指示器
  Widget _buildIndicator() {
    if (!isMeasureTabBarItemSize()) return SizedBox();
    return Positioned(
      key: widget.key,
      left: indicatorLeft,
      right: indicatorRight,
      bottom: widget.indicator?.bottom,
      top: widget.indicator?.top,
      child: Container(
        width: widget.indicator?.width,
        height: widget.indicator?.height,
        decoration: BoxDecoration(
          color: widget.indicator?.color,
          borderRadius: widget.indicator?.radius,
        ),
      ),
    );
  }

  Widget _buildTabBarItemRow() {
    return Stack(children: [
      if (widget.indicator != null) _buildIndicator(),
      TabBarItemRow(
        viewPortWidth: widget.physics is NeverScrollableScrollPhysics
            ? getViewportWidth()
            : null,
        physics: widget.physics,
        builder: widget.builder,
        onTapItem: _onTapItem,
        itemCount: widget.itemCount,
        sizeList: sizeList,
        onMeasureCompleted: () {
          print('onMeasureCompleted');
          WidgetsBinding.instance?.addPostFrameCallback((d) {
            setState(() {
              widget.indicator?.updateScrollIndicator(
                  getCurrentPage, sizeList, animDuration, positionNotifier);
            });
          });
        },
      )
    ]);
  }

  Widget _buildSlivers() {
    return SliverList(
        delegate: SliverChildListDelegate([_buildTabBarItemRow()]));
  }
}

class TabBarItemRow extends StatefulWidget {
  final double? viewPortWidth;
  final int itemCount;
  final IndexedWidgetBuilder builder;
  final List<Size> sizeList;
  final ValueChanged<int> onTapItem;
  final ScrollPhysics physics;
  final VoidCallback onMeasureCompleted;

  TabBarItemRow(
      {required this.viewPortWidth,
      required this.itemCount,
      required this.builder,
      required this.sizeList,
      required this.onTapItem,
      required this.physics,
      required this.onMeasureCompleted,
      key})
      : super(key: key);

  @override
  TabBarItemRowState createState() => TabBarItemRowState();
}

class TabBarItemRowState extends State<TabBarItemRow> {
  bool isMeasureCompletedCallback = false;

  Widget _createItem(int index, Widget child) {
    return GestureDetector(onTap: () => widget.onTapItem(index), child: child);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];

    ///如果不能滑动就平分父级组件宽度
    if (widget.physics is NeverScrollableScrollPhysics) {
      double? itemWidth = (widget.viewPortWidth ?? 0) / widget.itemCount;
      for (var i = 0; i < widget.itemCount; i++) {
        widgetList.add(_createItem(
            i,
            Container(
              width: itemWidth,
              child: widget.builder(context, i),
            )));
        widget.sizeList[i] = Size(itemWidth, 0);
      }
      if (!isMeasureCompletedCallback) {
        widget.onMeasureCompleted();
        isMeasureCompletedCallback = true;
      }
    } else {
      for (var i = 0; i < widget.itemCount; i++) {
        widgetList.add(_createItem(
            i,
            MeasureSizeBox(
              child: widget.builder(context, i),
              onSizeCallback: (size) {
                if (!size.isEmpty && !isMeasureCompletedCallback) {
                  widget.onMeasureCompleted();
                  isMeasureCompletedCallback = true;
                }
                widget.sizeList[i] = size;
              },
            )));
      }
    }

    return Row(children: widgetList);
  }
}

class MeasureSizeBox extends SingleChildRenderObjectWidget {
  final Widget child;
  final ValueChanged<Size> onSizeCallback;

  MeasureSizeBox({
    required this.child,
    required this.onSizeCallback,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderConstrainedBox(onSizeCallback: this.onSizeCallback);
  }
}

class _RenderConstrainedBox extends RenderConstrainedBox {
  final ValueChanged<Size> onSizeCallback;

  _RenderConstrainedBox({required this.onSizeCallback})
      : super(additionalConstraints: BoxConstraints());

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    super.layout(constraints, parentUsesSize: parentUsesSize);

    if (size.isEmpty) return;
    onSizeCallback(Size.copy(size));
  }
}

class TabBarItem extends StatefulWidget {
  final Widget? child;
  final int index;
  final TabBarTransform? transform;
  TabBarItem({
    Key? key,
    this.child,
    required this.index,
    this.transform,
  }) : super(key: key);

  @override
  _TabBarItemState createState() => _TabBarItemState();
}

class _TabBarItemState extends State<TabBarItem> {
  ValueNotifier<ScrollProgressInfo>? progressNotifier;
  ScrollProgressInfo? info;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      progressNotifier = TabsContext.of(context)?.progressNotifier;
      setState(() {
        info = progressNotifier!.value;
      });
      progressNotifier?.addListener(() {
        setState(() {
          info = progressNotifier!.value;
        });
      });
      assert(progressNotifier != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (info == null) return SizedBox();
    if (widget.transform != null) {
      return widget.transform!.build(context, widget.index, info!);
    }

    return Container(
      child: widget.child,
    );
  }
}
