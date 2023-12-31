import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'dart:async';

// dependencies outside screen's folder
import '../AnalysisScreen/analysis_screen.dart';
import 'package:wordblitz/tools/staticNavigationData.dart';
import 'package:wordblitz/tools/dict_and_dice.dart';

// dependencies within screen's folder
import 'blitz_screen_utils/prevent_reload.dart';
import 'blitz_screen.dart';
import 'blitz_screen_model.dart';
import 'blitz_screen_utils//drag_position.dart';
//

typedef BoolMatrix = List<List<bool>>;

class BlitzScreenController{
  //variables
  late final BlitzScreenModel _model;
  final BuildContext context;
  late final List<String> gridLayout;
  bool _isCurrentlySwiping = false;
  int _afterglowState = 0;
  final Size screenSize;
  late final double screenWidth;
  late final double gridSize;
  Timer? _timer;
  final ValueNotifier<double> gameTimerNotifier = ValueNotifier<double>(180);
  late final ValueNotifier<List<String>> recentWordsNotifier = ValueNotifier<List<String>>([]);
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
    required double initialGameTime,
    List<String>? initialWordList,
    List<String>? initialGridLayout,
  }){
    Random random = Random();
    gridLayout = initialGridLayout??List.generate(16, (index) =>
    Dice.txt
    [List<int>.unmodifiable(List.generate(16, (index) => index)..shuffle())[index]]
    [List<int>.unmodifiable(List.generate(16, (_) => random.nextInt(6)))[index]]);
    screenWidth = screenSize.width;
    gridSize = screenWidth * 0.8;//[Hardcoded]
    gameTimerNotifier.value = initialGameTime;

    _model = BlitzScreenModel(gridLayout);
    _model.resetGrid = resetHighlightGrid;
    _model.updateGrid = updateHighlightGrid;
    _model.updateDisplayScore = updateScore;
    _model.updateUIWordList = updateRecentWords;
    _model.initialiseWords(initialWordList??[]);
    getRecentSubmittedWords();
    updateScore();

    startBlitzTimer();
  }
  //
  //methods
  void onPanStart(DragStartDetails details) {
    _isCurrentlySwiping = true;
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
    _isCurrentlySwiping = false;
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
    _afterglowState++;
    await Future.delayed(const Duration(seconds: 2));
    if (_afterglowState == 1 && _isCurrentlySwiping==false){resetHighlightGrid();}
    if (_afterglowState >=1){_afterglowState--;}
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (gameTimerNotifier.value < 0){
        _timer?.cancel();
        if (PreventReload.shouldNotReNavigate){return;}
        navigateToAnalysis();
      } else {
        gameTimerNotifier.value -= 1;
      }
    });
  }
  void navigateToAnalysis() async{
    PreventReload.shouldNotReNavigate = true;
    _timer?.cancel();
    staticNavData.data = {
      "screen": BlitzScreen,
      "list":_model.submittedList,
      "time":gameTimerNotifier.value,
      "gridLayout":gridLayout,
    };
    Navigator.pop(context,
      await Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => AnalysisScreen(
              initialList: staticNavData.data["list"],
              gridLayout: staticNavData.data["gridLayout"],
            )
        )
      )
    );
    PreventReload.shouldNotReNavigate = false;
  }
  void navigatorPop(){
    _timer?.cancel();
    PreventReload.shouldNotReNavigate = false;
    Navigator.pop(context,{
      "screen": BlitzScreen,
      "list":_model.submittedList,
      "time":gameTimerNotifier.value,
      "gridLayout":gridLayout,
    });
  }
  void handleOnWillPop(){
    print("gameTimerNotifier.value is ${gameTimerNotifier.value}");
    print("needs to implement double click back button to confirm exit/ or a backbutton");//TODO
    navigatorPop();
  }
  //
}
