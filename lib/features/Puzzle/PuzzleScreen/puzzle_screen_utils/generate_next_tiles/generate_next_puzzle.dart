import 'dart:math';

import 'package:wordblitz/features/Puzzle/PuzzleScreen/puzzle_screen_utils/generate_next_tiles/puzzle_letters_cache.dart';
import 'package:wordblitz/tools/dict_and_dice.dart';


class PuzzleGenerator{
  static Random random = Random();

  //true means board layout will be based on dice loaded.
  static bool shouldUseDice = true;

  //default is with no blank tiles, but can be set to true
  static bool get isBlankTileEnabled => PuzzleCache.isBlankTileEnabled;
  static int get isBlankTileEnabledInt => PuzzleCache.isBlankTileEnabled?1:0;
  //default is 4 letter mode, but can be set to 3
  static bool get isFourLetterMode => PuzzleCache.isFourLetterMode;
  static int get isFourLetterModeInt => PuzzleCache.isFourLetterMode?1:0;

  //1 means we use the lotto system to determine next word, 0.75 means 3/4 the time we use lotto,minimum 0
  static double percentageUseLotto = 1.0;

  static String NextPuzzle(){
    int requestedLength = 3 + isFourLetterModeInt;
    bool shouldUseLotto = (random.nextDouble() < percentageUseLotto);

    if(shouldUseLotto){
      return _generateLottoLayout(isFromDice: shouldUseDice);
    } else {
      return _randomLayout(requestedLength,isFromDice: shouldUseDice);
    }
  }

  static String _randomLayout(int length,{bool isFromDice = true}){
    if(isFromDice) {
      List<String> boardLayout = List.generate(16, (index) => Dice.txt
      [List<int>.unmodifiable(List.generate(16, (index) => index)..shuffle())[index]]
      [List<int>.unmodifiable(List.generate(16, (_) => random.nextInt(6)))[index]]
      );
      return boardLayout.sublist(0, length).join();
    }
    else{
      return (_randomLetter()+_randomLetter()+_randomLetter()+_randomLetter());
    }
  }
  static String _randomLetter(){
    Random random = Random();
    int asciiValue = random.nextInt(26) + 65; // Generate a random number between 65 and 90 (ASCII values for capital letters)
    String letter = String.fromCharCode(asciiValue); // Convert ASCII value to character
    return letter;
  }

  static String _generateLottoLayout({bool isFromDice = true}){
    double randomValue = random.nextDouble();
    String lottoString = PuzzleCache.drawAllLotto();
    int requiredLength = (3 + isFourLetterModeInt);
    print("output lottoString is $lottoString");
    if (!lottoString.contains("QU")){
      lottoString.replaceFirst("QU", "Q");
    }
    while (lottoString.length < requiredLength){
      String possibleTiles = _randomLayout(4,isFromDice: isFromDice);
      List<String> remainingTiles = possibleTiles.split("").toSet().difference(lottoString.split("").toSet()).toList()..shuffle();
      lottoString = lottoString + remainingTiles[0];
    }
    if (lottoString.length > requiredLength){
      List<String> remainingTiles = lottoString.split("")..shuffle();
      lottoString = remainingTiles.join().substring(0,requiredLength);
    }
    return lottoString;
  }

}