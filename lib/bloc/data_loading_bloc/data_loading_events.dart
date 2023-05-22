import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class DataLoadingBlocEvent extends Equatable {
  @override
  List<Object> get props => [];
  DataLoadingBlocEvent([List props = const []]) : super();
}

class LoadRepositoryEvent extends DataLoadingBlocEvent {
  final bool forceDbDownload;

  LoadRepositoryEvent({this.forceDbDownload = false});
}

class ExportDataEvent extends DataLoadingBlocEvent {
  final String path;

  ExportDataEvent({required this.path});
}

class ImportDataEvent extends DataLoadingBlocEvent {
  final String path;

  ImportDataEvent({required this.path});
}
