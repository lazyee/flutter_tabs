import 'package:flutter/material.dart';
import 'package:flutter_tabs/library.dart';
import 'package:flutter_tabs/tab_bar.dart';

import '../indicator/custom_indicator.dart';

class TabsContext extends InheritedWidget {
  final ValueNotifier<ScrollProgressInfo> progressNotifier =
      ValueNotifier(ScrollProgressInfo());

  TabsContext({required Widget child, Key? key})
      : super(child: child, key: key);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static TabsContext? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabsContext>(
        aspect: TabsContext);
  }
}

class Tabs extends StatefulWidget {
  final int itemCount;

  final List<Widget> pages;
  final IndexedTabBarItemBuilder tabBarItemBuilder;
  final CustomIndicator? indicator;
  final int initialPage;
  final double tabbarHeight;
  final double? tabbarWidth;
  final bool pinned;
  Tabs({
    Key? key,
    required this.itemCount,
    required this.pages,
    required this.tabBarItemBuilder,
    this.indicator,
    this.pinned = false,
    this.initialPage = 0,
    this.tabbarHeight = 50,
    this.tabbarWidth,
  })  : assert(pinned == false || (pinned == true && tabbarWidth != null)),
        super(key: key);

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  late PageController _pageController =
      PageController(initialPage: widget.initialPage);
  late List<Widget> pageList = [...widget.pages];

  void onTapTabBarItem(int index) async {
    int currentPage = _pageController.page?.floor() ?? 0;

    if (currentPage == index) return;
    if ((currentPage - index).abs() == 1) {
      await _pageController.animateToPage(index,
          duration: animDuration, curve: Curves.easeIn);
      return;
    }

    int quickJumpIndex = 0;
    if (currentPage > index) {
      quickJumpIndex = currentPage - 1;
    } else {
      quickJumpIndex = currentPage + 1;
    }
    pageList[quickJumpIndex] = widget.pages[index];
    setState(() {
      pageList = [...pageList];
    });

    await _pageController.animateToPage(quickJumpIndex,
        duration: animDuration, curve: Curves.easeIn);
    _pageController.jumpToPage(index);

    WidgetsBinding.instance?.addPostFrameCallback((Duration duration) {
      setState(() {
        pageList = [...widget.pages];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TabsContext(
        child: Column(
      children: [
        CustomTabBar(
          initialIndex: widget.initialPage,
          height: widget.pinned ? null : widget.tabbarHeight,
          physics: widget.pinned
              ? NeverScrollableScrollPhysics()
              : BouncingScrollPhysics(),
          width: widget.tabbarWidth,
          itemCount: widget.itemCount,
          onTapItem: onTapTabBarItem,
          builder: widget.tabBarItemBuilder,
          pageController: _pageController,
          indicator: widget.indicator,
        ),
        Expanded(
            child: PageView(
          controller: _pageController,
          children: pageList,
          // childrenDelegate: _sliverChildBuilderDelegate,
        ))
      ],
    ));
  }
}
