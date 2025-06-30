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

class EEMarketApiService {
  final Client http;

  final Map<int, EEMarketItem> _marketData = <int, EEMarketItem>{};

  final _lastFetchKey = 'lastFetchedMarket';
  final _marketDataKey = 'marketData';
  final _fetchTimeInMinutes = 60;

  Timer? _fetchTimer;
  DateTime? _lastFetch;

  String? url;
  String keyId = 'id';
  String? keyTime;
  String keyPrice = 'estimated_price';

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
      }

      if (!ok) {
        final lastMarketData = prefs.getString(_marketDataKey);
        ok = await _parseMarketData(lastMarketData ?? '');
      }

      // Set up fetch timer
      _fetchTimer?.cancel();
      _fetchTimer = Timer.periodic(
        Duration(minutes: _fetchTimeInMinutes),
        (timer) => _fetchMarketData(),
      );
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

  Future<bool> _parseMarketData(String marketData) async {
    final lines = const CsvToListConverter().convert(
      marketData,
    );

    if (lines.isEmpty) return false;

    // Verify the header
    final indexId = lines[0].indexOf(keyId);
    final indexTime = lines[0].indexOf(keyTime);
    final indexPrice = lines[0].indexOf(keyPrice);
    final minLen = max(indexId, max(indexTime, indexPrice)) + 1;

    if (indexPrice < 0 || indexId < 0) return false;
    DateTime? globalTime;
    int errors = 0;

    if (lines.length > 1 &&
        lines[1][indexId] is String &&
        lines[1][indexId] == "date") {
      // The first data line may have the item ID as "date"
      try {
        globalTime = DateTime.parse(lines[1][indexPrice] as String);
      } catch (e) {
        print("Error parsing global time from market data: $e");
        return false;
      }
    } else if (indexTime < 0) {
      print("Error: Date column not found in market data");
      globalTime = DateTime(1970, 1, 1); // Fallback to a default date
    }

    final entries = lines
        .sublist(globalTime == null ? 1 : 2)
        .where((line) => line.length >= minLen && line[indexId] is! String)
        .map(
          (line) {
            try {
              final price = line[indexPrice] is double
                  ? line[indexPrice] as double
                  : null;
              final time = globalTime ?? DateTime.parse(line[indexTime]);
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
    print('Refreshed Market data with ${_marketData.length} entries, '
        'got $errors errors');

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
