import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomItemPray extends StatelessWidget {
  CustomItemPray(
      {@required this.title,
      @required this.time,
      @required this.active,
      @required this.onSwitch});
  final title;
  final time;
  final active;
  final Function onSwitch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title',
              style: TextStyle(fontSize: 20.0, color: Colors.green[200]),
            ),
            Row(
              children: [
                Text(
                  '$time',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700]),
                ),
                SizedBox(
                  width: 10.0,
                ),
                CupertinoSwitch(value: this.active, onChanged: this.onSwitch)
              ],
            )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        const Divider(
          color: Colors.grey,
          height: 1,
          thickness: 0.4,
          indent: 0,
          endIndent: 0,
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
