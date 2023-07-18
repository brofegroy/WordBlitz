import 'package:flutter/services.dart' show rootBundle;
import 'package:wordblitz/tools/config.dart';

import 'package:wordblitz/features/Puzzle/PuzzleScreen/puzzle_screen_utils/generate_next_tiles/word_validator.dart';

class Dice{
  static String _dicePath = "resources/raw/dice_modern.txt";
  static late List<List<String>> txt;
  static bool isDiceLoading = false;
  static bool isDiceLoaded = false; //this boolean is important

  static Future<bool> load() async {
    ///returns true if error detected, false once it finishes loading
    if(isDiceLoaded){return false;}
    if (isDiceLoading == true){return true;}
    isDiceLoading = true;
    final String fileContent = await rootBundle.loadString(_dicePath);
    txt = await _processFileContent(fileContent);
    isDiceLoading = false;
    isDiceLoaded = true;
    return false;
  }

  static Future<List<List<String>>> _processFileContent(String fileContent){
    return Future(() =>
      fileContent.split('\n').map((diceIter) =>
          diceIter.trim()
              .split(' ')
              .where((value) => value.isNotEmpty)
              .toList()
      ).toList()
    );
  }

  static void _changeDicePath(newDicePath){ //TODO needs implement
    _dicePath = newDicePath;
  }
}

class Dict{
  static String _dictPath = "resources/raw/csw22.txt";
  static late Set<String> txt;
  static bool isDictLoading = false;
  static bool isDictLoaded = false; //important
  //i have stuff that depends on not reloading, also not reloading unnecessarily is a good thing

  static Future<bool> load() async {
    ///returns true if error detected, false once it finishes loading
    if(isDictLoaded){return false;}
    isDictLoading = true;
    final String fileContent = await rootBundle.loadString(_dictPath);
    txt = await _processFileContent(fileContent);
    if(Config.shouldPreloadPuzzleCache){await WordValidator.load();}
    isDictLoading = false;
    isDictLoaded = true;
    return false;
  }

  static Future<Set<String>> _processFileContent(String fileContent){
    return Future(() =>
      fileContent.split("\n")
          .map((wordIter) => wordIter.trim())
          .where((wordIter) => wordIter.isNotEmpty)
          .where((wordIter) => (wordIter.length >= 3)) //all words in CSW have length <= 16
          .toSet()
    );
  }

  static void _changeDictPath(newDictPath) { //TODO may need implement
    _dictPath = newDictPath;
  }
}