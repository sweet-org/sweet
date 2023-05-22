import 'dart:async';
import 'dart:convert';

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
  final _fetchTimeInMinutes = 15;

  Timer? _fetchTimer;
  DateTime? _lastFetch;

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
    print('Fetching latest market data');
    final url = Uri.parse(
      'https://api.eve-echoes-market.com/market-stats/stats.csv',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 300) {
        return false;
      }

      final data = utf8.decode(response.bodyBytes);

      final isValid = await _parseMarketData(data);
      if (isValid) {
        await _storeMarketData(data);
      }

      return true;
    } catch (ex) {
      print('Exception fetching EE Market: $ex');
      return false;
    }
  }

  Future<bool> _parseMarketData(String marketData) async {
    final header = 'item_id,name,time,sell,buy,lowest_sell,highest_buy';
    if (!marketData.startsWith(header)) {
      return false;
    }

    final lines = const CsvToListConverter().convert(
      marketData,
    );

    if (lines.isEmpty) return false;

    // We are expecting a header line
    // item_id,name,time,sell,buy,lowest_sell,highest_buy

    final entries = lines
        .sublist(1)
        .where((line) => line.length == 7 && line[0] is! String)
        .map(
      (line) {
        try {
          return EEMarketItem(
            itemId: line[0] as int? ?? 0,
            time: DateTime.parse(line[2]),
            calculatedSell: line[3] is double ? line[3] as double : 0,
            calculatedBuy: line[4] is double ? line[4] as double : 0,
            lowestSell: line[5] is double ? line[5] as double : 0,
            highestBuy: line[6] is double ? line[6] as double : 0,
          );
        } catch (e, stacktrace) {
          reportError(
            e,
            stacktrace,
            info: [DiagnosticsNode.message('Line $line')],
          );
          return EEMarketItem.zero;
        }
      },
    ).map(
      (e) => MapEntry(e.itemId, e),
    );

    _marketData.clear();
    _marketData.addEntries(entries);
    print('Refreshed Market data with ${_marketData.length} entries');

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
