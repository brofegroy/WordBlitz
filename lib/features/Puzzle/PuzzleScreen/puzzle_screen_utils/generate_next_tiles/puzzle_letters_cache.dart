
import 'package:wordblitz/tools/Database/database_helper.dart';
import 'package:wordblitz/tools/Database/game_stats_model.dart';
import 'package:wordblitz/tools/global.dart';

import 'func_calculate_lotto.dart';

class PuzzleCache {
  static LetterNode baseLetterNode = LetterNode("");
  static bool isPuzzleCacheLoaded = false;
  static bool wasLoadingHalfway = false; //becomes false again if no interrupts occurred

  //default is with no blank tiles, but can be set to true
  static bool isBlankTileEnabled = false;
  //default is 4 letter mode, but can be set to 3
  static bool isFourLetterMode = true;

  static Future<bool> load() async{
    //returns true if there there is a need to do first time initialisation.
    print("load called");
    if (wasLoadingHalfway){print("verify load called");return _verifyLoaded();}
    if (!isPuzzleCacheLoaded){
      wasLoadingHalfway = true;
      List<GameStats> gameStatsList= await DatabaseHelper.instance.readAllGameStats();
      if(gameStatsList.length == 0){return true;}
      for (GameStats gameStats in gameStatsList){
        baseLetterNode.createWord(gameStats.word,targetLottoTickets: calculateLotto(gameStats.embeddedInt));
      }
      wasLoadingHalfway = false;
      isPuzzleCacheLoaded = true;
    }
    if(isPuzzleCacheLoaded){Global.isPuzzleLoaded.complete(true);}
    return false;
  }

  static Future<bool> _verifyLoaded() async{
    //returns true if there there is a need to do first time initialisation.
    List<GameStats> gameStatsList= await DatabaseHelper.instance.readAllGameStats();
    if(gameStatsList.length == 0){
      wasLoadingHalfway = false;
      return true;
    }
    for (GameStats gameStats in gameStatsList){
      if (baseLetterNode[gameStats.word] == null){
        baseLetterNode.createWord(gameStats.word,targetLottoTickets: calculateLotto(gameStats.embeddedInt));
      }
    }
    wasLoadingHalfway = false;
    isPuzzleCacheLoaded = true;
    if(isPuzzleCacheLoaded){Global.isPuzzleLoaded.complete(true);}
    return false;
  }
}

class LetterNode {
  final String nodeWordSegment; //the word or word segment represented by this node.
  double currentLottoTickets; // cumulative value of all lottoTickets of words enabled in its descendants.
  double? wordLottoTickets; // has a value if it is a real word.
  bool isEnabled; ///note: [isEnabled] should only be true if [wordLottoTickets] != null.
  //isEnabled is true if we counted this word's Lotto tickets towards current tickets,unaffected by adding children's lotto tickets.
  Map<String, LetterNode> children;

  LetterNode(
    this.nodeWordSegment, {
      this.currentLottoTickets = 0,
      this.wordLottoTickets = null, //both legitimate and illegal words must have lotto tickets. words never played before should be null
      this.isEnabled = false, //keep this default at false.
  }) : children ={}; //if wordLottoTickets is null, then a descendant that is a word, must be initialised as its child later, otherwise there will be an error.

  LetterNode? operator [](String wordSegment) {
    if (!wordSegment.startsWith(nodeWordSegment)) {throw ("LetterNode [$nodeWordSegment]does not contain desired segment [$wordSegment]");}
    if (wordSegment.length > 6) {throw ("Error: attempted to access a 7>= letter word");}
    if (wordSegment.length == nodeWordSegment.length) {return this;}

    String nextChildWord = wordSegment.substring(0, nodeWordSegment.length + 1);
    return children[nextChildWord]?[wordSegment];
  }// this is somewhat slow, so avoid this if possible



  void conditionallyEnableThis(){
    if (wordLottoTickets!=null){isEnabled = true;}
  }

