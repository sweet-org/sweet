import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:sweet/service/manup/manup_service.dart';

@immutable
abstract class DataLoadingBlocState extends Equatable {
  @override
  List<Object> get props => [];
  DataLoadingBlocState() : super();
}

class InitialRepositoryState extends DataLoadingBlocState {}

class LoadingRepositoryState extends DataLoadingBlocState {
  final String message;

  LoadingRepositoryState(this.message);

  @override
  List<Object> get props => [message];
}

class DownloadingDatabaseState extends LoadingRepositoryState {
  final int downloadedBytes;
  final int totalBytes;

  DownloadingDatabaseState({
    required this.downloadedBytes,
    required this.totalBytes,
    required String message,
  }) : super(message);

  @override
  List<Object> get props => [
        downloadedBytes,
        totalBytes,
        message,
      ];
}

class DatabaseDownloadFailedState extends LoadingRepositoryState {
  DatabaseDownloadFailedState({required String message}) : super(message);

  @override
  List<Object> get props => [message];
}

class AppUpdateAvailable extends DataLoadingBlocState {
  final ManUpStatus manUpStatus;

  AppUpdateAvailable({
    required this.manUpStatus,
  });

  @override
  List<Object> get props => [
        manUpStatus,
      ];
}

class AppUnsupportedState extends DataLoadingBlocState {
  final bool isDisabled;
  final bool isUnsupported;
  final ManUpStatus manUpStatus;

  AppUnsupportedState({
    required this.isDisabled,
    required this.isUnsupported,
    required this.manUpStatus,
  });

  @override
  List<Object> get props => [
        isDisabled,
        isUnsupported,
        manUpStatus,
      ];
}

class RepositoryLoadedState extends DataLoadingBlocState {}

class RepositoryFailedState extends DataLoadingBlocState {
  final String message;

  RepositoryFailedState(this.message);
}

class RepositoryFailedLoad extends RepositoryFailedState {
  final int expectedCrc;
  final int actualCrc;

  RepositoryFailedLoad({
    required String message,
    required this.expectedCrc,
    required this.actualCrc,
  }) : super(message);

  @override
  List<Object> get props => [message];
}

class RepositoryLoadException extends RepositoryFailedState {
  final dynamic exception;
  final StackTrace? stackTrace;

  RepositoryLoadException({
    required String message,
    this.exception,
    this.stackTrace,
  }) : super(message);

  @override
  List<Object> get props => [message];
}
