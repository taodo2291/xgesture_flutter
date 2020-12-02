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

  void onScaleUpdate(ScaleEvent event) {
    setLastEventName('onScaleUpdate');
    print(
        'onScaleUpdate - changedFocusPoint:  ${event.focalPoint} ; scale: ${event.scale} ;Rotation: ${event.rotationAngle}');
  }

  void onScaleStart(initialFocusPoint) {
    setLastEventName('onScaleStart');
    print('onScaleStart - initialFocusPoint: $initialFocusPoint');
  }

  void onMoveUpdate(MoveEvent event) {
    setLastEventName('onMoveUpdate');
    print('onMoveUpdate - pos: ${event.localPos} delta: ${event.delta}');
  }

  void onMoveEnd(localPos) {
    setLastEventName('onMoveEnd');
    print('onMoveEnd - pos: $localPos');
  }

  void onMoveStart(localPos) {
    setLastEventName('onMoveStart');
    print('onMoveStart - pos: $localPos');
  }

  void onLongPress(TapEvent event) {
    setLastEventName('onLongPress');
    print('onLongPress - pos: ${event.localPos}');
  }

  void onDoubleTap(event) {
    setLastEventName('onDoubleTap');
    print('onDoubleTap - pos: ' + event.localPos.toString());
  }

  void onTap(event) {
    setLastEventName('onTap');
    print('onTap - pos: ' + event.localPos.toString());
  }

  void setLastEventName(String eventName) {
    setState(() {
      lastEventName = eventName;
    });
  }
}
