import 'package:flutter/material.dart';

import 'puzzle_screen_controller.dart';

class PuzzleScreen extends StatelessWidget {
  const PuzzleScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = Size(
        (MediaQuery.of(context).size.aspectRatio > 5 / 8)
            ? MediaQuery.of(context).size.height * 5 / 8
            : MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height);

    final controller = PuzzleScreenController(
        context: context,
        screenSize: screenSize
    );

    return WillPopScope(
        onWillPop: () async {
          controller.handleOnWillPop();
          return true;
        },
        child: SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                Image.asset(
                  // this is where the background goes
                  "resources/images/backgrounds/not_zen.jpg",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                _PuzzleScreenMainColumWidget(
                  controller: controller,
                  screenSize: screenSize,
                ),
              ],
            ),
          ),
        ));
  }
}

class _PuzzleScreenMainColumWidget extends StatelessWidget {
  final PuzzleScreenController controller;
  final Size screenSize;

  const _PuzzleScreenMainColumWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PuzzleScreenAppBarWidget(
            controller: controller, screenSize: screenSize),
        Expanded(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //
              // Main Column
              //
              SizedBox(
                height: screenSize.width * 1 / 50,
              ),
              _PuzzleScreenPuzzleRowWidget(
                controller: controller,
                screenSize: screenSize,
              ),

              Divider(
                thickness: 2,
                color: Colors.black,
                indent: screenSize.width / 15,
                endIndent: screenSize.width / 15,
              ),

              _PuzzleScreenBelowDividerWidget(
                  controller: controller, screenSize: screenSize)
              //
              // Main Column
              //
            ],
          ),
        ))
      ],
    );
  }
}

class _PuzzleScreenBelowDividerWidget extends StatelessWidget {
  final PuzzleScreenController controller;
  final Size screenSize;
  const _PuzzleScreenBelowDividerWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.width * 0.7,
      width: screenSize.width * 3 / 4,
      child: ValueListenableBuilder(
          valueListenable: controller.isBlankTileModeEnabledNotifier,
          builder: (context, isBlankTileModeEnabled, _) {
            return Column(
              children: [
                if (isBlankTileModeEnabled)
                  _PuzzleScreenBlankTilesWidget(
                    controller: controller,
                    screenSize: screenSize,
                  ),
                if (isBlankTileModeEnabled)
                  SizedBox(
                    height: screenSize.width / 30,
                  ),
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(screenSize.width * 1 / 30),
                    child: Container(
                        child: _PuzzleScreenDismissibleSubWidget(
                            controller: controller, screenSize: screenSize)),
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class _PuzzleScreenBlankTilesWidget extends StatelessWidget {
  final PuzzleScreenController controller;
  final Size screenSize;
  const _PuzzleScreenBlankTilesWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller.currentBlankTileLetterNotifier,
        builder: (context, blankTile, _) {
          return Container(
            height: screenSize.width / 6,
            width: screenSize.width * 3 / 4,
            color: Colors.green,
            child: Text(
              "Blank Tiles \n${blankTile}\n${screenSize.height},${screenSize.width}",
              style: TextStyle(fontSize: screenSize.width / 25),
            ),
          );
        });
  }
}

class _PuzzleScreenDismissibleSubWidget extends StatelessWidget {
  final PuzzleScreenController controller;
  final Size screenSize;
  const _PuzzleScreenDismissibleSubWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller.isResultsVisible,
        builder: (context, isResultsVisible, _) {
          return ValueListenableBuilder(
              valueListenable: controller.wordListLengthNotifier,
              builder: (context, length, _) {
                List<String> wordList = controller.wordList;
                return ListView.builder(
                    itemCount: length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                          key: Key(wordList[index]),
                          onDismissed: (direction) =>
                              controller.handleRemoveWord(index),
                          direction: isResultsVisible
                              ? DismissDirection.none
                              : DismissDirection.horizontal,
                          child: Container(
                            padding: EdgeInsets.all(screenSize.width / 100),
                            color: isResultsVisible
                                ? controller.wordColorList[index]
                                : Colors.cyan,
                            height: screenSize.width / 12,
                            child: Text(
                              "${length - index}: ${wordList[index]}",
                              style: TextStyle(fontSize: screenSize.width / 20),
                            ),
                          ));
                    });
              });
        });
  }
}

