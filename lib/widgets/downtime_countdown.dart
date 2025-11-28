import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:sweet/util/constants.dart';

import 'package:sweet/service/manup/manup_service.dart';

class DowntimeCountdown extends StatelessWidget {
  DateTime _calculateNextDownTime({
    required int patchDay,
    required int patchHour,
    required int patchMin,
  }) {
    final currentUTC = DateTime.now().toUtc();
    var downtimeDateUTC = DateTime.utc(
      currentUTC.year,
      currentUTC.month,
      currentUTC.day,
      patchHour,
      patchMin,
    );

    var offset = (downtimeDateUTC.weekday - patchDay);
    if (downtimeDateUTC.weekday > patchDay) {
      offset = DateTime.daysPerWeek - offset;
    } else if (downtimeDateUTC.weekday == patchDay &&
        currentUTC.isAfter(downtimeDateUTC)) {
      offset = DateTime.daysPerWeek;
    } else {
      offset *= -1; // flip the sign
    }

    downtimeDateUTC = downtimeDateUTC.add(Duration(days: offset));

    return downtimeDateUTC;
  }

  String zeroPadInt(int value, {int width = 2}) =>
      value.toString().padLeft(width, '0');

  @override
  Widget build(BuildContext context) {
    final patchDay = RepositoryProvider.of<ManUpService>(context)
        .setting(key: kPatchDayManUpKey, orElse: DateTime.thursday);
    final patchHour = RepositoryProvider.of<ManUpService>(context)
        .setting(key: kPatchHourManUpKey, orElse: 0);
    final patchMin = RepositoryProvider.of<ManUpService>(context)
        .setting(key: kPatchMinuteManUpKey, orElse: 0);
    final style = TextStyle(color: Colors.white);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DT: ',
            style: style,
          ),
          CountdownTimer(
            endTime: _calculateNextDownTime(
              patchDay: patchDay,
              patchHour: patchHour,
              patchMin: patchMin,
            ).millisecondsSinceEpoch,
            widgetBuilder: (_, CurrentRemainingTime? time) {
              final days = time?.days ?? 0;
              final hours = time?.hours ?? 0;
              final mins = time?.min ?? 0;
              return Text(
                '${days}d ${zeroPadInt(hours)}:${zeroPadInt(mins)}',
                style: style,
              );
            },
          ),
        ],
      ),
    );
  }
}
