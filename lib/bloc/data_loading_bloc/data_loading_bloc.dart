import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:manup/manup.dart';
import 'package:sweet/model/character/character.dart';
import 'package:sweet/model/ship/fitting_list_element.dart';
import 'package:sweet/model/ship/ship_fitting_folder.dart';
import 'package:sweet/model/ship/ship_fitting_loadout.dart';

import 'package:sweet/service/fitting_simulator.dart';
import 'package:sweet/util/platform_helper.dart';

import '../../repository/character_repository.dart';
import '../../repository/item_repository.dart';
import '../../repository/localisation_repository.dart';
import '../../repository/ship_fitting_repository.dart';
import '../../util/constants.dart';
import '../../util/crash_reporting.dart';

import 'data_loading_events.dart';
import 'data_loading_states.dart';

class DataLoadingBloc extends Bloc<DataLoadingBlocEvent, DataLoadingBlocState> {
  final ItemRepository _itemRepository;
  final CharacterRepository _characterRepository;
  final ShipFittingLoadoutRepository _fittingRepository;
  final LocalisationRepository _localisationRepository;
  final ManUpService _manUpService;

  DataLoadingBloc(
    this._itemRepository,
    this._characterRepository,
    this._fittingRepository,
    this._localisationRepository,
    this._manUpService,
  ) : super(InitialRepositoryState()) {
    on<LoadRepositoryEvent>((event, emit) => _loadRepository(event, emit));
    on<ExportDataEvent>((event, emit) => _exportDataToFile(event.path, emit));
    on<ImportDataEvent>((event, emit) => _importDataFromFile(event.path, emit));
  }

  Future<void> _loadRepository(
    LoadRepositoryEvent event,
    Emitter<DataLoadingBlocState> emit,
  ) async {
    emit(LoadingRepositoryState('Warming up warp drives'));

    try {
      var start = DateTime.now();
      emit(LoadingRepositoryState('Checking for data update...'));
      final status = await _manUpService.validate();

      if (status == ManUpStatus.unsupported || status == ManUpStatus.disabled) {
        emit(AppUnsupportedState(
          isDisabled: status == ManUpStatus.disabled,
          isUnsupported: status == ManUpStatus.unsupported,
          manUpStatus: status,
        ));
        return;
      } else if (status != ManUpStatus.latest) {
        emit(AppUpdateAvailable(
          manUpStatus: status,
        ));
      }

      final version =
          _manUpService.setting<int>(key: kEEVersionManUpKey, orElse: 0);
      final expectedDbCrc =
          _manUpService.setting<int>(key: kDbCrcManUpKey, orElse: 0);
      final performCrcCheck =
          _manUpService.setting<bool>(key: kPerformCrcManUpKey, orElse: false);
      final useNewDbLocation =
          _manUpService.setting<bool>(key: kUseNewDbLocation, orElse: true);

      final downloadDb = event.forceDbDownload ||
          await _itemRepository.checkForDatabaseUpdate(
            latestVersion: version,
            dbCrc: expectedDbCrc,
            performCrcCheck: performCrcCheck,
            checkEtag: useNewDbLocation,
          );

      if (downloadDb) {
        await _itemRepository.downloadDatabase(
          latestVersion: version,
          emitter: emit,
        );
      }

      if (performCrcCheck) {
        emit(LoadingRepositoryState('Validating database...'));
        final dbCrc = await _itemRepository.databaseCrc();
        if (dbCrc != expectedDbCrc) {
          emit(RepositoryFailedLoad(
            message:
                'Database is missing or invalid. Please retry to download.',
            expectedCrc: expectedDbCrc,
            actualCrc: dbCrc,
          ));
          return;
        }
      }

      emit(LoadingRepositoryState('Loading data...'));
      print('${DateTime.now()}: Opening DB');
      await _itemRepository.openDatabase();
      print('${DateTime.now()}: Processing market groups');
      await _itemRepository.processMarketGroups();
      print('${DateTime.now()}: Processing non integratable rigs');
      await _itemRepository.processExcludeFusionRigs();
      print('${DateTime.now()}: Loading language strings');
      await _localisationRepository.loadStringsForLanguage('en');
      print(
        '${DateTime.now()}: Completed DB load in ${DateTime.now().difference(start)}',
      );

      if (PlatformHelper.isMobile) {
        await logEvent(
          name: 'app_startup',
          parameters: {
            'loadTime': '${DateTime.now().difference(start)}',
          },
        );
      }

      emit(LoadingRepositoryState('Draining clone bays'));
      _characterRepository.createMaxSkillCharacter(
        skills: _itemRepository.fittingSkills.values,
      );
      await _characterRepository.loadCharacters();
      await _fittingRepository.loadLoadouts();
      FittingSimulator.loadDefinitions(_itemRepository);

      emit(RepositoryLoadedState());
    } catch (e, stacktrace) {
      reportError(e, stacktrace);

      emit(RepositoryLoadException(
        message: 'Unknown exception',
        exception: e is Exception ? e as Exception? : e,
        stackTrace: stacktrace,
      ));
    }
  }

  Future<void> _exportDataToFile(
    String path,
    Emitter<DataLoadingBlocState> emit,
  ) async {
    final data = {
      'fittings': _fittingRepository.loadouts.toList(),
      'characters': _characterRepository.characters.toList(),
      CharacterRepository.defaultPilotPrefsKey:
          _characterRepository.defaultPilot.id,
    };

    final json = jsonEncode(data);
    await File(path).writeAsString(json, flush: true);
    emit(RepositoryLoadedState());
  }

  Future<void> _importDataFromFile(
    String path,
    Emitter<DataLoadingBlocState> emit,
  ) async {
    emit(LoadingRepositoryState('Importing data'));

    final json = await File(path).readAsString();
    final data = jsonDecode(json);

    final characters = List<Character>.from(
      data['characters'].map(
        (x) => Character.fromJson(x),
      ),
    );
    final fittings = List<FittingListElement>.from(
      data['fittings'].map(
        (x) => {
          if (x['type'] == null || x['type'] == 'LOADOUT') {
            ShipFittingLoadout.fromJson(x)
          } else if (x['type'] == "FOLDER") {
            ShipFittingFolder.fromJson(x)
          } else {
            //Should never happen
            null
          }
        }
      ),
    );

    await _characterRepository.loadCharacters(
      data: characters,
      defaultPilot: data[CharacterRepository.defaultPilotPrefsKey],
    );
    await _fittingRepository.loadLoadouts(data: fittings);

    emit(RepositoryLoadedState());
  }
}
