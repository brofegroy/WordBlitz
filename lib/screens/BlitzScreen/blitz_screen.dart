import 'package:flutter/material.dart';

//import screens
import 'blitz_screen_controller.dart';
//

class BlitzScreen extends StatelessWidget {
  final int initialGameTime;
  final List<String> initialWordList;

  const BlitzScreen({
    Key? key,
    this.initialGameTime = 180,
    this.initialWordList = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //constants
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeightRemaining =
        MediaQuery.of(context).size.height - screenWidth * 0.8;
    final double gridSize = screenWidth * 8 / 10; //[Hardcoded]
    final controller = BlitzScreenController(
        context: context,
        screenSize: MediaQuery.of(context).size,
        initialWordList: initialWordList,
    );
    controller.gameTimerNotifier.value = initialGameTime;
    //

    return WillPopScope(
      onWillPop: ()async{
        return await controller.handleOnWillPop();
        },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Image.network(
                // this is where the background goes
                "https://lh3.googleusercontent.com/proxy/cOkDFcHT6HDMa3rmBke28G5Ba_52bB9g-haUych5KN-9cZ4rDSMAF_SUArc2dtKbtmKYzVqf8KeTb8NL8uGPmozQhEpG8ndkQ4sSQTXC1XlRDlXEYtuzIx4WJ-zbJpBMcld84TOucNFK",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Center(
                child: Container(
                  color: Colors.red.withOpacity(0.25), //TODO make trans
                  padding: EdgeInsets.all(screenWidth / 10),
                  child: Column(
                      //
                      //
                      // --main screen column--
                      //
                      //
                      children: [
                        Row(
                          children: [
                            ScoreCardWidget(controller: controller),
                            SizedBox(
                              width: 50,
                            ),
                            GameTimeWidget(controller: controller),
                          ],
                        ),
                        BlitzGrid(
                          controller: controller,
                          gridSize: gridSize,
                        ),
                        const Divider(),
                        RecentWordsWidget(
                          controller: controller,
                          height: screenHeightRemaining * 0.45,
                          width: screenWidth * 0.6,
                        ),
                        //
                        //
                        // --main screen column--
                        //
                        //
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentWordsWidget extends StatelessWidget {
  final BlitzScreenController controller;
  final double height;
  final double width;
  final int numberOfWordsShown = 3;

  const RecentWordsWidget({
    Key? key,
    required this.controller,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(height / 15),
      ),
      child: Container(
          height: height,
          width: width,
          color: Colors.lightGreen.withOpacity(0.5),
          child: DismissibleWordsSubwidget(
            controller: controller,
            height: height / numberOfWordsShown,
          )
      ),
    );
  }
}

class DismissibleWordsSubwidget extends StatelessWidget {
  final BlitzScreenController controller;
  final double height;

  DismissibleWordsSubwidget({
    Key? key,
    required this.controller,
    required this.height
  }):super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller.recentWordsNotifier,
        builder: (context, recentWords, _) {
          return ListView.builder(
            itemCount: recentWords.length,
            itemBuilder: (BuildContext context,int index){
              return Dismissible(
                key: Key(recentWords[index]),
                onDismissed: (direction)=>controller.handleOnDismissed(index),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.cyan.withOpacity(0.5),
                  height: height,
                  child: Text(recentWords[index]),
                ),
              );
            }
          );
        }
    );
  }
}

class GameTimeWidget extends StatelessWidget {
  final BlitzScreenController controller;
  const GameTimeWidget({Key? key, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller.gameTimerNotifier,
        builder: (context, gameTimer, _) {
          return Text("Time left $gameTimer seconds");
        });
  }
}

class ScoreCardWidget extends StatelessWidget {
  final BlitzScreenController controller;
  const ScoreCardWidget({Key? key, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.currentScoreNotifier,
      builder: (context, currentScore, _) {
        print("score rebuilt");
        return Text("score: $currentScore");
      },
    );
  }
}

class BlitzGrid extends StatelessWidget {
  final BlitzScreenController controller;
  final double gridSize;
  // Constructor
  const BlitzGrid({Key? key, required this.controller, this.gridSize = 250})
      : super(key: key);
  //
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: controller.onPanStart,
      onPanUpdate: controller.onPanUpdate,
      onPanEnd: controller.onPanEnd,
      child: SizedBox(
        width: gridSize,
        height: gridSize,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(gridSize / 15)),
            child: Container(
              color: Colors.green.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (colNum) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (rowNum) {
                      return Center(
                        child: ValueListenableBuilder<List<List<bool>>>(
                            valueListenable: controller.isHighlightedNotifier,
                            builder: (context, value, _) {
                              return Container(
                                padding: const EdgeInsets.all(0),
                                height: gridSize / 5,
                                width: gridSize / 5,
                                color: controller.isHighlighted[rowNum][colNum]
                                    ? Colors.yellow
                                    : null,
                                child: Image.asset(
                                  "resources/images/tile_images/${controller.gridLayout[rowNum * 4 + colNum].toLowerCase()}_tile.png",
                                  fit: BoxFit.contain,
                                ),
                                /*Container(
                                color: Colors.blue,
                                child: Text("R$rowNum, C$colNum"),
                              ),*/
                              );
                            }),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}