  //useCases: massive enables/disables, does not update value
  void enableAllDescendants() {
    children.forEach((key, child) {
      child.enableAllDescendants();
    });
    conditionallyEnableThis();
  }
  void disableAllDescendants() {
    if (currentLottoTickets != 0) {
      children.forEach((key, child) {
        child.disableAllDescendants();
      });
    }
    isEnabled = false;
  }
  void updateAllDescendants(){
    currentLottoTickets = 0;
    children.forEach((key, child) {
      child.updateAllDescendants();
      currentLottoTickets += child.currentLottoTickets;
    });
    if (wordLottoTickets != null && isEnabled) {
      currentLottoTickets += wordLottoTickets!;
    }
  }

  /// below this line, do not call any methods outside of the root/base node ,""
  void enableAllDescendantsUpToCertainDepth(int depth){
    ///depth should be set to desired word length. depth = 3 will conditionally enable all words <=3 long
    conditionallyEnableThis();
    if (depth <= 0){return;}
    for (var child in children.values) {
      child.enableAllDescendantsUpToCertainDepth(depth - 1);
    }
  }
  void disableAllDescendantsAfterCertainDepth(int depth){
    ///depth should be set to desired word length. depth = 3 will disable all words that is 4 or more long
    if (depth <= 0){
      disableAllDescendants();
      return;
    }
    for (var child in children.values) {
      child.disableAllDescendantsAfterCertainDepth(depth - 1);
    }
  }

  void _updateLottoInALinePath(String targetChildWord,double valueChange){
    //to be used only in the root node, updates all values a fixed amount (positive/negative) down the tree
    //to only be used when target node is confirmed to exist.
    LetterNode accessedWordNode = this;
    currentLottoTickets += valueChange;
    for (int i=1;i <targetChildWord.length; i++) {
      accessedWordNode = accessedWordNode.children[targetChildWord.substring(0, i)]!;
      accessedWordNode.currentLottoTickets += valueChange;
    }
  }
  void updateWordIsEnabledAttribute(String targetChildWord, bool updatedIsEnabledValue){
    //to be used only at the root node, does nothing if it does not get to update isEnabled
    if (nodeWordSegment != ""){throw("Error: precisionUpdateWord function should only be used in the root node");}
    if (this[targetChildWord]?.wordLottoTickets == null){throw("Error: attempted to update a bridge node or an uninitialised node");}
    LetterNode targetNode = this[targetChildWord]!;

    if(targetNode.isEnabled == updatedIsEnabledValue){return;} //refuse to do anything if it doesn't change isEnabledValue

    targetNode.isEnabled = updatedIsEnabledValue; //updates Is enabled value

    double targetWordLotto = targetNode.wordLottoTickets!; //applies the change down the tree
    _updateLottoInALinePath(targetChildWord, (updatedIsEnabledValue)?targetWordLotto:-targetWordLotto);
  }
  void precisionUpdateWordLotto(String targetChildWord, double updatedLottoValue){
    //to be used only at the root node
    if (nodeWordSegment != ""){throw("Error: dirtyUpdateWordScore function should only be used in the root node");}
    if (updatedLottoValue < 0){throw("Error: cannot set lotto value Less than 0");}
    if (this[targetChildWord]?.wordLottoTickets == null){throw("Error: attempted to update a bridge node or an uninitialised node");}
    LetterNode targetNode = this[targetChildWord]!;

    double changedLottoValue = updatedLottoValue - targetNode.wordLottoTickets!; //keeps track of changed value
    targetNode.wordLottoTickets = updatedLottoValue; //sets new value
    if(!targetNode.isEnabled){return;} //refuse to do anything if node isn't already enabled

    _updateLottoInALinePath(targetChildWord, changedLottoValue);//updates all down the tree because it was enabled
  }
  void removeWordFromTreeAndUpdate(String targetChildWord){
    if (nodeWordSegment != ""){throw("snip should only be called from root node \"\"");}
    if(this[targetChildWord] == null){throw("Cannot snip off node that does not exist");}
    if(this[targetChildWord]!.children == {}){
      _snipSoloChildWordOffTreeAndUpdate(targetChildWord);
    } else{
      if(this[targetChildWord]!.wordLottoTickets != null){_convertToBridgeNode(targetChildWord);}
    }
  }
  void _snipSoloChildWordOffTreeAndUpdate(String targetChildWord){//to be used only at the root node
    String targetParentWord = targetChildWord.substring(0,targetChildWord.length-1);
    LetterNode targetParentNode = this[targetParentWord]!;
    if((targetParentNode.children.length == 1)  && (targetParentNode != "")){ //if it is the only child, move up the tree and snip above.
      _snipSoloChildWordOffTreeAndUpdate(targetParentNode.nodeWordSegment);
    } else {
      //if it has other children,we found the parent node we need to snip the target node from.
      LetterNode targetNode = this[targetChildWord]!;
      targetNode.updateWordIsEnabledAttribute(targetChildWord, false); //updates the tickets originating from that node to 0, and disables it, and
      targetParentNode.children.remove(targetChildWord); //snips it off the tree.
    }
  }
  void _convertToBridgeNode(String targetChildWord){
    LetterNode targetChildNode = this[targetChildWord]!;
    updateWordIsEnabledAttribute(targetChildWord, false); //updates values first
    targetChildNode.wordLottoTickets = null; //converts to bridge node
  }

