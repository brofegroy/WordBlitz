# Analysis Screen
**This Screen will construct its own controller instance upon initialisation**

## Overview
This is where the user will be able to add or remove words that they select into the list.
Theres not much to say here.
it takes 2 variables, initial list and gridlayout,
and tries to determine what words the user wants to submit, then marks them for it.
user can exit the screen with back button, and it should output the data to NavScreenData class in tools.


## inputs
final List<String>? initialList;
final List<String>? gridLayout;
const AnalysisScreen({
Key? key,
required this.initialList,
required this.gridLayout,
}) : super(key: key);
initial list contains the words that the user has managed to form in the previous screen, blitzscreen.
gridLayout is the layout of the board the user had previously formed the words from.
it will exit immediately if it detects that the initial list contains illegal character such as ")" or lower case letters,
which is not formable in the previous screen. also does an additional check for 16 length of gridlayout, and all caps.
if it detects anomalies, then it will immediately exit out.
**invalid inputs is an edge case and should not be possible with legal user inputs to begin with** 


## outputs
void navigatorPop(){
Navigator.pop(context,{
"screen": AnalysisScreen,
"submittedStatus": hasUserTriggeredSubmit,
"score": totalScore,
"initialList": initialList,
"gridLayout": gridLayout,
"cancelledWords": getRemovedWordsState(),
});
}
screen refers to the class which this screen has been popped from
submitted status allows us to recognise when if the game has been successfully completed
ngl score kinda redundant rn am thinking of recalculating
"initiallist" shows all words submitted in a list,
and using "cancelled words", we can figure out what words the user **actually** submitted
gridLayout may come in useful in the future if we want to show the user what board that game was played on.

## dependencies
-external libraries dependencies
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

-project dependencies
import 'package:wordblitz/tools/score_counter.dart';


## bugs
- bug(?) when clicked with the mouse4 button it produces a negligible thin green border around entire screen