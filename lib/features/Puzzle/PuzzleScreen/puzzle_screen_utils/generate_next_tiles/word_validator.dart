import 'package:wordblitz/features/Puzzle/PuzzleScreen/puzzle_screen_utils/generate_next_tiles/func_calculate_lotto.dart';

import 'package:wordblitz/tools/Database/database_helper.dart';
import 'package:wordblitz/tools/Database/game_stats_model.dart';
import 'package:wordblitz/tools/dict_and_dice.dart';

import 'puzzle_letters_cache.dart';

class WordValidator{

  static Set<String> puzzleDict3 = {};
  static Set<String> puzzleDict4 = {};
  static Set<String> puzzleDict5 = {};
  static Set<String> puzzleDict6qu = {};
  static final List<Set<String>> puzzleDicts = [puzzleDict3,puzzleDict4,puzzleDict5,puzzleDict6qu];

  static Future<void> load() async{
    for (String word in Dict.txt) {
      switch (word.length) {
        case 3:
          puzzleDict3.add(word);
          break;
        case 4:
          puzzleDict4.add(word);
          break;
        case 5:
          puzzleDict5.add(word);
          break;
        case 6:
          if (word.contains('QU')) {puzzleDict6qu.add(word);}
          break;
      }
    }

    bool databaseRequiringFirstTimeInitialisation = await PuzzleCache.load();
    if(databaseRequiringFirstTimeInitialisation == true){
      final List<GameStats> gameStatsList = [];
      for (Set<String> lengthDictionary in puzzleDicts){
        for(String validWord in lengthDictionary){
          gameStatsList.add(GameStats(word: validWord, isWordCorrect: true, embeddedInt: 0));
        }
      }
      await DatabaseHelper.instance.bulkCreate(gameStatsList);
      databaseRequiringFirstTimeInitialisation = await PuzzleCache.load();
    }
  }

  static bool isWordCorrect(String word){
    if (word.length<3){throw("word too short");}
    if (word.length>6){throw("word too long");}
    return puzzleDicts[word.length-3].contains(word);
  }

  static Future<void> submitPuzzleCorrections(List<String> words)async{
    print("submitted corrections for $words");
    for (int i=0;i<words.length;i++){
      if(isWordCorrect(words[i])){throw("Error: Not supposed to have correct words here");}
      else{await _submitCorrection(words[i]);}
    }
  }
  static Future<void> _submitCorrection(String word) async{
    GameStats gameStats = await DatabaseHelper.instance.readGameStats(word);
    int embeddedInt = ((gameStats.embeddedInt << 1)|(1)) & 0xFFFFFFFF; //0xFFFFFFFF is the bitmask for 32 1's
    print("embedded int for $word is now ${embeddedInt.toRadixString(2)}");
    if (embeddedInt == 0xFFFFFFFF){
      await DatabaseHelper.instance.delete(word);
      PuzzleCache.baseLetterNode.removeWordFromTreeAndUpdate(word);
    } else{
      GameStats newGameStats = GameStats(word: word, isWordCorrect: false, embeddedInt: embeddedInt);
      await DatabaseHelper.instance.update(newGameStats);
      PuzzleCache.baseLetterNode.precisionUpdateWordLotto(word,calculateLotto(embeddedInt));
    }
  }
  static Future<void> savePuzzleResults(List<String> words, List<bool> results) async{
    for (int i=0;i<words.length;i++){
      await submitWordResult(words[i], results[i]);
    }
    //TODO find a way to reduce tickets of fake words.
  }
  static Future<void> submitWordResult(String word,bool savedEmbeddedBool) async{
    try {
      GameStats gameStats = await DatabaseHelper.instance.readGameStats(word);
      int embeddedInt = (((gameStats.embeddedInt<< 1)|(savedEmbeddedBool?1:0)) & 0xFFFFFFFF);
      GameStats newGameStats = GameStats(word: word, isWordCorrect: gameStats.isWordCorrect, embeddedInt: embeddedInt);
      await DatabaseHelper.instance.update(newGameStats);
      PuzzleCache.baseLetterNode.precisionUpdateWordLotto(word,calculateLotto(embeddedInt));
    } on WordNotFoundException {
      await DatabaseHelper.instance.create(GameStats(word: word, isWordCorrect: false, embeddedInt: 0));
      PuzzleCache.baseLetterNode.createWord(word);
    }
  }

  static Set<String> getRelevantWords(String tiles,{bool withBlankTile = false, bool filterNonHooks = false}){
    if(!withBlankTile && filterNonHooks){throw("Error: cannot filter hooks without blank tiles");}
    Set<String> relevantWords = PuzzleCache.baseLetterNode.getRelevantChildren(tiles,withBlankTile: withBlankTile);
    return (filterNonHooks)?_filterForHooks(relevantWords):relevantWords;
  }
  static Set<String> getFormableWords(String tiles,{bool withBlankTile = false, bool filterNonHooks = false}){
    if(!withBlankTile && filterNonHooks){throw("Error: cannot filter hooks without blank tiles");}
    Set<String> formableWords = {};
    List<String> tilesList = tiles.split("").toList();
    for (int i = 0; i<(tiles.length -2+(withBlankTile?1:0)); i++){
      for (String validWord in puzzleDicts[i]){
        List<String> checklist = validWord.split("");
        for (String letter in tilesList){checklist.remove(letter);}
        if (checklist.length <= (withBlankTile?1:0)){formableWords.add(validWord);}
      }
    }
    if (tiles.contains("Q")){
      for (int i = 0; i<(tiles.length -1+(withBlankTile?1:0)); i++){
        for (String validWord in puzzleDicts[i]){
          if(validWord.contains("QU")){
            List<String> checklist = validWord.replaceFirst("QU", "Q").split("");
            for (String letter in tilesList){checklist.remove(letter);}
            if (checklist.length <= (withBlankTile?1:0)){formableWords.add(validWord);}
          };
        }
      }
    }
    return (filterNonHooks)?_filterForHooks(formableWords):formableWords;
  }
  static Set<String> _filterForHooks(Set<String> inputSet){
    Set<String> filteredSet = {};
    for(String word in inputSet){
      String frontHookWord = word.substring(1);
      String backHookWord = word.substring(0,word.length-1);
      if(isWordCorrect(frontHookWord) || isWordCorrect(backHookWord)){
        filteredSet.add(word);
      }
    }
    return filteredSet;
  }
}