library gesture_x_detector;

import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'src/base_event.dart';

class XGestureDetectorPlus extends StatefulWidget {
  static const int DEFAULT_DOUBLETAP_CONSIDER_TIME = 250;
  static const int DEFAULT_LONGPRESS_CONSIDER_TIME = 350;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// a flag to enable/disable tap event when double tap event occurs.
  ///
  /// By default it is false, that mean when user double tap on screen: it will trigge 1 double tap event and 2 single tap events
  final TapBehavior tapBehavior;

  ///  by default it is true, means after receive long press event without release pointer (finger still touch on screen)
  /// the move event will be ignore.
  ///
  /// set it to false in case you expect move event will be fire after long press event
  ///
  final MoveBehavior moveBehavior;

  /// A specific duration to detect double tap
  final int doubleTapTimeConsider;

  /// The pointer that previously triggered the onTapDown has also triggered onTapUp which ends up causing a tap.
  final TapEventListener? onTap;

  /// A pointer has contacted the screen with a primary button and has begun to
  /// move.
  final MoveEventListener? onMoveStart;

  /// A pointer that is in contact with the screen with a primary button and
  /// made a move
  final MoveEventListener? onMoveUpdate;

  /// A pointer that was previously in contact with the screen with a primary
  /// button and moving is no longer in contact with the screen and was moving
  /// at a specific velocity when it stopped contacting the screen.
  final TapEventListener? onMoveEnd;

  /// The pointers in contact with the screen have established a focal point and
  /// initial scale of 1.0.
  final void Function(Offset initialFocusPoint)? onScaleStart;

  /// The pointers in contact with the screen have indicated a new focal point
  /// and/or scale.
  final ScaleEventListener? onScaleUpdate;

  /// The pointers are no longer in contact with the screen.
  final void Function()? onScaleEnd;

  /// The user has tapped the screen at the same location twice in quick succession.
  final TapEventListener? onDoubleTap;

  /// A pointer has remained in contact with the screen at the same location for a long period of time
  final TapEventListener? onLongPress;

  /// The pointer are no longer in contact with the screen after onLongPress event.
  final TapEventListener? onLongPressEnd;

  /// A specific duration to detect long press
  final int longPressTimeConsider;

  final HitTestBehavior behavior;

  bool enabledScale;

  final int doubleTapRadiusConsider;

  /// Creates a widget that detects gestures.
  XGestureDetectorPlus(
      {required this.child,
      this.onTap,
      this.onMoveUpdate,
      this.onMoveEnd,
      this.onMoveStart,
      this.onScaleStart,
      this.onScaleUpdate,
      this.onScaleEnd,
      this.onDoubleTap,
      this.moveBehavior = MoveBehavior.byPassForLongPress,
      this.tapBehavior = TapBehavior.byPassForDoubleTap,
      this.doubleTapTimeConsider = DEFAULT_DOUBLETAP_CONSIDER_TIME,
      this.longPressTimeConsider = DEFAULT_LONGPRESS_CONSIDER_TIME,
      this.onLongPress,
      this.onLongPressEnd,
      this.enabledScale = true,
      this.behavior = HitTestBehavior.deferToChild,
      this.doubleTapRadiusConsider = 200});

  @override
  _XGestureDetectorPlusState createState() => _XGestureDetectorPlusState();
}

class _XGestureDetectorPlusState extends State<XGestureDetectorPlus> {
  Map<int, _Touch> touchingCache = new HashMap();
  Map<int, _Touch> touchedCache = new HashMap();
  Map<int, Timer> longPressTimerCache = new HashMap();
  Map<int, Timer> tapTimerCache = new HashMap();
  Set<int> scallingCouplePointers = new HashSet();
  _ScaleAndRotationContext scaleAndRotationContext =
      new _ScaleAndRotationContext(-1, -1, Offset.zero, 0.0, 0.0, false);

  @override
  Widget build(BuildContext context) {
    return Listener(
        behavior: widget.behavior,
        child: widget.child,
        onPointerDown: onPointerDown,
        onPointerUp: onPointerUp,
        onPointerMove: onPointerMove,
        onPointerCancel: onPointerCancel);
  }

