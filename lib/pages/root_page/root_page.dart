import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as utils;

import 'package:sweet/bloc/data_loading_bloc/data_loading.dart';
import 'package:sweet/mixins/file_selector_mixin.dart';
import 'package:sweet/pages/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweet/pages/home_page/widgets/social_button.dart';
import 'package:sweet/pages/home_page/widgets/version_label.dart';
import 'package:sweet/util/localisation_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../service/manup/manup_service.dart';

class RootPage extends StatelessWidget with FileSelector {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DataLoadingBloc, DataLoadingBlocState>(
          listenWhen: (prev, curr) => curr is AppUpdateAvailable,
          buildWhen: (prev, curr) => curr is! AppUpdateAvailable,
          listener: (context, state) {
            if (state is AppUpdateAvailable) {
              final theme = Theme.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'App update available',
                    style: theme.textTheme.bodyLarge,
                  ),
                  backgroundColor: theme.primaryColor,
                  duration: Duration(seconds: 10),
                  action: SnackBarAction(
                      label: 'Update',
                      textColor:
                          theme.textTheme.bodyLarge?.color ?? Colors.white,
                      onPressed: () {
                        final manup =
                            RepositoryProvider.of<ManUpService>(context);
                        _launchUpdateUrl(
                          manup.configData!.updateUrl!,
                          context,
                        );
                      }),
                ),
              );
            }
          },
          builder: (BuildContext context, DataLoadingBlocState state) {
            if (state is RepositoryLoadedState) {
              return HomePage(
                title: 'SWEET',
              );
            }

            if (state is InitialRepositoryState) {
              RepositoryProvider.of<DataLoadingBloc>(context)
                  .add(LoadRepositoryEvent());
            }

            return Material(
              child: _buildChild(state, context),
            );
          }),
    );
  }

  Widget _buildChild(DataLoadingBlocState state, BuildContext context) {
    if (state is RepositoryFailedState) {
      return _handleLoadingErrorState(
        context: context,
        state: state,
      );
    }

    var loadingMessage = 'Warming up warp drives';

    if (state is LoadingRepositoryState) {
      loadingMessage = state.message;
    }
    if (state is DatabaseDownloadFailedState) {
      print("State is DatabaseDownloadFailedState");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 10),
          ),
        );
      });
    }

    if (state is AppUnsupportedState) {
      return _buildUnsupportedAppState(
        context: context,
        state: state,
      );
    }

    return Container(
      color: Theme.of(context).canvasColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 32.0,
              horizontal: 8.0,
            ),
            child: Text(
              loadingMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedAppState({
    required BuildContext context,
    required AppUnsupportedState state,
  }) {
    final manup = RepositoryProvider.of<ManUpService>(context);

    return Container(
      color: Theme.of(context).canvasColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Icon(
              Icons.error_outline,
              color: Theme.of(context).primaryColor.withAlpha(128),
            ),
          ),
          Text(
            ManUpService.getMessage(status: state.manUpStatus),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () => _launchUpdateUrl(
              manup.configData!.updateUrl!,
              context,
            ),
            child: Text(
              'Update',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
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

  Widget _handleLoadingErrorState({
    required BuildContext context,
    required RepositoryFailedState state,
  }) {
    final versionLabelColor = Theme.of(context).textTheme.bodyLarge?.color;

    return SafeArea(
      child: Container(
        color: Theme.of(context).canvasColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).primaryColor.withAlpha(128),
              size: 128,
            ),
            Text(
              'Failed to load initial data.\nPlease check you have a stable internet connection',
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                runAlignment: WrapAlignment.spaceAround,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: _buildButtonsForState(context, state),
              ),
            ),
            Divider(),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Expanded(child: _buildExceptionWidgets(context, state)),
            VersionLabel(
              color: versionLabelColor?.withAlpha(128),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExceptionWidgets(
    BuildContext context,
    RepositoryFailedState state,
  ) {
    if (state is RepositoryLoadException) {
      final exception = state.exception?.toString();
      final stackTrace = state.stackTrace;
      return ExceptionWidget(exception: exception, stackTrace: stackTrace);
    } else if (state is RepositoryFailedLoad) {
      final expectedCrc = state.expectedCrc.toRadixString(16).toUpperCase();
      final actualCrc = state.actualCrc.toRadixString(16).toUpperCase();
      return Text(
        'Expected: 0x$expectedCrc\nActual: 0x$actualCrc',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Container();
  }

  List<Widget> _buildButtonsForState(
    BuildContext context,
    RepositoryFailedState state,
  ) {
    final bloc = context.read<DataLoadingBloc>();
    return [
      SizedBox(
        width: 150,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          onPressed: () => bloc.add(LoadRepositoryEvent()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        width: 150,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          onPressed: () => bloc.add(LoadRepositoryEvent(forceDbDownload: true)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Force Retry'),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        width: 150,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          onPressed: () =>
              _exportData((path) => bloc.add(ExportDataEvent(path: path))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.import_export),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Export Data'),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        width: 150,
        child: SocialButton(
          assetName: 'assets/branding/discord-logo-white.svg',
          socialUrl: 'https://discord.gg/2QyVpSJKte',
          title: 'Discord',
        ),
      ),
      SizedBox(
        width: 150,
        child: ElevatedButton(
          onPressed: () => copyStateToClipboard(context, state),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.copy),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Copy Error'),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Future<void> copyStateToClipboard(
    BuildContext context,
    RepositoryFailedState state,
  ) async {
    final String text;

    if (state is RepositoryLoadException) {
      final exception = state.exception?.toString() ?? 'None';
      final stackTrace = state.stackTrace ?? 'None';

      text = 'Error:\n$exception\n\nStack:\n$stackTrace}';
    } else if (state is RepositoryFailedLoad) {
      final expectedCrc = state.expectedCrc.toRadixString(16).toUpperCase();
      final actualCrc = state.actualCrc.toRadixString(16).toUpperCase();
      final message = state.message;
      text = '$message\nExpected: 0x$expectedCrc\nActual: 0x$actualCrc';
    } else {
      return;
    }

    await Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _exportData(void Function(String path) onExport) async {
    final folder = await selectFolder();

    if (folder != null) {
      final path = utils.join(
        folder,
        DateFormat('yyyyMMdd-HHmm').format(DateTime.now()),
      );
      onExport(path);
    }
  }
}

class ExceptionWidget extends StatelessWidget {
  const ExceptionWidget({
    Key? key,
    required this.exception,
    required this.stackTrace,
  }) : super(key: key);

  final String? exception;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            exception != null
                ? Text(
                    'Exception:\n$exception',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                : Container(),
            stackTrace != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Stack:\n$stackTrace}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
