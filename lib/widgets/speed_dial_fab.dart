import 'package:flutter/material.dart';

class SpeedDialFab extends StatefulWidget {
  final Function()? onPressed;
  final String? tooltip;
  final IconData? icon;
  final Color? buttonClosedColor;
  final Color? buttonOpenedColor;
  final List<Widget> children;

  const SpeedDialFab({
    super.key,
    this.onPressed,
    this.tooltip,
    this.icon,
    @Deprecated("Was never used") this.buttonClosedColor,
    @Deprecated("Was never used") this.buttonOpenedColor,
    required this.children,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  late AnimationController _animationController;
  late Animation<double> _opacity;
  late Animation<double> _animateIcon;
  late Animation<double> _translateButton;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 56.0;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });

    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.easeOut,
      ),
    ));

    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggle(BuildContext context) {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var l = widget.children.length;
    var children = widget.children
        .asMap()
        .map((index, w) => MapEntry<int, Widget>(
            index,
            Transform(
              transform: Matrix4.translationValues(
                0.0,
                _translateButton.value * (l--),
                0.0,
              ),
              child: Opacity(
                opacity: _opacity.value,
                child: w,
              ),
            )))
        .entries
        .map((e) => e.value)
        .toList();

    children.add(toggle(context));

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: children,
    );
  }
}
