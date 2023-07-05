import 'package:flutter/services.dart' show rootBundle;

class Dice{
  static String dicePath = "resources/raw/dice_modern.txt";
  static late List<List<String>> txt;
  static bool isDiceLoading = false;

  static Future<bool> load() async {
    ///returns true if error detected, false once it finishes loading
    if (isDiceLoading == true){return true;}
    isDiceLoading = true;
    final String fileContent = await rootBundle.loadString(dicePath);
    txt = await _processFileContent(fileContent);
    isDiceLoading = false;
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
    dicePath = newDicePath;
  }
}

class Dict{
  static String dictPath = "resources/raw/csw22.txt";
  static late Set<String> txt;
  static bool isDictLoading = false;
  static late Set<String> wordsWithQButNotFollowedByU;

  static Future<bool> load() async {
    ///returns true if error detected, false once it finishes loading
    print('reached here');

    isDictLoading = true;
    final String fileContent = await rootBundle.loadString(dictPath);
    txt = await _processFileContent(fileContent);
    wordsWithQButNotFollowedByU = await _filterQnoUWords();
    isDictLoading = false;
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

  static Future<Set<String>> _filterQnoUWords(){
    return Future(()=>
        txt
            .where((wordIter) => wordIter.contains("Q"))
            .where((wordIter) => !wordIter.contains("QU"))
            .toSet()
    );
  }

  static void _changeDictPath(newDictPath) { //TODO may need implement
    dictPath = newDictPath;
  }
}