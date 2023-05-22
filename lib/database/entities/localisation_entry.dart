
class LocalisationEntry {
  final int id;
  final String? source;
  final String? en;
  final String? de;
  final String? fr;
  final String? ja;
  final String? kr;
  final String? por;
  final String? ru;
  final String? spa;
  final String? zh;
  final String? zhcn;

  LocalisationEntry({
    required this.id,
    this.source,
    this.en,
    this.de,
    this.fr,
    this.ja,
    this.kr,
    this.por,
    this.ru,
    this.spa,
    this.zh,
    this.zhcn,
  });

  LocalisationEntry copyWithSource(String newSource) => LocalisationEntry(
        id: id,
        source: newSource,
        en: en,
        de: de,
        fr: fr,
        ja: ja,
        kr: kr,
        por: por,
        ru: ru,
        spa: spa,
        zh: zh,
        zhcn: zhcn,
      );

  factory LocalisationEntry.fromJson(Map<String, dynamic> map) =>
      LocalisationEntry(
        id: map['id'],
        source: map['source'],
        en: map['en'],
        de: map['de'],
        fr: map['fr'],
        ja: map['ja'],
        kr: map['kr'],
        por: map['por'],
        ru: map['ru'],
        spa: map['spa'],
        zh: map['zh'],
        zhcn: map['zhcn'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'en': en,
        'de': de,
        'fr': fr,
        'ja': ja,
        'kr': kr,
        'por': por,
        'ru': ru,
        'spa': spa,
        'zh': zh,
        'zhcn': zhcn,
      };
}
