import 'package:flutter/material.dart';
import 'package:flutter_custom_tab_bar/library.dart';
import 'package:flutter_tabs/tabs.dart';

import 'page_item.dart';

class StandardTabBarPage extends StatefulWidget {
  StandardTabBarPage({Key? key}) : super(key: key);

  @override
  _StandardTabBarPageState createState() => _StandardTabBarPageState();
}

class _StandardTabBarPageState extends State<StandardTabBarPage> {
  Widget getTabbarChild(BuildContext context, int index) {
    return TabBarItem(
        index: index,
        transform: ScaleTransform(
            maxScale: 1.3,
            transform: ColorsTransform(
              normalColor: Colors.black,
              highlightColor: Colors.green,
              builder: (context, color) {
                return Container(
                    padding: EdgeInsets.all(2),
                    alignment: Alignment.center,
                    constraints: BoxConstraints(minWidth: 70),
                    child: (Text(
                      index == 5 ? 'Tab555555555555' : 'Tab$index',
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                      ),
                    )));
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Standard Indicator')),
        body: Tabs(
          tabBarItemBuilder: getTabbarChild,
          initialPage: 10,
          indicator: StandardIndicator(
              color: Colors.blue,
              width: 20,
              height: 3,
              bottom: 8,
              radius: BorderRadius.circular(2)),
          pages: [
            PageItem(0),
            PageItem(1),
            PageItem(2),
            PageItem(3),
            PageItem(4),
            PageItem(5),
            PageItem(6),
            PageItem(7),
            PageItem(8),
            PageItem(9),
            PageItem(10),
            PageItem(11),
            PageItem(12),
            PageItem(13),
            PageItem(14),
            PageItem(15),
            PageItem(16),
            PageItem(17),
            PageItem(18),
            PageItem(19),
          ],
        ));
  }
}
