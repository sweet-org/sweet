import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:tinycolor2/tinycolor2.dart';

import 'package:sweet/pages/patch_notes/bloc/patch_notes_bloc.dart';

class PatchNotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PatchNotesPageBloc>(
      create: (context) => PatchNotesPageBloc(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: PatchNotesWidget(),
        ),
      ),
    );
  }
}

class PatchNotesWidget extends StatelessWidget {
  Color invertColor(Color color) {
    return Color.fromRGBO(255 - color.red, 255 - color.green, 255 - color.blue,
        color.alpha / 255);
  }

  Color hexToColor(String code) {
    return Color(int.parse(code, radix: 16));
  }

  List<TextSpan> parsePatchNotes(ThemeData theme, String patchNotes) {
    var sections = patchNotes.split('\n\n\n');

    var sectionSpans = sections.map((section) {
      var firstNewLine = section.indexOf('\n');
      var firstLine = section.substring(0, firstNewLine);
      var notes = section.substring(firstNewLine + 1);

      var colorRegex = RegExp(r"<color value='0x([0-9a-f]+)'>([^<]*)<\/color>");

      var matches = colorRegex.allMatches(notes);
      var spans = [
        TextSpan(
          text: '$firstLine\n',
          style: theme.textTheme.titleLarge,
        )
      ];
      var idx = 0;

      for (var m in matches) {
        var fontSizeRegex =
            RegExp(r"<fontsize( value='([0-9]+)')?>([^<]*)<\/fontsize>");

        var text = notes.substring(idx, m.start);
        var fontSizeMatch = fontSizeRegex.firstMatch(text);

        if ((fontSizeMatch?.groupCount ?? 0) > 0) {
          var fontSize = double.parse(fontSizeMatch!.group(2)!);
          var mainText = fontSizeMatch.group(3);

          spans.add(
            TextSpan(
              text: mainText,
              style: theme.textTheme.bodyLarge!.copyWith(fontSize: fontSize),
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: notes.substring(idx, m.start),
              style: theme.textTheme.bodyLarge,
            ),
          );
        }
        idx = m.end;

        // Add the Matched one
        var matchedString = m.group(2);
        var colorHexString = m.group(1)!;
        var color = hexToColor(colorHexString);

        if (color.isLight) {
          color = invertColor(color);
        }

        if (theme.brightness == Brightness.dark) {
          color = invertColor(color);
        }

        spans.add(
          TextSpan(
            text: matchedString,
            style: theme.textTheme.bodyLarge!.copyWith(
              color: color,
            ),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: '${notes.substring(idx)}\n\n\n',
          style: theme.textTheme.bodyLarge,
        ),
      );

      return spans;
    });

    return sectionSpans.expand((e) => e).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<PatchNotesPageBloc>().refreshPatchNotes(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<PatchNotesPageBloc, PatchNotesPageState>(
              builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if ((state.patchNotes).isEmpty) {
              return Text(StaticLocalisationStrings.noAnnoucements);
            }

            return RichText(
              text: TextSpan(
                children: parsePatchNotes(
                  Theme.of(context),
                  state.patchNotes,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
