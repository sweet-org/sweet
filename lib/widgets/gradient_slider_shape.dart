import 'package:flutter/material.dart';


class GradientRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  GradientRectSliderTrackShape({
    this.gradient = const LinearGradient(
      colors: [
        Colors.red,
        Colors.yellow,
      ],
    ),
  }) {
    darkGradient = LinearGradient(
      colors: [
        ...gradient.colors.map((color) => color.withOpacity(0.25)),
      ],
      stops: gradient.stops,
    );
  }

  final LinearGradient gradient;
  late final LinearGradient darkGradient;

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required Offset thumbCenter,
      Offset? secondaryOffset,
      bool isEnabled = true,
      bool isDiscrete = true,
      required TextDirection textDirection}) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
    );

    final activeGradientRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    //print("${trackRect.left}, ${trackRect.right}");

    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius trackActiveRadius = Radius.circular(trackRect.height / 2 + 1);

    final ColorTween activeColorTween = ColorTween(
      begin: sliderTheme.activeTrackColor,
      end: sliderTheme.activeTrackColor,
    );
    final ColorTween inactiveColorTween = ColorTween(
      begin: sliderTheme.inactiveTrackColor,
      end: sliderTheme.inactiveTrackColor,
    );

    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..color = activeColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..shader = darkGradient.createShader(trackRect)
      ..color = inactiveColorTween.evaluate(enableAnimation)!;

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom,
        topLeft: trackActiveRadius, bottomLeft: trackActiveRadius,
      ),
      activePaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom,
        topRight: trackRadius, bottomRight: trackRadius,
      ),
      inactivePaint,
    );
  }
}