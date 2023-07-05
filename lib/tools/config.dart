class Config{
  static String gamemode = "fun";
  static int blitzDuration = 180; //[hardcoded]
  static bool isBlitzAutocorrectQ = true;
  // when presented with words that is wrong in both Qu and Q,
  // do we assume they meant Qu and penalise them for it?
  //this bool answers that question.
  //Qu words are more common than words with only Q so the default value is true
  static bool isBlitzPenalisingQu = true;

  static void changeGamemode(int modeNumber){/*TODO modeNumber currently unused*/
    gamemode = "practice";
    gamemode = "practiceQ";
    gamemode = "fun";
    return;
  }
}