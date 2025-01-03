// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sweet/util/constants.dart';

import 'package:sweet/service/manup/manup_service.dart';

class VersionLabel extends StatefulWidget {
  final Color? color;

  const VersionLabel({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  State<VersionLabel> createState() => _VersionLabelState();
}

class _VersionLabelState extends State<VersionLabel> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    PackageInfo.fromPlatform().then(
      (info) => setState(() {
        _packageInfo = info;
      }),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var versionText = 'v0.0.1';
    final echoesVersion = RepositoryProvider.of<ManUpService>(context)
        .setting(key: kEEVersionManUpKey, orElse: 0);

    if (_packageInfo != null) {
      versionText = 'v${_packageInfo!.version} (${_packageInfo!.buildNumber})';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => showAboutDialog(
          context: context,
          applicationIcon: SizedBox.fromSize(
            size: Size.square(48),
            child: SvgPicture.asset('assets/svg/logo-transparent.svg'),
          ),
          applicationName: 'SWEET',
          applicationLegalese: '''
Eve Echoes thanks to CCP and NetEase
Sweet Icon made by Icongeek26 from www.flaticon.com
          ''',
          applicationVersion: versionText,
          children: [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              color: widget.color ?? Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '$versionText\nEchoes: $echoesVersion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.color ?? Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
