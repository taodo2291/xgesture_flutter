import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'dart:math' as Math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setEnabledSystemUIOverlays([]);
  runApp(
    MaterialApp(
      home: CanvasGestureExample(),
    ),
  );
}

Future<void> setEnabledSystemUIOverlays(List<String> overlays) async {
  await SystemChannels.platform
      .invokeMethod<void>('SystemChrome.setEnabledSystemUIOverlays', overlays);
}

class CanvasGestureExample extends StatelessWidget {
  final Model model = Model.createDefault();

  @override
  Widget build(BuildContext context) {
    return XGestureDetector(
      child: CustomPaint(
        child: Material(
          child: Center(child: Text('Try some gestures')),
        ),
        foregroundPainter: MyPainter(model),
      ),
      onScaleStart: (initialFocusPoint) =>
          model.startScaleRotate(initialFocusPoint),
      onScaleUpdate: (changedFocusPoint, scale, rotationAngle) =>
          model.updateScaleRotate(scale, changedFocusPoint, rotationAngle),
      onScaleEnd: () => model.staging(),
      onMoveUpdate: (localPos, position, localDelta, delta) =>
          model.moveMNode(localDelta),
      onDoubleTap: (localPos, position) => model.overlap(localPos),
      onLongPress: (pointer, localPos, position) => model.setFNodePos(position),
      onTap: (pointer, localPos, position) => model.setMNodePos(position),
      bypassTapEventOnDoubleTap: true,
    );
  }
}

class MyPainter extends CustomPainter {
  Model paintModel;
  MyPainter(this.paintModel) : super(repaint: paintModel);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.lightGreen[300], BlendMode.color);
    canvas.scale(paintModel.scale);

    Paint nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.yellow;

    canvas.drawCircle(paintModel.fNode.displayPos,
        paintModel.fNode.radius.toDouble(), nodePaint);

    TextPainter textPainter = TextPainter(
        textAlign: TextAlign.justify, textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
        text: 'F', style: TextStyle(fontSize: 30, color: Colors.black));
    textPainter.layout(minWidth: 0);

    textPainter.paint(
        canvas,
        Offset(paintModel.fNode.displayPos.dx - textPainter.size.width / 2,
            paintModel.fNode.displayPos.dy - textPainter.size.height / 2));

    canvas.drawCircle(paintModel.mNode.displayPos,
        paintModel.mNode.radius.toDouble(), nodePaint..color = Colors.black);

    textPainter.text = TextSpan(text: 'M', style: TextStyle(fontSize: 30));
    textPainter.layout(minWidth: 0);
    textPainter.paint(
        canvas,
        Offset(paintModel.mNode.displayPos.dx - textPainter.size.width / 2,
            paintModel.mNode.displayPos.dy - textPainter.size.height / 2));

    if (paintModel.shouldDrawControlPoint) {
      canvas.drawCircle(paintModel.focalPoint / paintModel.scale,
          4 / paintModel.scale, Paint());
      canvas.drawCircle(paintModel.focalPoint / paintModel.scale,
          2 / paintModel.scale, Paint()..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Model extends ChangeNotifier {
  Node fNode;
  Node mNode;
  double baseScale;
  double _scale = 1.0;
  double _rotate = 0;
  Offset _originFocalPoint = Offset(0, 0);
  Offset _focalPoint = Offset(0, 0);
  Offset _startPoint = Offset(0, 0);
  bool shouldDrawControlPoint = false;

  get scale => baseScale * _scale;
  get rotate => _rotate;
  get focalPoint => _focalPoint;

  get originFocalPoint => _originFocalPoint;

  Model(this.fNode, this.mNode, this.baseScale, this._rotate);

  static createDefault() {
    Node fNode = Node(Offset(100, 100), 30);
    Node mNode = Node(Offset(100, 300), 30);
    return Model(fNode, mNode, 1.0, 0.0);
  }

  void updateScaleRotate(
      double newScale, Offset changedFocusPoint, double newRotation) {
    _scale = newScale;
    _rotate = newRotation;

    _startPoint = _originFocalPoint - _focalPoint / scale;

    mNode.displayPos =
        rotateOffset(_originFocalPoint, mNode.pos, _rotate) - _startPoint;
    fNode.displayPos =
        rotateOffset(_originFocalPoint, fNode.pos, _rotate) - _startPoint;

    notifyListeners();
  }

  Offset rotateOffset(Offset centerPos, Offset currentPos, double angle) {
    double distance = (currentPos - centerPos).distance;
    double finalAngle =
        Math.atan2(currentPos.dx - centerPos.dx, currentPos.dy - centerPos.dy) -
            angle;

    return Offset(centerPos.dx + distance * Math.sin(finalAngle),
        centerPos.dy + distance * Math.cos(finalAngle));
  }

  void staging() {
    this.baseScale *= this._scale;
    this._scale = 1.0;
    updateModel(_originFocalPoint, _focalPoint, _rotate);
    this._rotate = 0.0;
    shouldDrawControlPoint = false;
  }

  void updateModel(Offset oFocalPoint, Offset focalPoint, double rotateValue) {
    mNode.pos = mNode.displayPos + _startPoint;
    fNode.pos = fNode.displayPos + _startPoint;
  }

  void moveMNode(Offset delta) {
    this.mNode.pos += delta / scale;
    this.mNode.displayPos += delta / scale;
    notifyListeners();
  }

  void overlap(Offset pos) {
    this.mNode.pos = _startPoint + pos / scale;
    this.mNode.displayPos =
        rotateOffset(_originFocalPoint, mNode.pos, _rotate) - _startPoint;

    this.fNode.pos = this.mNode.pos.translate(30, 15);
    this.fNode.displayPos =
        rotateOffset(_originFocalPoint, fNode.pos, _rotate) - _startPoint;

    notifyListeners();
  }

  void setMNodePos(Offset pos) {
    this.mNode.pos = _startPoint + pos / scale;
    this.mNode.displayPos =
        rotateOffset(_originFocalPoint, mNode.pos, _rotate) - _startPoint;
    notifyListeners();
  }

  void setFNodePos(Offset pos) {
    this.fNode.pos = _startPoint + pos / scale;
    this.fNode.displayPos =
        rotateOffset(_originFocalPoint, fNode.pos, _rotate) - _startPoint;
    notifyListeners();
  }

  void startScaleRotate(Offset initialFocusPoint) {
    _originFocalPoint =
        (initialFocusPoint - _focalPoint) / scale + _originFocalPoint;
    _focalPoint = initialFocusPoint;
    shouldDrawControlPoint = true;
  }
}

class Node {
  Offset pos;
  int radius;
  Offset displayPos;

  Node(this.pos, this.radius) {
    displayPos = this.pos;
  }
}
