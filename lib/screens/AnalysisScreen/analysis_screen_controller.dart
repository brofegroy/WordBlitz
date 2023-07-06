import 'package:flutter/cupertino.dart';
import 'package:wordblitz/screens/AnalysisScreen/analysis_screen.dart';
import 'package:wordblitz/tools/score_counter.dart';

class AnalysisScreenController{
  //variables
  final BuildContext context;
  List<String> initialList = [];
  List<String>? gridLayout;
  int wordScore = 0;
  int penaltyScore = 0;
  List<int> wordScoreList = [];
  final ValueNotifier<List<int>> submitCalledNotifier= ValueNotifier<List<int>>([0]);
  late final List<ValueNotifier<bool>> strikethroughStateNotifierList;
  //
  // getters,setters
  get totalScore => wordScore + penaltyScore;
  //
  //constructor
  AnalysisScreenController({
    required this.context,
    required this.initialList,
    required this.gridLayout,
  }){
    if ( ! isGridLayoutValid(gridLayout) || ! isInitialListValid(initialList)){navigatorPop();}
    strikethroughStateNotifierList = List.generate(initialList.length, (index) => ValueNotifier<bool>(false));
  }
  //

  bool isGridLayoutValid(List<String>? gridLayout){
    //filters length != 16
    if (gridLayout?.length != 16){return false;}
    //filters characters != A to Z
    for (int i =0;i<16;i++){
      String letter = gridLayout![i];
      if (letter.length!= 1){return false;}
      if ( ! isLetterAnUppercase(letter)){
        print("letter $letter is not valid");
        return false;
      }
    }
    //accepts if made it through filters
    return true;
  }
  bool isInitialListValid(List<String>? initialList){
    // tests for all words in list if is in capital letters
    if (initialList == null){return false;}
    //checks each word
    for (String word in initialList){
      //checks each letter
      for (int i =0;i<word.length;i++){
        if ( ! isLetterAnUppercase(word[i])){ print("word $word is not valid");return false;}
      }
    }
    //accepts if made it through filters
    return true;
  }
  bool isLetterAnUppercase(String letter){
    //this is a helper function for checking validity of gridLayout and initialList
    //only checks first char because it assumes a char input
    if (letter.codeUnitAt(0)<"A".codeUnitAt(0)
        || letter.codeUnitAt(0)>"Z".codeUnitAt(0)) {return false;}
    else {return true;}
  }

  bool handleOnWillPop(){
    navigatorPop();
    return true;
  }
  void navigatorPop(){
    Navigator.pop(context,{
      "screen": AnalysisScreen,
      "score": totalScore,
      "initialList": initialList,
      "gridLayout": gridLayout,
      "cancelled words": getRemovedWordsState(),
    });
  }

  List<bool> getRemovedWordsState(){
    //removes the booleans from each individual value notifier and puts them in a list.
    List<bool> outputList = [];
    for (int i=0;i<strikethroughStateNotifierList.length;i++){
      outputList.add(strikethroughStateNotifierList[i].value);
    }
    return outputList;
  }
  void checkCorrectWords(){
    wordScore = 0;
    penaltyScore = 0;
    wordScoreList = [];
    for (int i=0;i<initialList.length;i++){
      int score = ScoreCounter.countScore(initialList[i]);
      wordScoreList.add(score);
    }
  }
  void addScore(int score){
    if (score > 0 ){wordScore += score;}
    else{penaltyScore += score;}
  }
  void handleSubmit(){
    wordScore = 0;
    penaltyScore = 0;
    List<bool> removedWordsState = getRemovedWordsState();
    for (int i=0;i<removedWordsState.length;i++){
      if(!removedWordsState[i]){
        int score = ScoreCounter.countScore(initialList[i]);
        addScore(score);
      }
    }
    //triggers summit event
    submitCalledNotifier.value = [totalScore];
  }

  void handleOnTapped(index){
    strikethroughStateNotifierList[index].value = !strikethroughStateNotifierList[index].value;
  }

}
