import 'dart:math';

import 'package:tuple/tuple.dart';

import 'package:wordblitz/tools/score_counter.dart';
import 'package:wordblitz/tools/config.dart';
import 'package:wordblitz/tools/dict_and_dice.dart';

class BlitzScreenModel{
  // these functions to be provided by class initialising this
  late final Function letterChanged;
  late final Function resetGrid;
  late final Function(int,int,bool) updateGrid;
  late final Function updateDisplayScore;
  late final Function updateUIWordList;
  //
  // variables
  int currentWordScore = 0;
  int currentPenaltyScore = -0;
  List<String> gridLayout;
  List<Tuple2<int,int>> letters = [];
  List<String> submittedList = [];
  Set<String>? formableWords = Dict.txt; //TODO make algorithm that shortens list.
  //
  //constructor
  BlitzScreenModel(this.gridLayout);
  //

  //methods
  void handleClickedCell(int row,int col){
    //add first letter
    if (letters.isEmpty){
      letters.add(Tuple2(row, col));
      updateGrid(row,col,true);
      return;
    }
    //checks for repeats
    if (letters.contains(Tuple2(row, col))){
      //backtracks if previous cell
      if (letters.length > 1 ){
        if (letters[letters.length-2] == Tuple2(row, col)){
          int unselectRow = letters.last.item1;
          int unselectCol = letters.last.item2;
          letters.removeLast();
          updateGrid(unselectRow,unselectCol,false);
          return;
        }
      }
      //handler does nothing if the repeat is not the previous letter
      return;
    }
    //checks if its range
    if((letters.last.item1 - row).abs() <=1 && (letters.last.item2 - col).abs() <=1){
      letters.add(Tuple2(row, col));
      updateGrid(row,col,true);
      return;
    }
    //otherwise do nothing
  }
  void handleSubmit (){
    if (letters.length <3){letters = [];return;}
    //form the word
    String formedWord = letters.map(
            (Tuple2<int,int> rowColIndex) =>
            gridLayout[rowColIndex.item1 *4 + rowColIndex.item2]
    ).join();
    //clear letters
    letters = [];
    //form the Qu word
    String formedQuWord = formedWord.replaceAll("Q", "QU");

    print("formed word is $formedWord");
    print("formed formedQuWord is $formedQuWord");
    if(submittedList.contains(formedWord) || submittedList.contains(formedQuWord)){return;}
    //checks for the majority case where word does not contain Q
    if(!formedWord.contains("Q")){
      int scoreChange = ScoreCounter.countScore(formedWord);
      _submitWord(formedWord,scoreChange);
      _updateUI();
      return;
    }
    //at this point,word contains Q and is not already submitted before
    int qScore = ScoreCounter.countScore(formedWord);
    int quScore = ScoreCounter.countScore(formedQuWord);
    //if have autocorrect, submit the correct word amongst the two
    if(Config.isBlitzAutocorrectQ){
      if(qScore>0){_submitWord(formedWord, qScore);}
      if(quScore>0){_submitWord(formedQuWord, quScore);}
      if(quScore<0 && qScore<0){
        if(Config.isBlitzPenalisingQu){_submitWord(formedQuWord, quScore);}
        else{_submitWord(formedWord, qScore);}
      }
    }
    //if no autocorrect, submit both q and qu
    else{
      _submitWord(formedWord, qScore);
      _submitWord(formedQuWord, quScore);
    }
    ///note:there is another _updateUI() call within this function
    _updateUI();
    return;
  }
  void _updateUI(){
    updateDisplayScore();
    updateUIWordList();
  }
  void _submitWord(String submittedWord,int scoreChange){
    submittedList += [submittedWord];
    currentWordScore += max(scoreChange, 0);
    currentPenaltyScore += min(scoreChange,0);
  }
  void reInitialise(initialList){
    for (String word in initialList){
      print("reinitialised $word");
      int score = ScoreCounter.countScore(word);
      print("reinitialised $word's score is $score");
      _submitWord(word, score);
    }
  }
  void removeWord(int index){
    if (index <= submittedList.length){
      String removedWord = submittedList[index];
      submittedList.removeAt(index);
      int scoreChange = ScoreCounter.countScore(removedWord,formableWords);
      currentWordScore -= max(scoreChange, 0);
      currentPenaltyScore -= min(scoreChange,0);
      return;
    }
    throw Exception("Error: tried to remove word at non existent index");
  }

  //
}