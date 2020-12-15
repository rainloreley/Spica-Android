import 'package:flutter/material.dart';
import 'package:spica/Structs/XP.dart';

class XPProgressBarView extends StatefulWidget {
  XPProgressBarView({Key key, @required this.xp, @required this.width})
      : super(key: key);

  XP xp;
  double width;

  @override
  _XPProgressBarViewState createState() => _XPProgressBarViewState();
}

class _XPProgressBarViewState extends State<XPProgressBarView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: widget.width,
                height: 20,
                decoration: BoxDecoration(
                    color: Colors.greenAccent[700].withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              Container(
                width: widget.width * widget.xp.progress,
                height: 20,
                decoration: BoxDecoration(
                    color: Colors.greenAccent[700],
                    borderRadius: BorderRadius.circular(20.0)),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "${widget.xp.total} ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black)),
                    TextSpan(
                        text: "XP",
                        style: TextStyle(
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black))
                  ]),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                      "Lvl. ${widget.xp.level}; ${(widget.xp.progress * 100).round()}% (${widget.xp.levelXP}/${widget.xp.levelXPMax})"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
