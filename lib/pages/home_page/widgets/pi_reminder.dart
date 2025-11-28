import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet/repository/localisation_repository.dart';
import 'package:sweet/service/local_notifications_service.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:sweet/widgets/localised_text.dart';

class PIReminder extends StatefulWidget {
  @override
  State<PIReminder> createState() => _PIReminderState();
}

class _PIReminderState extends State<PIReminder> {
  String zeroPadInt(int value, {int width = 2}) =>
      value.toString().padLeft(width, '0');

  DateTime? endTime;
  String get endTimePrefsKey => 'PIEndTime';

  _PIReminderState() {
    SharedPreferences.getInstance().then((prefs) {
      final msSinceEpoch = prefs.getInt(endTimePrefsKey);

      if (msSinceEpoch != null) {
        setState(() {
          endTime = DateTime.fromMillisecondsSinceEpoch(msSinceEpoch);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationService =
        RepositoryProvider.of<LocalNotificationsService>(context);

    final localiseRepo = RepositoryProvider.of<LocalisationRepository>(context);
    return ListTile(
      leading: Icon(
        Icons.public,
        size: 24,
        color: Theme.of(context).primaryColor,
      ),
      title: LocalisedText(
        localiseId: LocalisationStrings.planetaryInteraction,
      ),
      subtitle: _buildSubtitle(),
      onTap: () => setState(() {
        final duration = Duration(hours: 24);
        final date = DateTime.now().add(duration);
        SharedPreferences.getInstance()
            .then(
              (prefs) =>
                  prefs.setInt(endTimePrefsKey, date.millisecondsSinceEpoch),
            )
            .then(
              (_) => notificationService.scheduleNotification(
                title: localiseRepo.getLocalisedStringForIndex(
                  LocalisationStrings.planetaryInteraction,
                ),
                message: 'Your timer is about to expire', // TODO: Localise
                duration: duration - Duration(hours: 1),
              ),
            );
        endTime = date;
      }),
    );
  }

  Widget _buildSubtitle() {
    if (endTime == null) {
      return Text('--:--:--\n${StaticLocalisationStrings.tapToRefresh}');
    }

    return CountdownTimer(
      endTime: endTime?.millisecondsSinceEpoch,
      widgetBuilder: (_, CurrentRemainingTime? time) {
        final hours = time?.hours ?? 0;
        final mins = time?.min ?? 0;
        final sec = time?.sec ?? 0;
        return Text(
          '$hours:${zeroPadInt(mins)}:${zeroPadInt(sec)}\n${StaticLocalisationStrings.tapToRefresh}',
        );
      },
    );
  }
}
