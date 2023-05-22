import 'package:sweet/database/database.dart';
import 'package:sweet/database/entities/attribute.dart';
import 'package:sweet/database/entities/category.dart';
import 'package:sweet/database/entities/group.dart';
import 'package:sweet/database/entities/item.dart';
import 'package:sweet/database/entities/market_group.dart';

class LangString {
  final int id;
  final String? source;
  final String? translated;

  LangString({required this.id, this.source, this.translated});
}

class LocalisationRepository {
  final EveEchoesDatabase _echoesDatabase;
  String _currentLanguageCode = 'en';

  LocalisationRepository(this._echoesDatabase);

  var strings = <int, LangString>{};
  Future<void> loadStringsForLanguage(String language) async {
    _currentLanguageCode = language;

    var rows = await _echoesDatabase.db.query(
      _echoesDatabase.localisedStringDao.tableName,
      columns: ['id', 'source', _currentLanguageCode],
    );
    strings = {
      for (var e in rows.map(
        (e) => LangString(
          id: e['id'] as int,
          source: e['source'] as String?,
          translated: e[language] as String?,
        ),
      ))
        e.id: e
    };
  }

  String getLocalisedStringForIndex(int? index) =>
      _getLocalisedStringForIndex(index) ?? '';

  String? _getLocalisedStringForIndex(int? index) {
    if (index == null) return null;
    return strings[index]?.translated ?? strings[index]?.source;
  }

  String getLocalisedNameForItem(Item item) {
    // special index where we combined the IDs
    // Because NE did something strange with the names now :/
    if (item.nameKey == -2) {
      // Strings are 'expected' in "{ID}... format, so we will split them out"
      final regex = RegExp('{(?<id>([^}])*)}');
      final ids = regex
          .allMatches(item.sourceName ?? '')
          .map((e) => e.namedGroup('id') ?? '0')
          .map((e) => int.tryParse(e) ?? 0);
      final strings =
          ids.map((e) => _getLocalisedStringForIndex(e) ?? '[NONE]');
      return strings.join(' ');
    }

    return _getLocalisedStringForIndex(item.nameKey) ??
        item.sourceName ??
        '[NONE]';
  }

  String getLocalisedStringForCategory(Category category) {
    return _getLocalisedStringForIndex(category.localisedNameIndex) ??
        category.sourceName;
  }

  String getLocalisedStringForGroup(Group group) {
    return _getLocalisedStringForIndex(group.localisedNameIndex) ??
        group.sourceName;
  }

  String getLocalisedNameForAttribute(Attribute attribute) {
    return _getLocalisedStringForIndex(attribute.nameLocalisationKey) ??
        attribute.attributeName;
  }

  String getLocalisedUnitForAttribute(Attribute attribute) {
    return _getLocalisedStringForIndex(attribute.unitLocalisationKey) ??
        attribute.attributeSourceUnit ??
        '';
  }

  String getLocalisedStringForMarketGroup(MarketGroup marketGroup) {
    return _getLocalisedStringForIndex(marketGroup.localisationIndex) ??
        marketGroup.sourceName;
  }
}