  String drawLotto(double drawnLotto){
    if (nodeWordSegment != ""){throw("Error: dirtyUpdateWordScore function should only be used in the root node");}
    if (drawnLotto >= 1){throw("Error: exceeding maximum range");}
    if (drawnLotto < 0){throw("Error: no lotto to draw, invalid call");}
    String result = _drawLotto(drawnLotto * this.currentLottoTickets);
    print("current lotto is${currentLottoTickets}, result is ${result}");
    if(result == ""){
      /*throw("Error: drawnLotto more than current tickets");*/
      print("an unforeseen error occurred in Puzzle mode lotto drawing, probably due to type <double> inaccuracy");
      result = _drawLotto((drawnLotto-0.5) * this.currentLottoTickets);
    }
    return result;
  }//to be used only at the root node
  String _drawLotto(double drawnLotto){
    double remainingLotto = drawnLotto;
    String? result;
    for (LetterNode child in children.values) {
      remainingLotto -= child.currentLottoTickets;
      if(remainingLotto <= 0){
        result = child._drawLotto(remainingLotto + child.currentLottoTickets);
        break;
      }
    }
    return result??nodeWordSegment;
  }//private helper function for drawLotto

  Set<String> getRelevantChildren(String tiles,{bool withBlankTile = false}){
    if(!tiles.contains("Q")){
      return (withBlankTile)?_getRelevantChildrenWithBlank(tiles).toSet():_getRelevantChildrenNoBlank(tiles).toSet();
    } else {
      return (withBlankTile)? _getRelevantChildrenWithBlankQU(tiles).toSet():_getRelevantChildrenNoBlankQU(tiles).toSet();
    }
  }
  List<String> _getRelevantChildrenNoBlank(String tiles,{int tilesUsed = 0}){
    List<String> relevantChildren = [];
    for (int i=0;i<tiles.length;i++){ //for all tiles
      String currentWordSegment = nodeWordSegment+tiles[i]; //form a extension of current word from the tile at the back
      if(children[currentWordSegment] != null){ //if there exists children there, there will be a initialised word somewhere down the line.
        relevantChildren += children[currentWordSegment]!._getRelevantChildrenNoBlank(tiles.replaceFirst(tiles[i],""), tilesUsed: tilesUsed + 1);
      }
    }
    if((tilesUsed > 2) && wordLottoTickets != null){relevantChildren.add(nodeWordSegment);}
    return relevantChildren;
  }
  List<String> _getRelevantChildrenWithBlank(String tiles,{int tilesUsed = 0}){
    List<String> relevantChildren = [];
    children.forEach((key, child) {
      String lastLetter = key[key.length-1];
      if(tiles.contains(lastLetter)){
        relevantChildren += child._getRelevantChildrenWithBlank(tiles.replaceFirst(lastLetter, ""),tilesUsed: tilesUsed+1);
      } else{
        relevantChildren += child._getRelevantChildrenNoBlank(tiles,tilesUsed: tilesUsed+1);
      }
    });
    if((tilesUsed > 2) && wordLottoTickets != null){relevantChildren.add(nodeWordSegment);}
    return relevantChildren;
  }
  List<String> _getRelevantChildrenNoBlankQU(String tiles,{int tilesUsed = 0}){
    List<String> relevantChildren = [];
    String notQUTiles = tiles.replaceFirst("Q", "");
    for (int i=0;i<notQUTiles.length;i++){ //for all tiles
      String currentWordSegment = nodeWordSegment+notQUTiles[i]; //form a extension of current word from the tile at the back
      if(children[currentWordSegment] != null){ //if there exists children there, there will be a initialised word somewhere down the line.
        relevantChildren += children[currentWordSegment]!._getRelevantChildrenNoBlankQU(notQUTiles.replaceFirst(notQUTiles[i],"")+"Q", tilesUsed: tilesUsed + 1);
      }
    }
    LetterNode? QChild = children[nodeWordSegment+"Q"];
    if (QChild != null){
      relevantChildren += QChild._getRelevantChildrenNoBlank(notQUTiles,tilesUsed: tilesUsed+1);
      LetterNode? QUChild = QChild.children[nodeWordSegment+"QU"];
      if(QUChild != null){
        relevantChildren += QUChild._getRelevantChildrenNoBlank(notQUTiles,tilesUsed: tilesUsed+1);
      }
    }
    if((tilesUsed > 2) && wordLottoTickets != null){relevantChildren.add(nodeWordSegment);}
    return relevantChildren;
  }
  List<String> _getRelevantChildrenWithBlankQU(String tiles,{int tilesUsed = 0}){
    List<String> relevantChildren = [];
    children.forEach((key, child) {
      String lastLetter = key[key.length-1];
      if(tiles.contains(lastLetter)){
        if(lastLetter == "Q"){
          relevantChildren += child._getRelevantChildrenWithBlank(tiles.replaceFirst("Q", ""),tilesUsed: tilesUsed+1);
          LetterNode? QUChild = child.children[nodeWordSegment + "QU"];
          if(QUChild != null){
            relevantChildren += QUChild._getRelevantChildrenWithBlank(tiles.replaceFirst("Q", ""),tilesUsed: tilesUsed+1);
          }
        } else {
          relevantChildren += child._getRelevantChildrenWithBlankQU(tiles.replaceFirst(lastLetter, ""),tilesUsed: tilesUsed+1);
        }
      } else{
        relevantChildren += child._getRelevantChildrenNoBlankQU(tiles,tilesUsed: tilesUsed+1);
      }
    });
    if((tilesUsed > 2) && wordLottoTickets != null){relevantChildren.add(nodeWordSegment);}
    return relevantChildren;
  }

