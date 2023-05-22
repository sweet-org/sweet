abstract class LocalisationStrings {
  // 'Stable'
  static int stable = 11928;
  // 'Bonus per Lv.'
  static int bonusPerLv = 9803;
  // 'Role Bonus'
  static int roleBonus = 10554;
  // 'Rigs'
  static int rigs = 8457;
  // 'Add Clone'
  static int addClone = 18167;
  // 'Warp Preparation Time'
  static int warpPreparationTime = 31622;
  // 'Buy'
  static int buy = 9929;
  // 'Cancel'
  static int cancel = 3901;
  // 'Capacitor'
  static int capacitor = 10967;
  // 'Copy'
  static int copy = 30388;
  // 'DPS'
  static int dps = 8464;
  // 'Please enter a name'
  static int pleaseEnterName = 32084;
  // 'Max Velocity'
  static int maxVelocity = 9145;
  // 'OK'
  static int ok = 4649;
  // 'Planetary Interaction'
  static int planetaryInteraction = 13959;
  // 'Resistance Info'
  static int resistanceInfo = 8059;

  // 'Warp stability'
  static int warpStability = 14628;
  // 'Missile Range'
  static int missileRange = 6295;
  // 'km (unit)'
  static int kmUnit = 3441;
  // 'GJ/s (unit)'
  static int gjPerSecondUnit = 4455;
  // 'GJ (unit)'
  static int gjUnit = 4454;
  // '%d min'
  static int minUnit = 20;
  // '/Min'
  static int perMinUnit = 62;
  // 'S'
  static int secondsShort = 11893;

  // 'Drones'
  static int drones = 8745;
  // 'Fighters'
  static int fighters = 614077;

  // Main Attribute
  static int mainAttribute = 34858;
  // Trainable
  static int trainable = 34940;

  // Nihilus Environment
  static int nihilusEnvironment = 35439;
  // Capacitor Recharge Time Adjustment
  static int capacitorRechargeTimeAdjustment = 10983;

  // Languages Strings
  static int langEnglish = 13188;
  static int langRussian = 2470;
  static int langGerman = 7466;
  static int langFrench = 10004;
  static int langJapanese = 32655;
  static int langBrasilPortuguese = 30173;
  static int langSpanish = 30224;
  static int langChinese = 1894;
  static int langKorean = 32670;
}

abstract class StaticLocalisationStrings {
  static const cannotFitModule = 'Cannot fit this module';
  static const cannotFitRig = 'Cannot fit this rig';
  static const cannotOpenUpdateUrl = 'Cannot open update URL';
  static const close = 'Close';
  static const copyCode = 'Copy Code';
  static const copyFitting = 'Copy Fitting';
  static const defaultPilot = 'Default Pilot';
  static const deleteClone = 'Delete Clone';
  static const deleteFitting = 'Delete Fitting';
  static const delete = 'Delete';
  static const discard = 'Discard';
  static const done = 'Done';
  static const exportToFile = 'Export to File';
  static const firepower = 'Firepower';
  static const fittingAdded = 'Fitting added';
  static const importFromFile = 'Import from File';
  static const incorrectStateDetected = 'Incorrect state detected';
  static const invalidFormatDetected = 'Invalid format detected';
  static const misc = 'Misc';
  static const noAnnoucements = 'No annoucements at this time';
  static const noResultsFound = 'No results found';
  static const sell = 'Sell';
  static const tapToRefresh = 'Tap to refresh';
  static const theme = 'Theme';
  static const itemIsNotShip = 'This item is not a ship';
  static const unsavedChanges = 'Unsaved changes!';
  static const unsavedChangesMessage =
      'There are unsaved changes, backing out will cause them to be lost.';
  static const emptyModule = '- Empty -';
  static const effectiveHP = 'Effective HP';
  static const importExport = 'Import/Export data';
}

final kSupportedLanguages = {
  'en': LocalisationStrings.langEnglish,
  'ru': LocalisationStrings.langRussian,
  'de': LocalisationStrings.langGerman,
  'fr': LocalisationStrings.langFrench,
  'zh': LocalisationStrings.langChinese,
  'por': LocalisationStrings.langBrasilPortuguese,
  'spa': LocalisationStrings.langSpanish,
  'ja': LocalisationStrings.langJapanese,
  'kr': LocalisationStrings.langKorean,
};