class _PuzzleScreenPuzzleRowWidget extends StatelessWidget {
  final PuzzleScreenController controller;
  final Size screenSize;
  const _PuzzleScreenPuzzleRowWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            _PuzzleScreenPuzzleRowButtonWidget(
              onTap: controller.handleShufflePressed,
              screenSize: screenSize,
              text: "Shuffle",
              iconData: Icons.shuffle_rounded,
            ),
            SizedBox(height: screenSize.width*0.05),
            ValueListenableBuilder(
              valueListenable: controller.isResultsVisible,
              builder: (context,isResultsVisible,_) {
                return _PuzzleScreenPuzzleRowButtonWidget(
                  onTap: (!isResultsVisible && controller.hasBoardBeenAttemptedOnce==null)?controller.handleReloadFirstAttempt:controller.handleRetry,
                  screenSize: screenSize,
                  text: (!isResultsVisible && controller.hasBoardBeenAttemptedOnce==null)?"Load First":"Retry",
                  iconData: Icons.cached_rounded,
                );
              }
            ),
          ],
        ),
        SizedBox(
          width: screenSize.width * 1 / 60,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(screenSize.width * 1 / 30),
          child: Container(
            height: screenSize.width * (1 / 2 + 1 / 10),
            width: screenSize.width * 1 / 2,
            color: Colors.brown,
            child: Column(
              children: [
                _PuzzleScreenPuzzleRowMainGridWidget(
                    controller: controller, screenSize: screenSize),
                _PuzzleScreenPuzzleRowCurrentWordWidget(
                  controller: controller,
                  screenSize: screenSize,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: screenSize.width * 1 / 60,
        ),
        ValueListenableBuilder(
            valueListenable: controller.isResultsVisible,
            builder: (context, isResultsVisible, _) {
              return (isResultsVisible && !controller.shouldAllowChangeAnswerConfig && controller.hasBoardBeenAttemptedOnce==true)
                  ? _PuzzleScreenPuzzleRowButtonWidget(
                      onTap: controller.handleSaveDataAndLoadNext,
                      screenSize: screenSize,
                      text: "Save&Next",
                      iconData: Icons.label_rounded,
                    )
                  : ValueListenableBuilder(
                      valueListenable: controller.isConfirmButtonEnabled,
                      builder: (context, isConfirmButtonEnabled, _) {
                        return _PuzzleScreenPuzzleRowButtonWidget(
                          onTap: (isResultsVisible)
                              ? controller.handleReloadFirstAttempt
                              :(isConfirmButtonEnabled)?controller.handleConfirmPressed:(){},
                          screenSize: screenSize,
                          text: (isResultsVisible)?"Load First":"Confirm",
                          iconData: (isConfirmButtonEnabled)?Icons.fact_check_rounded:Icons.fact_check_outlined,
                        );
                      });
            }),
      ],
    );
  }
}

