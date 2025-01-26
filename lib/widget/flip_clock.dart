import 'dart:async';

import 'package:flutter/material.dart';

import 'flip_clock_builder.dart';
import 'flip_widget.dart';

/// FlipClock display with current time.
///
/// Display a row of [FlipWidget] to show the current time digits,
/// this digits are refreshed by a stream of [DateTime].now() instances.
/// Since FlipWidget animates only changes, just digits that actually
/// change between seconds are flipped.
class FlipClock extends StatefulWidget {
  /// FlipClock constructor.
  ///
  /// Parameters define clock digits and flip panel appearance.
  /// - flipDirection defaults to AxisDirection.down.
  /// - flipCurve defaults to FlipWidget.bounceFastFlip when direction is down, to FlipWidget.defaultFlip otherwise
  /// - digitColor and separatorColor defaults to colorScheme.onPrimary.
  /// - backgroundColor defauts to colorScheme.primary.
  /// - separatorWidth defaults to width / 3.
  /// - separatorColor defaults to colorScheme.onPrimary.
  /// - separatorBackground defaults to null (transparent).
  /// - showBorder can be set or defaults to true if boderColor or borderWidth is set
  /// - borderWidth defaults to 1.0 when a borderColor is set
  /// - borderColor defaults to colorScheme.onPrimary when a width is set.
  /// - borderRadius defaults to Radius.circular(4.0)
  /// - hingeWidth defaults to 0.8
  /// - hindeLength defaults to CrossAxis size
  /// - hingeColor defaults to null (transparent)
  /// - digitSpacing defaults to horizontal: 2.0
  FlipClock({
    Key? key,
    required double digitSize,
    required double width,
    required double height,
    AxisDirection flipDirection = AxisDirection.down,
    this.showSeconds = true,
    Curve? flipCurve,
    Color? digitColor,
    Color? backgroundColor,
    double? separatorWidth,
    Color? separatorColor,
    Color? separatorBackgroundColor,
    bool? showBorder,
    double? borderWidth,
    Color? borderColor,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    double hingeWidth = 0.8,
    double? hingeLength,
    Color? hingeColor,
    EdgeInsets digitSpacing = const EdgeInsets.fromLTRB(0, 0, 2, 0),
  })  : assert(hingeLength == null || hingeWidth == 0.0 && hingeLength == 0.0 || hingeWidth > 0.0 && hingeLength > 0.0),
        assert((borderWidth == null && borderColor == null) || (showBorder == null || showBorder == true)),
        _displayBuilder = FlipClockBuilder(
          digitSize: digitSize,
          width: width,
          height: height,
          flipDirection: flipDirection,
          flipCurve:
              flipCurve ?? (flipDirection == AxisDirection.down ? FlipWidget.bounceFastFlip : FlipWidget.defaultFlip),
          digitColor: digitColor,
          backgroundColor: backgroundColor,
          separatorWidth: separatorWidth ?? width / 3.0,
          separatorColor: separatorColor,
          separatorBackgroundColor: separatorBackgroundColor,
          showBorder: showBorder ?? (borderColor != null || borderWidth != null),
          borderWidth: borderWidth,
          borderColor: borderColor,
          borderRadius: borderRadius,
          hingeWidth: hingeWidth,
          hingeLength: hingeWidth == 0.0
              ? 0.0
              : hingeLength ??
                  (flipDirection == AxisDirection.down || flipDirection == AxisDirection.up ? width : height),
          hingeColor: hingeColor,
          digitSpacing: digitSpacing,
        ),
        super(key: key);

  /// Builder with common code for all FlipClock types.
  ///
  /// This builder is created with most of my constructor parameters
  final FlipClockBuilder _displayBuilder;

  final bool showSeconds;

  @override
  State<FlipClock> createState() => _FlipClockState();
}

class _FlipClockState extends State<FlipClock> {
  late final StreamController<DateTime> _streamController;
  Timer? _timer;
  late DateTime _lastDateTime;

  @override
  void initState() {
    super.initState();
    _lastDateTime = DateTime.now();
    _initializeTimer();
  }

  void _initializeTimer() {
    _streamController = StreamController<DateTime>.broadcast();
    _streamController.add(_lastDateTime);

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!_streamController.isClosed) {
          final now = DateTime.now();
          if (_shouldUpdateTime(now)) {
            _lastDateTime = now;
            _streamController.add(now);
          }
        }
      },
    );
  }

  bool _shouldUpdateTime(DateTime newTime) {
    if (!widget.showSeconds) {
      return newTime.minute != _lastDateTime.minute;
    }
    return newTime.second != _lastDateTime.second;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHourDisplay(),
        widget._displayBuilder.buildSeparator(context),
        _buildMinuteDisplay(),
        if (widget.showSeconds) ...[
          widget._displayBuilder.buildSeparator(context),
          _buildSecondDisplay(),
        ],
      ],
    );
  }

  Widget _buildHourDisplay() => widget._displayBuilder.buildTimePartDisplay(
        _streamController.stream.map((time) => time.hour),
        _lastDateTime.hour,
      );

  Widget _buildMinuteDisplay() => widget._displayBuilder.buildTimePartDisplay(
        _streamController.stream.map((time) => time.minute),
        _lastDateTime.minute,
      );

  Widget _buildSecondDisplay() => widget._displayBuilder.buildTimePartDisplay(
        _streamController.stream.map((time) => time.second),
        _lastDateTime.second,
        isSecondPart: true,
      );

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    super.dispose();
  }
}
