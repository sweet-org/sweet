import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet/util/crash_reporting.dart';

import 'models/market_csv_line.dart';

final _tzRegex = RegExp(r'([zZ]|[+-]\d{2}(:\d{2})?)$');

class EEMarketApiService {
  final Client http;

  final Map<int, EEMarketItem> _marketData = <int, EEMarketItem>{};

  final _lastFetchKey = 'lastFetchedMarket';
  final _marketDataKey = 'marketData';
  final _fetchTimeInMinutes = 60;

  Timer? _fetchTimer;
  DateTime? _lastFetch;

  /// Stores the time when the data was last updated from the game servers, as
  /// indicated by the data itself.
  DateTime? _timeOfData;

  String? url;
  String keyId = 'id';
  String? keyTime;
  String keyPrice = 'estimated_price';
  String colDelimiter = ',';

  EEMarketApiService({
    required this.http,
  });

  Duration get timeSinceLastFetch {
    if (_lastFetch != null) {
      return DateTime.now().difference(_lastFetch!);
    }
    return Duration(minutes: _fetchTimeInMinutes);
  }

  Future<bool> loadMarketData() async {
    final prefs = await SharedPreferences.getInstance();

    final lastFetchString = prefs.getString(_lastFetchKey);
    _lastFetch =
        lastFetchString != null ? DateTime.parse(lastFetchString) : null;

    var ok = false;
    try {
      if (timeSinceLastFetch.inMinutes >= _fetchTimeInMinutes * 0.75) {
        ok = await _fetchMarketData();
      } else {
        print(
            'Skipping market data fetch, last fetch was only ${timeSinceLastFetch.inMinutes} minutes ago');
      }

      if (!ok) {
        print("Loading cached market data");
        final lastMarketData = prefs.getString(_marketDataKey);
        ok = await _parseMarketData(lastMarketData ?? '');
      }

      // Set up fetch timer
      // Don't need that, we only reload on app start for now
      //_fetchTimer?.cancel();
      //_fetchTimer = Timer.periodic(
      //  Duration(minutes: _fetchTimeInMinutes),
      //  (timer) => _fetchMarketData(),
      //);
    } catch (ex) {
      print('Exception loading EE Market: $ex');
      return false;
    }

    return ok;
  }

  Future<bool> _fetchMarketData() async {
    if (url == null) {
      return false;
    }

    print('Fetching latest market data from $url');
    final csvUrl = Uri.parse(url!);

    try {
      final response = await http.get(csvUrl, headers: {
        'User-Agent': 'SweetEchoes/1.0',
        'Accept': 'text/csv',
      });

      if (response.statusCode >= 300) {
        return false;
      }

      final data = utf8.decode(response.bodyBytes);

      final isValid = await _parseMarketData(data);
      if (isValid) {
        await _storeMarketData(data);
        print('Market data fetched and stored successfully');
      } else {
        print('Invalid market data received from $url');
      }

      return true;
    } catch (ex) {
      print('Exception fetching EE Market: $ex');
      return false;
    }
  }

  static int? getIndexOfKey(List<dynamic> header, String keyName) {
    if (header.isEmpty) return null;
    final index = header.indexOf(keyName);
    if (index >= 0) return index;
    // Check if keyName is numeric and use as index if valid
    final keyAsInt = int.tryParse(keyName);
    if (keyAsInt == null) return null;
    if (keyAsInt < 0 || keyAsInt >= header.length) return null;
    return keyAsInt;
  }

  static DateTime? tryParseTime(String timeString) {
    DateTime? result;
    try {
      result = DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
    if (!_tzRegex.hasMatch(timeString)) {
      return result.copyWith(isUtc: true).toLocal();
    }
    return result.toLocal();
  }

  Future<bool> _parseMarketData(String marketData) async {
    final lines = CsvToListConverter(fieldDelimiter: colDelimiter).convert(
      marketData,
    );

    if (lines.isEmpty) return false;

    // Verify the header
    final indexId = getIndexOfKey(lines[0], keyId) ?? -1;
    final indexTime =
        keyTime != null ? (getIndexOfKey(lines[0], keyTime!) ?? -1) : -1;
    final indexPrice = getIndexOfKey(lines[0], keyPrice) ?? -1;
    final minLen = max(indexId, max(indexTime, indexPrice)) + 1;

    if (indexPrice < 0 || indexId < 0) return false;
    DateTime? globalTime;
    int errors = 0;
    bool skipFirstDataLine = false;

    if (keyTime == null && lines.isNotEmpty && lines[0].isNotEmpty) {
      // Header may contain date in first column
      globalTime = tryParseTime(lines[0][0] as String);
    }
    if (keyTime == null &&
        globalTime == null &&
        lines.length > 1 &&
        lines[1][indexId] is String &&
        lines[1][indexId] == "date") {
      // The first data line may have the item ID as "date"
      globalTime = tryParseTime(lines[1][indexPrice] as String);
      skipFirstDataLine = true;
    }
    if (keyTime == null && globalTime == null) {
      print("Error: Date not found in market data");
      globalTime = DateTime(1970, 1, 1); // Fallback to a default date
    }

    final entries = lines
        .sublist(skipFirstDataLine ? 1 : 2)
        .where((line) => line.length >= minLen && line[indexId] is! String)
        .map(
          (line) {
            try {
              final price = line[indexPrice] is double
                  ? line[indexPrice] as double
                  : null;
              final time = globalTime ?? tryParseTime(line[indexTime])!;
              final itemId = line[indexId] as int?;
              if (itemId == null || itemId <= 0 || price == null) {
                errors++;
                return null;
              }
              return EEMarketItem(itemId: itemId, time: time, price: price);
            } catch (e, stacktrace) {
              reportError(
                e,
                stacktrace,
                info: [DiagnosticsNode.message('Line $line')],
              );
              errors++;
              return null;
            }
          },
        )
        .nonNulls
        .map(
          (e) => MapEntry(e.itemId, e),
        );

    _marketData.clear();
    _marketData.addEntries(entries);
    print('Refreshed Market data for $globalTime '
        'with ${_marketData.length} entries, '
        'got $errors errors');
    _timeOfData = globalTime;

    return _marketData.isNotEmpty;
  }

  Future<void> _storeMarketData(String marketData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_marketDataKey, marketData);
    await prefs.setString(_lastFetchKey, DateTime.now().toIso8601String());
  }

  EEMarketItem marketDataForItem({required itemId}) =>
      _marketData[itemId] ?? EEMarketItem.zero;
}
