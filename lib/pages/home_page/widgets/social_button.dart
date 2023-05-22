import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialButton extends StatelessWidget {
  SocialButton({
    Key? key,
    required this.assetName,
    required this.socialUrl,
    this.title = '',
    this.size = 20,
  }) : super(key: key);

  final String assetName;
  final String socialUrl;
  final String title;
  final double size;

  void _openUrl(String url) {
    final uri = Uri.parse(url);
    canLaunchUrl(uri).then((canLaunch) {
      if (canLaunch) {
        launchUrl(uri);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _openUrl(socialUrl),
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetName,
              height: size,
            ),
            title.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(title),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