class _PuzzleScreenPuzzleRowMainGridWidget extends StatelessWidget {
  final PuzzleScreenController controller;
  final Size screenSize;
  const _PuzzleScreenPuzzleRowMainGridWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    double gridSize = screenSize.width * GRID_SCRWIDTH_PCT;
    return GestureDetector(
      onPanStart: controller.handleOnPannedStart,
      onPanUpdate: controller.handleGridOnPanned,
      onPanEnd: controller.handleOnPannedEnd,
/*      onTapUp: controller.handleOnTapped,*/
      child: Container(
        height: gridSize,
        width: gridSize,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PuzzleScreenPuzzleRowLetterButtonWidget(
                    letterIndex: 0, controller: controller, gridSize: gridSize),
                _PuzzleScreenPuzzleRowLetterButtonWidget(
                    letterIndex: 1, controller: controller, gridSize: gridSize),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PuzzleScreenPuzzleRowLetterButtonWidget(
                    letterIndex: 2, controller: controller, gridSize: gridSize),
                _PuzzleScreenPuzzleRowLetterButtonWidget(
                    letterIndex: 3, controller: controller, gridSize: gridSize),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PuzzleScreenPuzzleRowLetterButtonWidget extends StatelessWidget {
  final PuzzleScreenController controller;
  final double gridSize;
  final int letterIndex;
  const _PuzzleScreenPuzzleRowLetterButtonWidget({
    required this.controller,
    required this.gridSize,
    required this.letterIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller.isTileSelectedNotifier[letterIndex],
        builder: (context, isTileSelected, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(gridSize / 15),
            child: Container(
              height: gridSize * 8 / 20 + 4,
              width: gridSize * 8 / 20 + 4,
              padding: EdgeInsets.all(2),
              color: (isTileSelected) ? Colors.yellow : null,
              child: ValueListenableBuilder(
                  valueListenable: controller.boardLayoutNotifier[letterIndex],
                  builder: (context, letter, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(gridSize / 15),
                      child: Container(
                          height: gridSize * 8 / 20,
                          width: gridSize * 8 / 20,
                          color: Colors.blue,
                          child: Center(
                              child: Text(
                                (letter == "Q")?"Qu": "${letter}",
                                style: TextStyle(fontSize: gridSize / 4),
                          ))),
                    );
                  }),
            ),
          );
        });
  }
}

class _PuzzleScreenPuzzleRowCurrentWordWidget extends StatelessWidget {
  final PuzzleScreenController controller;
  final Size screenSize;
  const _PuzzleScreenPuzzleRowCurrentWordWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final Function onClear = controller.handleClearCurrentWord;
    final Function onBacktrack = controller.handleRemoveOneLetter;
    final ValueNotifier<String> currentWordListenable =
        controller.currentSelectedLettersNotifier;
    return Container(
      height: screenSize.width * 1 / 10,
      width: screenSize.width * 1 / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: screenSize.width * 1 / 10,
            color: Colors.teal,
            child: Center(
              child: IconButton(
                onPressed: () => onBacktrack(),
                icon: Icon(Icons.first_page_rounded),
                iconSize: screenSize.width * 1 / 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.handleAddWord(),
            child: ValueListenableBuilder(
                valueListenable: currentWordListenable,
                builder: (context, currentWord, _) {
                  return Container(
                      height: screenSize.width * 1 / 10,
                      width: screenSize.width * (1 / 2 - 1 / 5),
                      color: Colors.purple,
                      child: Center(
                          child: Text("$currentWord",
                              style:
                                  TextStyle(fontSize: screenSize.width / 25))));
                }),
          ),
          Container(
            width: screenSize.width * 1 / 10,
            color: Colors.red,
            child: Center(
              child: IconButton(
                onPressed: () => onClear(),
                icon: Icon(Icons.delete),
                iconSize: screenSize.width * 1 / 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PuzzleScreenPuzzleRowButtonWidget extends StatelessWidget {
  final Function onTap;
  final Size screenSize;
  final String text;
  final IconData iconData;
  const _PuzzleScreenPuzzleRowButtonWidget({
    required this.onTap,
    required this.screenSize,
    required this.text,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(screenSize.width * 1 / 50),
      child: GestureDetector(
        onTap: () => onTap(),
        child: Container(
          height: screenSize.width * 1.75 / 10,
          width: screenSize.width * 3.25 / 15,
          color: Colors.purple,
          child: Center(
            child: Column(
              children: [
                Icon(
                  iconData,
                  size: screenSize.width * 1 / 10,
                ),
                Text(
                  "$text",
                  style: TextStyle(fontSize: screenSize.width / 25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PuzzleScreenAppBarWidget extends StatelessWidget {
  final PuzzleScreenController controller;
  final Size screenSize;
  const _PuzzleScreenAppBarWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.width / 8,
      width: screenSize.width,
      color: Colors.grey,
      padding: EdgeInsets.symmetric(horizontal: screenSize.width / 120),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenSize.width / 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PuzzleScreenAppBarButtonWidget(
              onPressed: controller.handleOnWillPop,
              screenSize: screenSize,
              color: Colors.purple,
              text: "Back",
              iconData: Icons.arrow_back_rounded,
            ),
            _PuzzleScreenAppBarScoreCardWidget(
              valueListenable: controller.displayWrongCountNotifier,
              screenSize: screenSize,
              color: Colors.red,
              icon: Icons.cancel,
            ),
            Container(
              height: screenSize.width / 10,
              width: screenSize.width / 3,
              color: Colors.purple,
              child: Text(
                "Filters",
                style: TextStyle(fontSize: screenSize.width / 25),
              ),
            ),
            _PuzzleScreenAppBarScoreCardWidget(
              valueListenable: controller.displayCorrectCountNotifier,
              screenSize: screenSize,
              color: Colors.green,
              icon: Icons.check_circle,
            ),
            _PuzzleScreenAppBarButtonWidget(
              onPressed: controller.handleSkipPressed,
              screenSize: screenSize,
              color: Colors.purple,
              text: "Skip",
              iconData: Icons.fast_forward,
            ),
          ],
        ),
      ),
    );
  }
}

class _PuzzleScreenAppBarScoreCardWidget extends StatelessWidget {
  final ValueNotifier valueListenable;
  final Size screenSize;
  final Color color;
  final IconData icon; //Temporary edit, TODO
  const _PuzzleScreenAppBarScoreCardWidget({
    required this.valueListenable,
    required this.screenSize,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: valueListenable,
        builder: (context, scoreCount, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(screenSize.width / 100),
            child: Container(
              height: screenSize.width / 10,
              width: screenSize.width / 9,
              color: color,
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: screenSize.width / 20,
                  ),
                  Text(
                    "$scoreCount",
                    style: TextStyle(fontSize: screenSize.width / 25),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class _PuzzleScreenAppBarButtonWidget extends StatelessWidget {
  final Function onPressed;
  final Size screenSize;
  final Color color;
  final String text;
  final IconData iconData; //Temporary edit, TODO
  const _PuzzleScreenAppBarButtonWidget({
    required this.onPressed,
    required this.screenSize,
    required this.color,
    required this.text,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenSize.width / 100),
        child: Container(
          height: screenSize.width / 10,
          width: screenSize.width / 6,
          color: Colors.purple,
          child: Column(
            children: [
              Icon(
                iconData,
                size: screenSize.width / 20,
              ),
              Text(
                "$text",
                style: TextStyle(fontSize: screenSize.width / 25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