  void createWord(String targetChildWord,{double targetLottoTickets = 1}) {
    // this function creates a word and enables it, works for bridge nodes and not yet initialised nodes, but does not accept already initialised nodes
    ///todo NOTE: this assumes default lotto value for [new words] is 1, which is true as of writing, and remember to update storage as well
    if (nodeWordSegment != "") {throw("Error: createWord function should only be used in the root node");}
    if (targetChildWord.length > 6) {throw ("Error: attempted to add a 7>= letter word");}
    if (this[targetChildWord]?.wordLottoTickets != null) {throw ("target word $targetChildWord already exists in node");}

    _createWord(targetChildWord, targetLottoTickets);
  }
  void _createWord(String targetChildWord,double targetLottoTickets){
    //to be used form main node only.
    LetterNode pointerWordNode = this; // starts at ""
    currentLottoTickets += targetLottoTickets;// add tickets to ""
    for (int i=1;i <=targetChildWord.length; i++) {
      String pointerWord = targetChildWord.substring(0, i); //points the pointer at next node
      LetterNode? childWordNode = pointerWordNode.children[pointerWord];
      if(childWordNode != null){ //if the next node already exists
        pointerWordNode = childWordNode;
        pointerWordNode.currentLottoTickets += targetLottoTickets; //add the lotto
      } else { //create bridge nodes until it reaches
        pointerWordNode.children[pointerWord] = LetterNode(pointerWord,currentLottoTickets: targetLottoTickets);
        pointerWordNode = pointerWordNode.children[pointerWord]!;
      }
    }
    pointerWordNode.wordLottoTickets = targetLottoTickets;
    pointerWordNode.isEnabled = true;
  }
}
