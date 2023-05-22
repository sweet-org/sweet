

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import 'states.dart';

class PatchNotesPageBloc extends Cubit<PatchNotesPageState> {
  PatchNotesPageBloc()
      : super(PatchNotesPageState(
          patchNotes: '',
          isLoading: true,
        )) {
    refreshPatchNotes();
  }

  Future<void> refreshPatchNotes() {
    emit(state.update(isLoading: true));
    final noticeUrl = Uri.parse(
        'https://g85naxx2gb.update.netease.com/game_notice/g85naxx2gb_notice');
    return http.get(noticeUrl).then((response) {
      emit(
        state.update(
          isLoading: false,
          patchNotes: utf8.decode(response.bodyBytes),
        ),
      );
    });

    //new File(path).writeAsBytes(response.bodyBytes);
  }
}
