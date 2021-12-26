import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';

class Tabs extends StatefulWidget {
  final List<Widget> pages;
  final IndexedTabBarItemBuilder tabBarItemBuilder;
  final CustomIndicator? indicator;
  final int initialPage;
  final double tabbarHeight;
  final double? tabbarWidth;
  final bool pinned;
  Tabs({
    Key? key,
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
          duration: kCustomerTabBarAnimDuration, curve: Curves.easeIn);
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
        duration: kCustomerTabBarAnimDuration, curve: Curves.easeIn);
    _pageController.jumpToPage(index);

    WidgetsBinding.instance?.addPostFrameCallback((Duration duration) {
      setState(() {
        pageList = [...widget.pages];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTabBar(
          initialIndex: widget.initialPage,
          height: widget.pinned ? null : widget.tabbarHeight,
          pinned: widget.pinned,
          width: widget.tabbarWidth,
          itemCount: widget.pages.length,
          onTapItem: onTapTabBarItem,
          builder: widget.tabBarItemBuilder,
          pageController: _pageController,
          indicator: widget.indicator,
          controlJump: false,
        ),
        Expanded(
            child: PageView(
          controller: _pageController,
          children: pageList,
          // childrenDelegate: _sliverChildBuilderDelegate,
        ))
      ],
    );
  }
}
