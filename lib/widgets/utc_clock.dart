import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UTCClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 500)),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'UTC: ${DateFormat('HH:mm').format(DateTime.now().toUtc())}',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