  void onPointerDown(PointerDownEvent event) {
    var touch = new _Touch(event.pointer, currentTimeStamp(),
        event.localPosition, _TouchState.Touch);
    touchingCache.putIfAbsent(event.pointer, () => touch);

    longPressTimerCache.putIfAbsent(
        event.pointer, () => getLongPressTimer(event));

    if (touchingCache.length == 2 && widget.enabledScale) {
      _Touch firstTouch = touchedCache.entries
          .firstWhere((element) => element.key != event.pointer)
          .value;
      scaleAndRotationContext.init(firstTouch, touch);
    }
  }

  void onPointerUp(PointerUpEvent event) {
    longPressTimerCache.remove(event.pointer)?.cancel();

    var touch = touchingCache.remove(event.pointer)!;

    switch (touch.state) {
      case _TouchState.LongTouching:
        widget.onLongPressEnd?.call(
            new TapEvent(event.localPosition, event.position, event.pointer));
        break;
      case _TouchState.Moving:
        widget.onMoveEnd?.call(
            new TapEvent(event.localPosition, event.position, event.pointer));
        break;
      case _TouchState.Touch:
        bool isDoubleTapped = false;
        var now = currentTimeStamp();
        if (widget.tapBehavior == TapBehavior.countForDoubleTap) {
          widget.onTap?.call(
              new TapEvent(event.localPosition, event.position, event.pointer));
        } else {
          if (widget.onDoubleTap != null && touchedCache.length > 0) {
            var tapInRanges = touchedCache.values.where((touch) =>
                (touch.position - event.localPosition).distanceSquared <
                widget.doubleTapRadiusConsider);
            if (tapInRanges.isNotEmpty) {
              var latestMatchTap = tapInRanges.reduce((prev, element) =>
                  element.timestamp > prev.timestamp ? element : prev);
              if (now - latestMatchTap.timestamp <=
                  widget.doubleTapTimeConsider) {
                touchedCache.remove(latestMatchTap.touchId);
                tapTimerCache[latestMatchTap.touchId]?.cancel();
                widget.onDoubleTap!.call(new TapEvent(
                    event.localPosition, event.position, event.pointer));
                isDoubleTapped = true;
              }
            }
          }
        }

        if (!isDoubleTapped) {
          touchedCache.putIfAbsent(
              event.pointer,
              () => new _Touch(
                  event.pointer, now, event.position, _TouchState.Released));
          tapTimerCache[event.pointer] = getTapTimer(event);
        }
        break;
      default:
    }
  }

  void onPointerMove(PointerMoveEvent event) {}

  void onPointerCancel(PointerCancelEvent event) {}

  int currentTimeStamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  Timer getLongPressTimer(PointerDownEvent event) {
    return Timer(Duration(milliseconds: widget.longPressTimeConsider), () {
      var longPressEvent =
          new TapEvent(event.localPosition, event.position, event.pointer);
      widget.onLongPress?.call(longPressEvent);
      longPressTimerCache.remove(event.pointer);
      touchingCache[event.pointer]?.state = _TouchState.LongTouching;
      scaleAndRotationContext.reset();
    });
  }

  Timer getTapTimer(PointerUpEvent event) {
    return Timer(Duration(milliseconds: widget.doubleTapTimeConsider), () {
      if (touchedCache.remove(event.pointer) != null) {
        widget.onTap?.call(
            new TapEvent(event.localPosition, event.position, event.pointer));
      }
    });
  }
}

class _Touch {
  int touchId;
  int timestamp;
  Offset position;
  _TouchState state;

  _Touch(this.touchId, this.timestamp, this.position, this.state);
}

enum _TouchState { Touch, Moving, LongTouching, Released }

class _ScaleAndRotationContext {
  int firstPointerId;
  int secondPointerId;
  Offset focalPoint;
  double initialScaleDistance;
  double rotationAngle;
  bool _isReady;

  _ScaleAndRotationContext(
      this.firstPointerId,
      this.secondPointerId,
      this.focalPoint,
      this.initialScaleDistance,
      this.rotationAngle,
      this._isReady);

  void init(_Touch firstTouch, _Touch secondTouch) {}

  void reset() {
    this._isReady = false;
  }

  bool isReady() => this._isReady;
}
