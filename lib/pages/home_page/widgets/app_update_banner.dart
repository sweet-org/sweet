import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../service/manup/manup_service.dart';

class AppUpdateBanner extends StatelessWidget {
  const AppUpdateBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manup = RepositoryProvider.of<ManUpService>(context);

    return FutureBuilder<ManUpStatus>(
        future: manup.validate(),
        builder: (context, snapshot) {
          final status = snapshot.data;

          if (status == null || status == ManUpStatus.latest || status == ManUpStatus.unknown) {
            return Container();
          }

          return Container(
            color: Theme.of(context).focusColor,
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'App update available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                ElevatedButton(
                  onPressed: () => _launchUpdateUrl(
                    manup.configData!.updateUrl!,
                    context,
                  ),
                  child: Text(
                    'Update',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _launchUpdateUrl(String updateUrl, context) {
    final url = Uri.parse(updateUrl);
    canLaunchUrl(url).then((canLaunch) {
      if (canLaunch) {
        launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StaticLocalisationStrings.cannotOpenUpdateUrl),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}
