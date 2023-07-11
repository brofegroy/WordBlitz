import 'package:shared_preferences/shared_preferences.dart';

class Config{
  static SharedPreferences? _preferences;

  static String gamemode = "fun"; // this is the default value
  static double blitzDuration = 180; //this is the default value
  static bool isBlitzAutocorrectQ = true;
  // when presented with words that is wrong in both Qu and Q,
  // do we assume they meant Qu and penalise them for it?
  //this bool answers that question.
  //Qu words are more common than words with only Q so the default value is true
  static bool isBlitzPenalisingQu = true;

  static Future<void> load () async{
    _preferences = await SharedPreferences.getInstance();
    var blitzDurationStoredValue = _preferences?.get("blitzDuration");
    blitzDuration = (blitzDurationStoredValue is double) ? blitzDurationStoredValue : 180;
  }

  static void changeGamemode(int modeNumber){/*TODO modeNumber currently unused*/
    gamemode = "practice";
    gamemode = "practiceQ";
    gamemode = "fun";
    return;
  }

  static Future<bool> changeBlitzDuration(double value) async{
    bool? isSubmitSuccessful = await _preferences?.setDouble("blitzDuration", value);
    blitzDuration = (isSubmitSuccessful??false) ? value : blitzDuration;
    return isSubmitSuccessful??false;
  }
}