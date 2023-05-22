import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sweet/widgets/downtime_countdown.dart';
import 'package:sweet/widgets/utc_clock.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox.fromSize(
                  size: Size.square(48),
                  child: SvgPicture.asset('assets/svg/logo-transparent.svg'),
                ),
              ),
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  UTCClock(),
                  DowntimeCountdown(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
