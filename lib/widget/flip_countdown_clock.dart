import 'dart:async';

import 'package:flutter/material.dart';

import 'flip_clock_builder.dart';

/// FlipCountdownClock display a countdown flip clock.
///
/// Dispaly a row of [FlipWidget] to show the countdown digits,
/// this digits are refreshed by a stream of time left [Duration] instances,
/// Since FlipWidget only animate changes, only digits that actually
/// change between seconds are flipped.
///
/// Most constructor parameters are required to define digits appearance,
/// some parameters are optional, configuring flip panel appearance.
class FlipCountdownClock extends StatefulWidget {
  /// FlipCountdownClock constructor.
  ///
  /// Parameters define clock digits and flip panel appearance.
  /// - flipDirection defaults to AxisDirection.up.
  /// - flipCurve defaults to null, that will deliver FlipWidget.defaultFlip.
  /// - digitColor and separatorColor defaults to colorScheme.onPrimary.
  /// - backgroundColor defauts to colorScheme.primary.
  /// - separatorWidth defaults to width / 3.
  /// - separatorColor defaults to colorScheme.onPrimary.
  /// - separatorBackground defaults to null (transparent).
  /// - showBorder can be set or defaults to true if boderColor or borderWidth is set
  /// - borderWidth defaults to 1.0 when a borderColor is set
  /// - borderColor defaults to colorScheme.onPrimary when a width is set.
  /// - borderRadius defaults to Radius.circular(4.0)
  /// - digitSpacing defaults to horizontal: 2.0
  /// - hingeWidth defaults to 0.8
  /// - hindeLength defaults to CrossAxis size
  /// - hingeColor defaults to null (transparent)
  FlipCountdownClock({
    Key? key,
    required this.duration,
    required double digitSize,
    required double width,
    required double height,
    AxisDirection flipDirection = AxisDirection.up,
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
    EdgeInsets digitSpacing = const EdgeInsets.symmetric(horizontal: 2.0),
    this.onDone,
  })  : _showHours = duration.inHours > 0,
        _displayBuilder = FlipClockBuilder(
          digitSize: digitSize,
          width: width,
          height: height,
          flipDirection: flipDirection,
          flipCurve: flipCurve,
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

  /// Duration of the countdown.
  final Duration duration;

  /// Optional callback when the countdown is done.
  final VoidCallback? onDone;

  /// Builder with common code for all FlipClock types.
  ///
  /// This builder is created with most of my constructor parameters
  final FlipClockBuilder _displayBuilder;

  final bool _showHours;

  @override
  State<FlipCountdownClock> createState() => _FlipCountdownClockState();
}

class _FlipCountdownClockState extends State<FlipCountdownClock> {
  StreamController<Duration>? _streamController;
  Timer? _timer;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  @override
  void didUpdateWidget(FlipCountdownClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      // 当 duration 改变时，重新初始化计时器
      _disposeTimer();
      _initializeTimer();
    }
  }

  void _initializeTimer() {
    _streamController = StreamController<Duration>.broadcast();
    const step = Duration(seconds: 1);
    _endTime = DateTime.now().add(widget.duration).add(step);

    _timer = Timer.periodic(step, (timer) {
      final now = DateTime.now();
      if (now.isBefore(_endTime!)) {
        _streamController?.add(_endTime!.difference(now));
      } else {
        _streamController?.add(Duration.zero);
        widget.onDone?.call();
        _disposeTimer();
      }
    });

    // 立即发送初始值
    _streamController?.add(widget.duration);
  }

  void _disposeTimer() {
    _timer?.cancel();
    _timer = null;
    _streamController?.close();
    _streamController = null;
  }

  @override
  void dispose() {
    _disposeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_streamController == null) return Container(); // 或其他占位符

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget._showHours) ...[
          _buildHoursDisplay(_streamController!.stream, widget.duration),
          widget._displayBuilder.buildSeparator(context),
        ],
        _buildMinutesDisplay(_streamController!.stream, widget.duration),
        widget._displayBuilder.buildSeparator(context),
        _buildSecondsDisplay(_streamController!.stream, widget.duration),
      ],
    );
  }

  Widget _buildHoursDisplay(Stream<Duration> stream, Duration initValue) =>
      widget._displayBuilder.buildTimePartDisplay(
        stream.map((time) => time.inHours % 24),
        initValue.inHours % 24,
      );

  Widget _buildMinutesDisplay(Stream<Duration> stream, Duration initValue) =>
      widget._displayBuilder.buildTimePartDisplay(
        stream.map((time) => time.inMinutes % 60),
        initValue.inMinutes % 60,
      );

  Widget _buildSecondsDisplay(Stream<Duration> stream, Duration initValue) =>
      widget._displayBuilder.buildTimePartDisplay(
        stream.map((time) => time.inSeconds % 60),
        initValue.inSeconds % 60,
      );
}