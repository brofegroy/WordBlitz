
import 'package:flutter/material.dart';

import 'puzzle_screen_utils/generate_next_tiles/generate_next_puzzle.dart';
import 'puzzle_screen_utils/puzzle_drag_position.dart';
import 'puzzle_screen_utils/generate_next_tiles/word_validator.dart';

const GRID_SCRWIDTH_PCT = 0.5;

class PuzzleScreenController{
  BuildContext context;
  Size screenSize;

  final ValueNotifier<bool> isConfirmButtonEnabled = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isBlankTileModeEnabledNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> currentBlankTileLetterNotifier = ValueNotifier<String>("A");

  final ValueNotifier<int> displayWrongCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> displayCorrectCountNotifier = ValueNotifier<int>(0);
  final List<ValueNotifier<String>> boardLayoutNotifier = List.unmodifiable(List.generate(4, (_) => ValueNotifier<String>("Z")));
  final ValueNotifier<bool> isResultsVisible = ValueNotifier<bool>(false);
  final List<ValueNotifier<bool>> isTileSelectedNotifier = List.unmodifiable(List.generate(5, (_) => ValueNotifier<bool>(false)));
  final ValueNotifier<String> currentSelectedLettersNotifier =  ValueNotifier<String>("");

  /// [wordListLengthNotifier] must be manually updated for dismissible to work, so use _insertWordToList() instead.
  final ValueNotifier<int> wordListLengthNotifier = ValueNotifier<int>(0); //TODO reset to 0
  List<String> wordList = []; //do not edit this value directly
  List<Color> wordColorList = [];
  final Color colorCorrect = Colors.green; //colour constants todo edit preferred colours here.
  final Color colorWrong = Colors.redAccent;
  final Color colorMiss = Colors.grey;
  Set<String> formableWords = {};
  //this is the set of words that they have gotten wrong in the past, where if user does not repeat mistakes, user should be rewarded for it
  Set<String> previouslyFakedWords = {};
  bool isWordSearchLoading = false;
  bool? hasBoardBeenAttemptedOnce = false; //not false if attempted,null if currently is not showing first result
  List<String> firstAttemptWordList = []; //this is for the retry button
  List<Color> firstAttemptColorList = [];
  bool shouldAllowChangeAnswerConfig = false;///todo make functionality to edit this value


  int get wrongCount => displayWrongCountNotifier.value;
  set wrongCount(value) => displayWrongCountNotifier.value = value;
  int get correctCount => displayCorrectCountNotifier.value;
  set correctCount(value) => displayCorrectCountNotifier.value = value;
  String get letters => currentSelectedLettersNotifier.value;
  set letters(value) => currentSelectedLettersNotifier.value = value;

  PuzzleScreenController({
    required this.context,
    required this.screenSize,
  }){
    handleSkipPressed();
  }
  
  void _assignTiles(List<String> list){
    for (int i=0;i<4;i++){
      if (list[i] == ""){
        list[i] = list[3];
        list[3] = "";
      }
      boardLayoutNotifier[i].value = list[i];
    }
  }
  String _getTiles(){
    List<String> tileList = [
      boardLayoutNotifier[0].value,
      boardLayoutNotifier[1].value,
      boardLayoutNotifier[2].value,
      boardLayoutNotifier[3].value,]..sort();
    return tileList.join();
  }

  Future<void> _startSafetyConfirmButtonTimer() async{
    isConfirmButtonEnabled.value = false;
    await Future.delayed(Duration(milliseconds: 500));
    isConfirmButtonEnabled.value = true;
  }

  void handleOnWillPop() {
    Navigator.pop(context);
    return;
  }

  void handleSkipPressed() async{
    if (isWordSearchLoading){return;}
    isWordSearchLoading = true;
    _startSafetyConfirmButtonTimer();

    handleClearCurrentWord();
    wordList = [];
    wordColorList = [];
    wordListLengthNotifier.value = 0;
    hasBoardBeenAttemptedOnce = false;
    isResultsVisible.value = true; //need to do a value update for both cases
    isResultsVisible.value = false;

    bool isBlankTileEnabled = PuzzleGenerator.isBlankTileEnabled;
    isBlankTileModeEnabledNotifier.value = isBlankTileEnabled;

    String nextPuzzle = PuzzleGenerator.NextPuzzle();
    _assignTiles(nextPuzzle.split("") + [""]);
    formableWords = WordValidator.getFormableWords(nextPuzzle,withBlankTile: isBlankTileEnabled);
    previouslyFakedWords = WordValidator.getRelevantWords(nextPuzzle,withBlankTile: isBlankTileEnabled).difference(formableWords);
    handleShufflePressed();

    isWordSearchLoading = false;
  }
  void handleSaveDataAndLoadNext() async{
    if (isWordSearchLoading){return;}
    if (!shouldAllowChangeAnswerConfig && hasBoardBeenAttemptedOnce == null){throw("not supposed to be able to submit other answers");}

    bool isAllWordsCorrect = true;
    for (Color color in wordColorList){
      if(color != colorCorrect){isAllWordsCorrect = false;break;}
    }
    if(isAllWordsCorrect){displayCorrectCountNotifier.value += 1;}
    else{displayWrongCountNotifier.value += 1;}

    List<bool> results = wordColorList.map((color) => color == colorCorrect ? true : false).toList();
    List<String> wordsNotFaked = previouslyFakedWords.difference(wordList.toSet()).toList();
    await WordValidator.savePuzzleResults(wordList,results);
    await WordValidator.submitPuzzleCorrections(wordsNotFaked);
    await WordValidator.submitGridResult(_getTiles(),isAllWordsCorrect);
    print(_getTiles());

    handleSkipPressed();
  }

