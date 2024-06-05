import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListTileCustom extends StatefulWidget {
  ListTileCustom({
    super.key,
    required this.index,
    required this.snapshot,
  });

  final AsyncSnapshot<dynamic> snapshot;
  final int index;
  List<ListTile> selectedImageList = List.empty();
  @override
  State<ListTileCustom> createState() => _ListTileCustomState();
}

class _ListTileCustomState extends State<ListTileCustom> {
  int click = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ListTile(
          leading: (widget.snapshot.data[widget.index]!),
          onTap: () {
            click += 1;
            if (click == 1) {
              print("first click");
              widget.selectedImageList.add(widget.snapshot.data[widget.index]!);
            } else if (click == 2) {
              print("second click");
              widget.selectedImageList.add(widget.snapshot.data[widget.index]!);
              if (widget.selectedImageList.length == 2) {
                ListTile temp;
                int lastIndex = ((widget.selectedImageList.length) - 1);
                temp = widget.selectedImageList.removeLast();

                //widget.selectedImageList[]
              }
              setState(() {
                super.initState();
              });
              click = 0;
            } else {}
          }),
    );
  }
}
