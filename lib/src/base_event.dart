import 'package:flutter/widgets.dart';

enum MoveBehavior { byPassForLongPress, countForLongPress }

enum TapBehavior { byPassForDoubleTap, countForDoubleTap }

/// The pointer has moved with respect to the device while the pointer is in
/// contact with the device.
///
/// See also:
///
///  * [XGestureDetector.onMoveUpdate], which allows callers to be notified of these
///    events in a widget tree.
///  * [XGestureDetector.onMoveStart], which allows callers to be notified for the first time this event occurs
///  * [XGestureDetector.onMoveEnd], which allows callers to be notified after the last move event occurs.
@immutable
class MoveEvent extends TapEvent {
  /// The [delta] transformed into the event receiver's local coordinate
  /// system according to [transform].
  ///
  /// If this event has not been transformed, [delta] is returned as-is.
  ///
  /// See also:
  ///
  ///  * [delta], which is the distance the pointer moved in the global
  ///    coordinate system of the screen.
  final Offset localDelta;

  /// Distance in logical pixels that the pointer moved since the last
  /// [MoveEvent].
  ///
  /// See also:
  ///
  ///  * [localDelta], which is the [delta] transformed into the local
  ///    coordinate space of the event receiver.
  final Offset delta;

  const MoveEvent(
    Offset localPos,
    Offset position,
    int pointer, {
    this.localDelta = const Offset(0, 0),
    this.delta = const Offset(0, 0),
  }) : super(localPos, position, pointer);
}

/// The pointer  has made a move.
///
/// See also:
///
///  * [XGestureDetector.onMoveUpdate], which allows callers to be notified of these
///    events in a widget tree.
@immutable
class TapEvent {
  /// Unique identifier for the pointer, not reused. Changes for each new
  /// pointer down event.
  final int pointer;

  /// The [position] transformed into the event receiver's local coordinate
  /// system according to [transform].
  ///
  /// If this event has not been transformed, [position] is returned as-is.
  /// See also:
  ///
  ///  * [position], which is the position in the global coordinate system of
  ///    the screen.
  final Offset localPos;

  /// Coordinate of the position of the pointer, in logical pixels in the global
  /// coordinate space.
  ///
  /// See also:
  ///
  ///  * [localPosition], which is the [position] transformed into the local
  ///    coordinate system of the event receiver.
  final Offset position;

  const TapEvent(this.localPos, this.position, this.pointer);

  static from(PointerEvent event) {
    return TapEvent(event.localPosition, event.position, event.pointer);
  }
}

/// Two pointers has made contact with the device.
///
/// See also:
///
///  * [XGestureDetector.onScaleUpdate], which allows callers to be notified of these
///    events in a widget tree.
@immutable
class ScaleEvent {
  /// the middle point between 2 pointers(causes by 2 touching fingers)
  final Offset focalPoint;

  /// The delta distances of 2 pointers between the current and the previous
  final double scale;

  /// the rotate angle in radians - using for rotate
  final double rotationAngle;

  const ScaleEvent(this.focalPoint, this.scale, this.rotationAngle);
}

/// Signature for listening to [ScaleEvent] events.
///
/// Used by [XGestureDetector].
typedef ScaleEventListener = void Function(ScaleEvent event);

/// Signature for listening to [TapEvent] events.
///
/// Used by [XGestureDetector].
typedef TapEventListener = void Function(TapEvent event);

/// Signature for listening to [MoveEvent] events.
///
/// Used by [XGestureDetector].
typedef MoveEventListener = void Function(MoveEvent event);
