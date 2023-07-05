import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:wordblitz/screens/AnalysisScreen/analysis_screen.dart';
import 'package:wordblitz/screens/BlitzScreen/blitz_screen.dart';
import 'package:wordblitz/tools/config.dart';

//import dependencies
import 'package:wordblitz/tools/dict_and_dice.dart';
import 'blitz_screen_model.dart';
import 'BlitzScreenUtils/drag_position.dart';
//

typedef BoolMatrix = List<List<bool>>;

class BlitzScreenController{
  //variables
  late final BlitzScreenModel _model;
  final BuildContext context;
  late final List<String> gridLayout;
  bool isCurrentlySwiping = false;
  int afterglowState = 0;
  final Size screenSize;
  late final double screenWidth;
  late final double gridSize;
  late final ValueNotifier<List<String>> recentWordsNotifier = ValueNotifier<List<String>>([]);
  final ValueNotifier<int> gameTimerNotifier = ValueNotifier<int>(180);
  final ValueNotifier<int> currentScoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<BoolMatrix> isHighlightedNotifier = ValueNotifier<BoolMatrix>(BoolMatrix.unmodifiable([
    [false, false, false, false],
    [false, false, false, false],
    [false, false, false, false],
    [false, false, false, false],
  ]));
  //
  //getters,setters
  get isHighlighted => isHighlightedNotifier.value;
  set isHighlighted(value) => isHighlightedNotifier.value = value;
  get currentScore => currentScoreNotifier.value;
  set currentScore(value) => currentScoreNotifier.value = value;
  //
  //constructor
  BlitzScreenController({
    required this.context,
    required this.screenSize,
    List<String>? initialWordList,
    int? initialScore,
  }){
    Random random = Random();
    final List<int> dicePositionShuffleState = List<int>.unmodifiable(List.generate(16, (index) => index)..shuffle());
    final List<int> diceOrientationShuffleState = List<int>.unmodifiable(List.generate(16, (_) => random.nextInt(6)));
    gridLayout = List.generate(16, (index) => Dice.txt[dicePositionShuffleState[index]][diceOrientationShuffleState[index]]);
    screenWidth = screenSize.width;
    gridSize = screenWidth * 0.8;//[Hardcoded]

    _model = BlitzScreenModel(gridLayout);
    _model.resetGrid = resetHighlightGrid;
    _model.updateGrid = updateHighlightGrid;
    _model.updateDisplayScore = updateScore;
    _model.updateUIWordList = updateRecentWords;

    startBlitzTimer();
  }
  //
  //methods
  void onPanStart(DragStartDetails details) {
    isCurrentlySwiping = true;
    resetHighlightGrid();
  }
  void onPanUpdate(DragUpdateDetails details){
    Tuple2<int,int>? rowColIndex = DragPosition.getRowCol(details.localPosition,gridSize);
    if (rowColIndex != null){
      int row = rowColIndex.item1;
      int col = rowColIndex.item2;
      _model.handleClickedCell(row, col);
    }
  }
  void onPanEnd(DragEndDetails details){
    isCurrentlySwiping = false;
    triggerAfterglow();
    _model.handleSubmit();
  }
  void updateHighlightGrid(int row,int col,bool state){
    isHighlighted[row][col] = state;
    // if notifyListeners() ever break, then just make a (new) full 4x4list and assign it.
    // line below is to suppress linter
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    isHighlightedNotifier.notifyListeners();
  }
  void resetHighlightGrid(){
    isHighlighted = List.generate(4, (_) => List<bool>.filled(4, false));
  }
  Future<void> triggerAfterglow() async{
    afterglowState++;
    await Future.delayed(const Duration(seconds: 2));
    if (afterglowState == 1 && isCurrentlySwiping==false){resetHighlightGrid();}
    if (afterglowState >=1){afterglowState--;}
    return;
  }
  List<String> handleOnDismissed(int dismissedIndex){
    int index = _model.submittedList.length -1 - dismissedIndex ;
    _model.removeWord(index);
    updateScore();
    return getRecentSubmittedWords();
  }
  List<String> getRecentSubmittedWords(){
    int listLengthToRetrieve = min(_model.submittedList.length, 3);
    int startIndex = _model.submittedList.length - listLengthToRetrieve;
    recentWordsNotifier.value = _model.submittedList.sublist(startIndex).reversed.toList();
    return recentWordsNotifier.value;
  }
  void updateRecentWords(){
    recentWordsNotifier.value = getRecentSubmittedWords();
  }
  void updateScore(){
    currentScore = _model.currentWordScore;
  }
  void startBlitzTimer() async{
    while (gameTimerNotifier.value > 0){
      await Future.delayed(const Duration(seconds: 1));
      gameTimerNotifier.value -= 1;
    }
    navigateToAnalysis();
  }
  void navigateToAnalysis() async{
    Navigator.pop(context,
      await Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => const AnalysisScreen()
        )
      )
    );
  }
  void navigatorPop(){
    Navigator.pop(context,{
      "screen": BlitzScreen,
      "list":_model.submittedList,
      "time":gameTimerNotifier.value}
    );
  }
  Future<bool> handleOnWillPop()async{
    print("gameTimerNotifier.value is ${gameTimerNotifier.value}");
    return false;
  }
  //
}