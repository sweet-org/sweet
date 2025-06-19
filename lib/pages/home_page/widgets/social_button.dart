import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialButton extends StatelessWidget {
  SocialButton({
    super.key,
    required this.assetName,
    this.darkAssetName,
    required this.socialUrl,
    this.title = '',
    this.size = 20,
  });

  final String assetName;
  final String? darkAssetName;
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
    print(Theme.of(context).brightness == Brightness.dark);
    print('SocialButton: $assetName, darkAssetName: $darkAssetName, socialUrl: $socialUrl, title: $title, size: $size');
    final asset = Theme.of(context).brightness == Brightness.dark && darkAssetName != null
        ? darkAssetName!
        : assetName;
    print('Using asset: $asset');
    return ElevatedButton(
      onPressed: () => _openUrl(socialUrl),
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(asset,
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
