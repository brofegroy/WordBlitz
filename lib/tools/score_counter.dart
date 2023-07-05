import 'dict_and_dice.dart';

class ScoreCounter{
  static final List<int> wordScoreConfig = List.unmodifiable([
    0,0,0,
    1,1,2,
    3,5,7,
  ]);
  static final List<int> wordPenaltyConfig = List.unmodifiable([
    0,0,0,
    1,1,1,
    2,3,4,
  ]);

  static int countScore(String submittedWord ,[Set<String>? dictionary]){
    ///optional:pass in a dictionary to check against,
    ///otherwise it will just check against the static Dict class
    ///returns a positive score value if valid, returns a negative penalty value if not valid
    dictionary ??= Dict.txt;
    if (_checkValid(submittedWord,dictionary) )
    {return countWordScore(submittedWord);}
    else
    {return (-1 * countPenaltyScore(submittedWord));}
  }

  static int countWordScore(String submittedWord){
    if (submittedWord.length >= 8){return wordScoreConfig[8];}
    return wordScoreConfig[submittedWord.length];
  }

  static int countPenaltyScore(String submittedWord){
    if (submittedWord.length >= 8){return wordPenaltyConfig[8];}
    return wordPenaltyConfig[submittedWord.length];
  }

  static bool _checkValid(String submittedWord,Set<String> dictionary){
    return (dictionary.contains(submittedWord));
  }
}