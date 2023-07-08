# BlitzScreen
**This Screen will construct its own controller and model instance upon initialisation**

## Overview
This is the screen where the user will be able to swipe to practice boggle on a board
It will generate a fresh board if constructed without any arguments.

It has a timer running the moment this screen loads up, and when it reaches 0 or is initially less than 0,
it will remove this current screen from the stack,then push the an instance of AnalysisScreen.
It returns a Future of the return value of AnalysisScreen.

If this screen was exited prematurely, before the timer reaches 0,
and if it uses the navigatorPop() method within the controller,
it will return the current states of the board.

## Inputs
1. final int? initialGameTime;
sets initial game time for board, will default to 180 if null
2. final List<String>? initialWordList;
sets the initial word submitted list, will default to an empty list if null
3. final List<String>? initialGridLayout;
sets the initial GridLayout, will generate a random board if null

## Outputs
1. void navigatorPop(){
   Navigator.pop(context,{
   "screen": BlitzScreen,
   "list":_model.submittedList,
   "time":gameTimerNotifier.value,
   "gridLayout":gridLayout,
   });
   }
if popped before timer ends, and uses the navigatorPop() method within the controller instance,
it will return a dictionary with 3 parameters:
"screen" references the class which constructed this screen. this is so whatever function that is awaiting this return value can distinguish the return value from the next screen.
"list" refers to the list of words which the user submitted before this screen popped.
"time" refers to the remaining time which the user has before this screen popped.
"gridLayout" refers to the tile shuffle state of the board that was popped.

2. void navigateToAnalysis() async{
   Navigator.pop(context,
   await Navigator.push(context,
   MaterialPageRoute(
   builder: (context) => const AnalysisScreen()
   )));}
if timer ends, it pops using navigateToAnalysis() and with the second argument in pop,
it returns a Future of whatever AnalysisScreen() returns.
note that transmitting data through multiple screens seem to have some issues,so im going to use a separate tool class, staticNavData, to transmit info.

## Dependencies
-external libraries dependencies
import 'dart:math';
import 'dart:ui';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';

-project dependencies
import 'package:wordblitz/screens/AnalysisScreen/analysis_screen.dart';
import 'package:wordblitz/tools/score_counter.dart';
import 'package:wordblitz/tools/config.dart';
import 'package:wordblitz/tools/dict_and_dice.dart';

## Bugs
- currently assumes maximum of 1 dice with Qu exists on the board at any give time
- currently does not show the Qu tile properly