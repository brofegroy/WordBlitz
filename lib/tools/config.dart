import 'package:shared_preferences/shared_preferences.dart';

class Config{
  static SharedPreferences? _preferences;

  static double _blitzDuration = 180; //this is the default value
  static bool _isNightMode = false;
  static String gamemode = "fun"; // this is the default value
  static bool isBlitzAutocorrectQ = true;
  // when presented with words that is wrong in both Qu and Q,
  // do we assume they meant Qu and penalise them for it?
  //this bool answers that question.
  //Qu words are more common than words with only Q so the default value is true
  static bool isBlitzPenalisingQu = true;

  static bool _shouldPreloadPuzzleCache = true;

  // getters and setters
  static double get blitzDuration => _blitzDuration;
  static bool get isNightMode => _isNightMode;
  static bool get shouldPreloadPuzzleCache => _shouldPreloadPuzzleCache;
  //

  static Future<void> load () async{
    _preferences = await SharedPreferences.getInstance();
    var blitzDurationStoredValue = _preferences?.get("blitzDuration");
    _blitzDuration = (blitzDurationStoredValue is double) ? blitzDurationStoredValue : _blitzDuration;
    var isNightModeStoredValue = _preferences?.get("isNightMode");
    _isNightMode = (isNightModeStoredValue is bool) ? isNightModeStoredValue : _isNightMode;
    var shouldLoadPuzzleCacheStoredValue = _preferences?.get("shouldLoadPuzzleCache");
    _shouldPreloadPuzzleCache = (shouldLoadPuzzleCacheStoredValue is bool) ? shouldLoadPuzzleCacheStoredValue : _shouldPreloadPuzzleCache;
  }

  static void changeGamemode(int modeNumber){/*TODO modeNumber currently unused*/
    gamemode = "practice";
    gamemode = "practiceQ";
    gamemode = "fun";
    return;
  }

  static Future<bool> changeBlitzDuration(double value) async{
    bool? isSubmitSuccessful = await _preferences?.setDouble("blitzDuration", value);
    _blitzDuration = (isSubmitSuccessful??false) ? value : _blitzDuration;
    return isSubmitSuccessful??false;
  }

  static Future<bool> changeIsNightMode(bool value) async{
    bool? isSubmitSuccessful = await _preferences?.setBool("isNightMode", value);
    _isNightMode =  (isSubmitSuccessful??false) ? value : _isNightMode;
    return isSubmitSuccessful??false;
  }
}