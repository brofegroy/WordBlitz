

import 'dart:math';

import 'package:wordblitz/tools/Database/database_helper.dart';
import 'package:wordblitz/tools/Database/game_stats_model.dart';
import 'package:wordblitz/tools/dict_and_dice.dart';
import 'package:wordblitz/tools/global.dart';


import 'puzzle_letters_cache.dart';
import 'func_calculate_lotto.dart';

class WordValidator{

  static Set<String> puzzleDict3 = {};
  static Set<String> puzzleDict4 = {};
  static Set<String> puzzleDict5 = {};
  static Set<String> puzzleDict6qu = {};
  static final List<Set<String>> puzzleDicts = [puzzleDict3,puzzleDict4,puzzleDict5,puzzleDict6qu];

  static Set<String> diceCombination3 = {};
  static Set<String> diceCombination4 = {};

  static Future<void> load() async{
    assignDict();
    assignDice();

    List<GameStats> gameStatsList= await DatabaseHelper.instance.readAllGameStats();
    List<GameStats> boardGameStatsList = await DatabaseHelper.instance.readAllGameStats(accessedTable: boardGameStatsTable);
    bool databaseRequiringFirstTimeInitialisation = (gameStatsList.length == 0);
    bool databaseRequiringFirstTimeInitialisationBoard = (boardGameStatsList.length == 0);
    if(databaseRequiringFirstTimeInitialisation){
      for (Set<String> lengthDictionary in puzzleDicts){
        for(String validWord in lengthDictionary){
          gameStatsList.add(GameStats(word: validWord, embeddedInt: 0));
        }
      }
      await DatabaseHelper.instance.bulkCreate(gameStatsList);
    }
    if(databaseRequiringFirstTimeInitialisationBoard){
      for(String boardCombination in diceCombination3){
        boardGameStatsList.add(GameStats(word: boardCombination, embeddedInt: 0));
      }
      for(String boardCombination in diceCombination4){
        boardGameStatsList.add(GameStats(word: boardCombination, embeddedInt: 0));
      }
      await DatabaseHelper.instance.bulkCreate(boardGameStatsList,accessedTable: boardGameStatsTable);
    }
    PuzzleCache.load(gameStatsList,boardGameStatsList);
  }

  static void assignDice(){
    for(int i = 0; i<16;i++){for(int a = 0; a<6;a++){
      Set<String> diceCombination3staging = {};
      Set<String> diceCombination4staging = {};
      for(int j = i+1; j<16;j++){for(int b = 0; b<6;b++){
            for(int k = j+1; k<16;k++){for(int c = 0; c<6;c++){
                List<String> formedListString = [Dice.txt[i][a],Dice.txt[j][b],Dice.txt[k][c]]..sort();
                String formedCombo = formedListString.join().toString();
                diceCombination3staging.add(formedCombo);
                for(int index = k+1;index<16;index++){for(int d = 0; d<6;d++){
                    List<String> fourListString = (formedCombo + Dice.txt[index][d]).split("")..sort();
                    diceCombination4staging.add(fourListString.join().toString());
                }}
            }}
      }}
      diceCombination3.addAll(diceCombination3staging);
      diceCombination4.addAll(diceCombination4staging);
    }}
  }
  static void assignDict(){
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
      GameStats newGameStats = GameStats(word: word, embeddedInt: embeddedInt);
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
      GameStats newGameStats = GameStats(word: word, embeddedInt: embeddedInt);
      await DatabaseHelper.instance.update(newGameStats);
      PuzzleCache.baseLetterNode.precisionUpdateWordLotto(word,calculateLotto(embeddedInt));
    } on WordNotFoundException {
      await DatabaseHelper.instance.create(GameStats(word: word, embeddedInt: 0));
      PuzzleCache.baseLetterNode.createWord(word);
    }
  }
  static Future<void> submitGridResult(String word,bool savedEmbeddedBool) async{
    try {
      GameStats gameStats = await DatabaseHelper.instance.readGameStats(word,accessedTable: boardGameStatsTable);
      int embeddedInt = ((gameStats.embeddedInt<< 1) & 0xFFFFFFFF);
      //this check is to speed up the disposal of junk combos like WWWW.
      if ((_checkIfRealComboWithBlankTile(word) != null) //if it is null means it is a real word even without use of blank tile.
          && ((embeddedInt & ~0xFFFF)!=0)
          && (savedEmbeddedBool == true)
      ){
        if(_checkIfRealComboWithBlankTile(word) == false){embeddedInt = 0xFFFF;}
        else{embeddedInt = (embeddedInt<<1)|3;} //this is the case where its a real combo but needs a blank tile to be real.
      }
      embeddedInt == embeddedInt|(savedEmbeddedBool?1:0);
      GameStats newGameStats = GameStats(word: word, embeddedInt: embeddedInt);
      await DatabaseHelper.instance.update(newGameStats,accessedTable: boardGameStatsTable);
      PuzzleCache.baseBoardNode.precisionUpdateWordLotto(word, calculateLotto(embeddedInt));
    } on WordNotFoundException {
      //means the board wasn't makable in a real game anyways, no action required.
    }
  }
  static bool? _checkIfRealComboWithBlankTile(String word){
    //returns null if word is real without blank tile,true if requiring blank tile,false otherwise
    List<String> tilesList = word.split("");
    int hasQ = tilesList.contains("Q")?1:0;
    bool realWithBlankTile = false;
    for(int i=0;i<3+hasQ;i++){
      for (String validWord in puzzleDicts[i]){
        List<String> checklist = validWord.split("");
        for (String letter in tilesList){checklist.remove(letter);}
        if (checklist.length <= 1){
          if(checklist.length <= 0){return null;}
          realWithBlankTile = true;
        }
      }
    }
    return realWithBlankTile;
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