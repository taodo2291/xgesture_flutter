import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';

void main() {
  runApp(
    MaterialApp(
      home: XGestureExample(),
    ),
  );
}

class XGestureExample extends StatefulWidget {
  @override
  _XGestureExampleState createState() => _XGestureExampleState();
}

class _XGestureExampleState extends State<XGestureExample> {
  String lastEventName = 'Tap on screen';

  @override
  Widget build(BuildContext context) {
    return XGestureDetector(
      child: Material(
        child: Center(
          child: Text(
            lastEventName,
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
      doubleTapTimeConsider: 300,
      longPressTimeConsider: 350,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onMoveStart: onMoveStart,
      onMoveEnd: onMoveEnd,
      onMoveUpdate: onMoveUpdate,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
      bypassTapEventOnDoubleTap: false,
    );
  }

  void onScaleEnd() {
    setLastEventName('onScaleEnd');
    print('onScaleEnd');
  }

  void onScaleUpdate(changedFocusPoint, scale) {
    setLastEventName('onScaleUpdate');
    print(
        'onScaleUpdate - changedFocusPoint:  $changedFocusPoint ; scale: $scale');
  }

  void onScaleStart(initialFocusPoint) {
    setLastEventName('onScaleStart');
    print('onScaleStart - initialFocusPoint: ' + initialFocusPoint.toString());
  }

  void onMoveUpdate(localPos, position, localDelta, delta) {
    setLastEventName('onMoveUpdate');
    print('onMoveUpdate - pos: ' + localPos.toString());
  }

  void onMoveEnd(pointer, localPos, position) {
    setLastEventName('onMoveEnd');
    print('onMoveEnd - pos: ' + localPos.toString());
  }

  void onMoveStart(pointer, localPos, position) {
    setLastEventName('onMoveStart');
    print('onMoveStart - pos: ' + localPos.toString());
  }

  void onLongPress(pointer, localPos, position) {
    setLastEventName('onLongPress');
    print('onLongPress - pos: ' + localPos.toString());
  }

  void onDoubleTap(localPos, position) {
    setLastEventName('onDoubleTap');
    print('onDoubleTap - pos: ' + localPos.toString());
  }

  void onTap(pointer, localPos, position) {
    setLastEventName('onTap');
    print('onTap - pos: ' + localPos.toString());
  }

  void setLastEventName(String eventName) {
    setState(() {
      lastEventName = eventName;
    });
  }
}