  void handleShufflePressed() {
    handleClearCurrentWord();
    List<String> shuffled = boardLayoutNotifier.map((notifier) =>
    notifier.value).toList()
      ..shuffle();
    _assignTiles(shuffled);
  }

  void handleConfirmPressed() async{
    if (!wordList.every((word) => word.length <= 5)){
      handleOnWillPop(); //TODO make it show to user that an error caused it to pop
      throw ("Error in dismissible:word.length>5");
    }
    await Future.delayed(Duration(milliseconds: 50));
    List<String> missedWords = formableWords.difference(wordList.toSet()).toList();
    for (String missedWord in missedWords){_insertToWordList(missedWord,colorMiss);}
    if(shouldAllowChangeAnswerConfig){hasBoardBeenAttemptedOnce = true;}
    else{if(hasBoardBeenAttemptedOnce != null){hasBoardBeenAttemptedOnce = true;}}
    isResultsVisible.value = true;
    //TODO prepare next random. ahead of time,optional
  }

  void handleOnPannedStart(DragStartDetails details){
    int? index = GetPuzzleDragPosition.getDragIndex(details.localPosition.dx,details.localPosition.dy,screenSize.width*GRID_SCRWIDTH_PCT);
    if(index != null){_handleTileSwipedAtIndex(index);}
  }
  void handleOnPannedEnd(DragEndDetails details){
    if(!isBlankTileModeEnabledNotifier.value){
      handleAddWord();
    }
  }
  void handleGridOnPanned(DragUpdateDetails details){
    int? index = GetPuzzleDragPosition.getDragIndex(details.localPosition.dx,details.localPosition.dy,screenSize.width*GRID_SCRWIDTH_PCT);
    if(index != null){_handleTileSwipedAtIndex(index);}
  }
  void _handleTileSwipedAtIndex(int index){
    if (isWordSearchLoading){return;}
    String tileLetter = boardLayoutNotifier[index].value;
    if (tileLetter.isEmpty){return;}
    if (!isTileSelectedNotifier[index].value){
     letters += tileLetter;
     isTileSelectedNotifier[index].value = true;
    }
  }
  void handleGridOnTapped(TapUpDetails details){
    int index = 0;
    if(details.localPosition.dx>screenSize.width*GRID_SCRWIDTH_PCT/2){index+=1;}
    if(details.localPosition.dy>screenSize.width*GRID_SCRWIDTH_PCT/2){index+=2;}
    _handleTileSelectedAtIndex(index);
  }
  void _handleTileSelectedAtIndex(int index){
    if (isWordSearchLoading){return;}
    String tileLetter = boardLayoutNotifier[index].value;
    if (tileLetter.isEmpty){return;}
    if (!isTileSelectedNotifier[index].value){
      letters += tileLetter;
    } else {
      String lettersAfterRemoval = letters.replaceFirst(tileLetter, '');
      if (letters.length == lettersAfterRemoval.length){throw("Error: no valid letters to remove");}
      letters = lettersAfterRemoval;
    }
    isTileSelectedNotifier[index].value = ! isTileSelectedNotifier[index].value;
  }
  void handleRetry(){
    if (hasBoardBeenAttemptedOnce != null){
      firstAttemptWordList = wordList;
      firstAttemptColorList = wordColorList;
      hasBoardBeenAttemptedOnce = null;
    }
    isResultsVisible.value = false;
    handleClearList();
  }
  void handleReloadFirstAttempt(){
    if (hasBoardBeenAttemptedOnce != null){return;}
    wordList = firstAttemptWordList;
    wordColorList = firstAttemptColorList;
    wordListLengthNotifier.value = wordList.length;
    hasBoardBeenAttemptedOnce = true;
    isResultsVisible.value = false; //needs to refresh the listener here
    isResultsVisible.value = true;
  }

  void handleRemoveOneLetter(){
    if (letters.isNotEmpty){
      String removedLetter = letters[letters.length-1];

      for (int i=0;i<5;i++){
        String tileLetter = (i < 4) ? boardLayoutNotifier[i].value : removedLetter;
        bool isTileSelected = isTileSelectedNotifier[i].value;
        if (tileLetter == removedLetter && isTileSelected){
          isTileSelectedNotifier[i].value = false;
          letters = letters.substring(0,letters.length-1);
          return;
        }
      }
      handleOnWillPop();
      throw("Error: no corresponding tile matching last letter can be removed");
    }
  }
  void handleAddWord(){
    if (!wordList.contains(letters) && letters.isNotEmpty){
      if((!isResultsVisible.value) && letters.length>2){
        bool hasInsertedValidWordYet = false;
        if(letters.contains("Q")){
          String QULetter = letters.replaceFirst("Q", "QU");
          if (formableWords.contains(QULetter)){_insertToWordList(QULetter, colorCorrect);hasInsertedValidWordYet = true;}
        }
        if(hasInsertedValidWordYet == false){
          _insertToWordList(letters,(formableWords.contains(letters) ? colorCorrect : colorWrong));
        } else {
          if (formableWords.contains(letters)){_insertToWordList(letters,colorCorrect);/*hasInsertedValidWord = true*/}
        }
      }
    }
    handleClearCurrentWord();
  }
  void _insertToWordList(String word,Color wordColor){
    wordList.insert(0, word);
    wordColorList.insert(0, wordColor);
    wordListLengthNotifier.value++;
  }
  void handleClearCurrentWord(){ //this clears letters, not the list
    isTileSelectedNotifier.forEach((isSelected) =>isSelected.value = false);
    letters = "";
  }
  void handleRemoveWord(int index){
    wordList.removeAt(index);
    wordColorList.removeAt(index);
    wordListLengthNotifier.value--;
  }
  void handleClearList(){
    wordList = [];
    wordColorList = [];
    wordListLengthNotifier.value = 0;
  }


}