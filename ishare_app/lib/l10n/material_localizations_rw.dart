import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Kinyarwanda Material Localizations
/// This provides translations for all Material Design widgets in Kinyarwanda
class MaterialLocalizationsRw extends GlobalMaterialLocalizations {
  const MaterialLocalizationsRw({
    super.localeName = 'rw',
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  // ============================================================================
  // DIALOG & ALERT LABELS
  // ============================================================================

  @override
  String get alertDialogLabel => 'Umuburo';

  @override
  String get dialogLabel => 'Ikiganiro';

  @override
  String get modalBarrierDismissLabel => 'Kureka';

  // ============================================================================
  // BUTTON LABELS
  // ============================================================================

  @override
  String get okButtonLabel => 'SAWA';

  @override
  String get cancelButtonLabel => 'Kureka';

  @override
  String get continueButtonLabel => 'Komeza';

  @override
  String get closeButtonLabel => 'Gufunga';

  @override
  String get closeButtonTooltip => 'Gufunga';

  @override
  String get backButtonTooltip => 'Gusubira inyuma';

  @override
  String get deleteButtonTooltip => 'Gusiba';

  @override
  String get moreButtonTooltip => 'Ibindi';

  @override
  String get copyButtonLabel => 'Gukoporora';

  @override
  String get cutButtonLabel => 'Gukata';

  @override
  String get pasteButtonLabel => 'Gushyiramo';

  @override
  String get selectAllButtonLabel => 'Guhitamo byose';

  @override
  String get saveButtonLabel => 'BIKA';

  @override
  String get shareButtonLabel => 'Gusangira';

  @override
  String get lookUpButtonLabel => 'Shakisha';

  @override
  String get searchWebButtonLabel => 'Shakisha';

  @override
  String get scanTextButtonLabel => 'Gusikana inyandiko';

  @override
  String get viewLicensesButtonLabel => 'REBA IMPUSHYA';

  // ============================================================================
  // TIME & DATE LABELS
  // ============================================================================

  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get postMeridiemAbbreviation => 'PM';

  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.HH_colon_mm;

  @override
  String get timePickerDialHelpText => 'HITAMO IGIHE';

  @override
  String get timePickerInputHelpText => 'INJIZA IGIHE';

  @override
  String get timePickerHourLabel => 'Isaha';

  @override
  String get timePickerMinuteLabel => 'Umunota';

  @override
  String get timePickerHourModeAnnouncement => 'Hitamo amasaha';

  @override
  String get timePickerMinuteModeAnnouncement => 'Hitamo iminota';

  @override
  String get invalidTimeLabel => 'Injira igihe cyemewe';

  // ============================================================================
  // DATE PICKER LABELS
  // ============================================================================

  @override
  String get datePickerHelpText => 'HITAMO ITARIKI';

  @override
  String get dateInputLabel => 'Injiza itariki';

  @override
  String get dateHelpText => 'mm/dd/yyyy';

  @override
  String get dateSeparator => '/';

  @override
  String get dateOutOfRangeLabel => 'Hanze y\'intera.';

  @override
  String get invalidDateFormatLabel => 'Imiterere itemewe.';

  @override
  String get invalidDateRangeLabel => 'Urwego rutemewe.';

  @override
  String get currentDateLabel => 'Uyu munsi';

  @override
  String get unspecifiedDate => 'Itariki';

  @override
  String get unspecifiedDateRange => 'Intera y\'itariki';

  @override
  String get selectedDateLabel => 'Itariki yahiswemo';

  @override
  String get dateRangeStartLabel => 'Itariki yo gutangira';

  @override
  String get dateRangeEndLabel => 'Itariki yo kurangiza';

  @override
  String get dateRangePickerHelpText => 'HITAMO INTERA';

  @override
  String get calendarModeButtonLabel => 'Guhindura kuri kalendari';

  @override
  String get inputDateModeButtonLabel => 'Guhindura ku buryo bwo kwinjiza';

  @override
  String get inputTimeModeButtonLabel => 'Guhindura ku buryo bwo kwinjiza umwandiko';

  @override
  String get dialModeButtonLabel => 'Guhindura kuriya buryo bwo guhitamo';

  @override
  String get selectYearSemanticsLabel => 'Hitamo umwaka';

  @override
  String get nextMonthTooltip => 'Ukwezi gutaha';

  @override
  String get previousMonthTooltip => 'Ukwezi gushize';

  // ============================================================================
  // NAVIGATION & MENU LABELS
  // ============================================================================

  @override
  String get drawerLabel => 'Menu yo kugendagenda';

  @override
  String get openAppDrawerTooltip => 'Gufungura menu yo kugendagenda';

  @override
  String get showMenuTooltip => 'Kwerekana menu';

  @override
  String get popupMenuLabel => 'Menu isubirwamo';

  @override
  String get menuBarMenuLabel => 'Menu';

  @override
  String get menuDismissLabel => 'Gufunga menu';

  @override
  String get bottomSheetLabel => 'Urupapuro rwo hasi';

  @override
  String get scrimLabel => 'Funga';

  // ============================================================================
  // PAGE & NAVIGATION LABELS
  // ============================================================================

  @override
  String get firstPageTooltip => 'Ipaji ya mbere';

  @override
  String get lastPageTooltip => 'Ipaji ya nyuma';

  @override
  String get nextPageTooltip => 'Ipaji ikurikira';

  @override
  String get previousPageTooltip => 'Ipaji ibanziriza';

  @override
  String get rowsPerPageTitle => 'Imirongo kuri buri paji:';

  // ============================================================================
  // SEARCH & SELECTION LABELS
  // ============================================================================

  @override
  String get searchFieldLabel => 'Gushakisha';

  @override
  String get clearButtonTooltip => 'Gusiba';

  @override
  String get collapsedIconTapHint => 'Kwagura';

  @override
  String get expandedIconTapHint => 'Kugabanya';

  @override
  String get collapsedHint => 'aguye';

  @override
  String get expandedHint => 'hinamye';

  @override
  String get expansionTileCollapsedHint => 'kanda inshuro ebyiri kugira ngo wagure';

  @override
  String get expansionTileCollapsedTapHint => 'wagura kugira ngo urebe ibindi';

  @override
  String get expansionTileExpandedHint => 'kanda inshuro ebyiri kugira ngo uhine';

  @override
  String get expansionTileExpandedTapHint => 'hina kugira ngo urebe bike';

  // ============================================================================
  // ACCOUNT & SIGN IN LABELS
  // ============================================================================

  @override
  String get signedInLabel => 'Winjiye';

  @override
  String get hideAccountsLabel => 'Guhisha konti';

  @override
  String get showAccountsLabel => 'Kwerekana konti';

  // ============================================================================
  // REORDER & DRAG-DROP LABELS
  // ============================================================================

  @override
  String get reorderItemDown => 'Kwimura hasi';

  @override
  String get reorderItemLeft => 'Kwimura ibumoso';

  @override
  String get reorderItemRight => 'Kwimura iburyo';

  @override
  String get reorderItemToEnd => 'Kwimura ku mpera';

  @override
  String get reorderItemToStart => 'Kwimura ku ntango';

  @override
  String get reorderItemUp => 'Kwimura hejuru';

  // ============================================================================
  // REFRESH & MISC LABELS
  // ============================================================================

  @override
  String get refreshIndicatorSemanticLabel => 'Kongeramo';

  // ============================================================================
  // LICENSES LABELS
  // ============================================================================

  @override
  String get licensesPageTitle => 'Impushya';

  @override
  String get licensesPackageDetailTextZero => 'Nta mpushya';

  @override
  String get licensesPackageDetailTextOne => 'Uruhushya 1';

  @override
  String get licensesPackageDetailTextTwo => r'$licenseCount impushya';

  @override
  String get licensesPackageDetailTextFew => r'$licenseCount impushya';

  @override
  String get licensesPackageDetailTextMany => r'$licenseCount impushya';

  @override
  String get licensesPackageDetailTextOther => r'Impushya $licenseCount';

  // ============================================================================
  // SCRIPT CATEGORY
  // ============================================================================

  @override
  ScriptCategory get scriptCategory => ScriptCategory.englishLike;

  // ============================================================================
  // KEYBOARD KEYS
  // ============================================================================

  @override
  String get keyboardKeyAlt => 'Alt';

  @override
  String get keyboardKeyAltGraph => 'AltGr';

  @override
  String get keyboardKeyBackspace => 'Backspace';

  @override
  String get keyboardKeyCapsLock => 'Caps Lock';

  @override
  String get keyboardKeyChannelDown => 'Channel Down';

  @override
  String get keyboardKeyChannelUp => 'Channel Up';

  @override
  String get keyboardKeyControl => 'Ctrl';

  @override
  String get keyboardKeyDelete => 'Del';

  @override
  String get keyboardKeyEject => 'Eject';

  @override
  String get keyboardKeyEnd => 'End';

  @override
  String get keyboardKeyEscape => 'Esc';

  @override
  String get keyboardKeyFn => 'Fn';

  @override
  String get keyboardKeyHome => 'Home';

  @override
  String get keyboardKeyInsert => 'Insert';

  @override
  String get keyboardKeyMeta => 'Meta';

  @override
  String get keyboardKeyMetaMacOs => 'Command';

  @override
  String get keyboardKeyMetaWindows => 'Win';

  @override
  String get keyboardKeyNumLock => 'Num Lock';

  @override
  String get keyboardKeyNumpad0 => 'Num 0';

  @override
  String get keyboardKeyNumpad1 => 'Num 1';

  @override
  String get keyboardKeyNumpad2 => 'Num 2';

  @override
  String get keyboardKeyNumpad3 => 'Num 3';

  @override
  String get keyboardKeyNumpad4 => 'Num 4';

  @override
  String get keyboardKeyNumpad5 => 'Num 5';

  @override
  String get keyboardKeyNumpad6 => 'Num 6';

  @override
  String get keyboardKeyNumpad7 => 'Num 7';

  @override
  String get keyboardKeyNumpad8 => 'Num 8';

  @override
  String get keyboardKeyNumpad9 => 'Num 9';

  @override
  String get keyboardKeyNumpadAdd => 'Num +';

  @override
  String get keyboardKeyNumpadComma => 'Num ,';

  @override
  String get keyboardKeyNumpadDecimal => 'Num .';

  @override
  String get keyboardKeyNumpadDivide => 'Num /';

  @override
  String get keyboardKeyNumpadEnter => 'Num Enter';

  @override
  String get keyboardKeyNumpadEqual => 'Num =';

  @override
  String get keyboardKeyNumpadMultiply => 'Num *';

  @override
  String get keyboardKeyNumpadParenLeft => 'Num (';

  @override
  String get keyboardKeyNumpadParenRight => 'Num )';

  @override
  String get keyboardKeyNumpadSubtract => 'Num -';

  @override
  String get keyboardKeyPageDown => 'PgDown';

  @override
  String get keyboardKeyPageUp => 'PgUp';

  @override
  String get keyboardKeyPower => 'Power';

  @override
  String get keyboardKeyPowerOff => 'Power Off';

  @override
  String get keyboardKeyPrintScreen => 'Print Screen';

  @override
  String get keyboardKeyScrollLock => 'Scroll Lock';

  @override
  String get keyboardKeySelect => 'Select';

  @override
  String get keyboardKeySpace => 'Space';

  @override
  String get keyboardKeyShift => 'Shift';

  // ============================================================================
  // TEXT FIELD CHARACTER COUNT
  // ============================================================================

  @override
  String get remainingTextFieldCharacterCountZero => 'Nta nyuguti yasigaye';

  @override
  String get remainingTextFieldCharacterCountOne => 'Hasigaye inyuguti 1';

  @override
  String get remainingTextFieldCharacterCountTwo => r'Hasigaye inyuguti $remainingCount';

  @override
  String get remainingTextFieldCharacterCountFew => r'Hasigaye inyuguti $remainingCount';

  @override
  String get remainingTextFieldCharacterCountMany => r'Hasigaye inyuguti $remainingCount';

  @override
  String get remainingTextFieldCharacterCountOther => r'Hasigaye inyuguti $remainingCount';

  // ============================================================================
  // SELECTED ROW COUNT
  // ============================================================================

  @override
  String get selectedRowCountTitleZero => 'Nta kintu cyahiswemo';

  @override
  String get selectedRowCountTitleOne => 'Ikintu 1 cyahiswemo';

  @override
  String get selectedRowCountTitleTwo => r'Ibintu $selectedRowCount byahiswemo';

  @override
  String get selectedRowCountTitleFew => r'Ibintu $selectedRowCount byahiswemo';

  @override
  String get selectedRowCountTitleMany => r'Ibintu $selectedRowCount byahiswemo';

  @override
  String get selectedRowCountTitleOther => r'Ibintu $selectedRowCount byahiswemo';

  // ============================================================================
  // RAW STRING TEMPLATES (with placeholders)
  // ============================================================================

  @override
  String get aboutListTileTitleRaw => r'Kuri $applicationName';

  @override
  String get dateRangeEndDateSemanticLabelRaw => r'Itariki yo kurangiza $fullDate';

  @override
  String get dateRangeStartDateSemanticLabelRaw => r'Itariki yo gutangira $fullDate';

  @override
  String get pageRowsInfoTitleRaw => r'$firstRow–$lastRow muri $rowCount';

  @override
  String get pageRowsInfoTitleApproximateRaw => r'$firstRow–$lastRow hafi muri $rowCount';

  @override
  String get scrimOnTapHintRaw => r'Gufunga $modalRouteContentName';

  @override
  String get tabLabelRaw => r'Tab $tabIndex muri $tabCount';
}

// ==============================================================================
// DELEGATE FOR KINYARWANDA MATERIAL LOCALIZATIONS
// ==============================================================================

/// Delegate that loads Kinyarwanda Material localizations
class RwMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const RwMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // 🛡️ SAFETY CHECK: Helper to safely get a DateFormat
    // If 'rw' crashes (because data isn't loaded), it falls back to 'en'
    intl.DateFormat safeFormat(String pattern) {
      try {
        return intl.DateFormat(pattern, 'rw');
      } catch (e) {
        return intl.DateFormat(pattern, 'en');
      }
    }

    // 🛡️ SAFETY CHECK: Helper to safely get a NumberFormat
    intl.NumberFormat safeNumberFormat(String pattern) {
      try {
        return intl.NumberFormat(pattern, 'rw');
      } catch (e) {
        return intl.NumberFormat(pattern, 'en');
      }
    }

    return SynchronousFuture<MaterialLocalizations>(
      MaterialLocalizationsRw(
        fullYearFormat: safeFormat('y'),
        compactDateFormat: safeFormat('yMd'),
        shortDateFormat: safeFormat('yMMMd'),
        mediumDateFormat: safeFormat('EEE, MMM d'),
        longDateFormat: safeFormat('EEEE, MMMM d, y'),
        yearMonthFormat: safeFormat('yMMMM'),
        shortMonthDayFormat: safeFormat('MMM d'),
        decimalFormat: safeNumberFormat('#,##0.###'),
        twoDigitZeroPaddedFormat: safeNumberFormat('00'),
      ),
    );
  }

  @override
  bool shouldReload(RwMaterialLocalizationsDelegate old) => false;
}