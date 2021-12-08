import 'package:flutter/material.dart';

class PageItem extends StatefulWidget {
  final int index;
  PageItem(this.index, {Key? key}) : super(key: key);

  @override
  _PageItemState createState() => _PageItemState();
}

class _PageItemState extends State<PageItem>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build index:${widget.index} page');
    return Container(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          '${widget.index}',
          style: TextStyle(
              color: Colors.black, fontSize: 190, fontWeight: FontWeight.bold),
        ),
        Text(
          '${DateTime.now()}',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ]),
      alignment: Alignment.center,
    );
  }

  @override
  // bool get wantKeepAlive => false;
  bool get wantKeepAlive => true;
}
