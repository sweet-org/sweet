

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class PatchNotesPageState extends Equatable {
  final String patchNotes;
  final bool isLoading;

  PatchNotesPageState({required this.patchNotes, required this.isLoading});
  @override
  List<Object> get props => [
        DateTime.now(),
        patchNotes,
        isLoading,
      ];

  PatchNotesPageState update({bool? isLoading, String? patchNotes}) {
    return (PatchNotesPageState(
      isLoading: isLoading ?? this.isLoading,
      patchNotes: patchNotes ?? this.patchNotes,
    ));
  }
}
