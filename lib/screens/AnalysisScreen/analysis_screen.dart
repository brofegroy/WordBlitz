import 'package:flutter/material.dart';

//import screens
import 'package:wordblitz/screens/AnalysisScreen/analysis_screen_controller.dart';
//

class AnalysisScreen extends StatelessWidget {
  final List<String>? initialList;
  final List<String>? gridLayout;

  const AnalysisScreen({
    Key? key,
    required this.initialList,
    required this.gridLayout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final controller = AnalysisScreenController(
        context: context,
        initialList: initialList ?? [],
        gridLayout: gridLayout);

    return WillPopScope(
        onWillPop: () async {
          return controller.handleOnWillPop();
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
                _AnalysisScreenMainColumnWidget(
                    controller: controller, screenSize: screenSize),
              ],
            ),
          ),
        ));
  }
}

class _AnalysisScreenMainColumnWidget extends StatelessWidget {
  final AnalysisScreenController controller;
  final Size screenSize;
  const _AnalysisScreenMainColumnWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final boldTextStyle = TextStyle(fontWeight: FontWeight.bold,fontSize: screenSize.width*0.05);
    return Column(
      children: [
        Container(
          width: screenSize.width,
          color: Colors.pink.withOpacity(0.5),
          height: screenSize.height/6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: (){controller.handleSubmit();},
                  child:const Row(
                    children: [
                      Text("Submit Words!"),
                      Icon(Icons.control_point_sharp)
                    ],
                  )
              ),
              Container(
                color: Colors.white.withOpacity(0),//TODO remove this
                child: ValueListenableBuilder(
                  valueListenable: controller.submitCalledNotifier,
                  builder: (context,totalScoreDummyParam,_){
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Word score:${controller.wordScore}",style: boldTextStyle,),
                        Text("Penalty Score:${controller.penaltyScore}",style: boldTextStyle,),
                        Text("Total Score:${controller.totalScore}",style: boldTextStyle,),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                width: screenSize.width,
                color: Colors.grey.withOpacity(0.25), //TODO make transparent
                child: Column(
                  children: [
                    _WordGroupTilesListWidget(
                      controller: controller,
                      screenSize: screenSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WordGroupTilesListWidget extends StatelessWidget {
  final AnalysisScreenController controller;
  final Size screenSize;
  const _WordGroupTilesListWidget({
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: (controller.initialList.length / 10).ceil(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _WordGroupTileWidget(
              controller: controller,
              screenSize: screenSize,
              wordGroupTileIndex: (index * 2).floor(),
            ),
            _WordGroupTileWidget(
              controller: controller,
              screenSize: screenSize,
              wordGroupTileIndex: (index * 2 + 1).floor(),
            ),
          ],
        );
      },
    );
  }
}

class _WordGroupTileWidget extends StatelessWidget {
  final AnalysisScreenController controller;
  final Size screenSize;
  final int wordGroupTileIndex;
  const _WordGroupTileWidget({
    required this.controller,
    required this.screenSize,
    required this.wordGroupTileIndex,
  });

  @override
  Widget build(BuildContext context) {
    double groupTileBorderThickness = 2;

    ///[Hardcoded] but could implement config to change these values
    double groupTileWidthWithoutBorder = (screenSize.width * 0.4);
    double groupTileHeightWithoutBorder = (screenSize.height * 0.25);
    double groupTileWidth =
        groupTileWidthWithoutBorder + groupTileBorderThickness * 2;
    double groupTileHeight =
        groupTileHeightWithoutBorder + groupTileBorderThickness * 2;
    double groupTileBorderRadius = (groupTileWidth / 15);

    return Container(
        margin: EdgeInsets.only(top: screenSize.width * 0.05),
        child: ClipRRect(
          borderRadius:
              BorderRadius.all(Radius.circular(groupTileBorderRadius)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(groupTileBorderRadius),
              border: Border.all(
                  width: groupTileBorderThickness, color: Colors.black),
            ),
            height: groupTileHeight,
            width: groupTileWidth,
            child: Column(
              children: List<Widget>.generate(
                5,
                (index) => _WordTileWidget(
                  controller: controller,
                  allocatedHeight: groupTileHeightWithoutBorder / 5,
                  allocatedWidth: groupTileWidth,
                  wordIndex: wordGroupTileIndex * 5 + index,
                ),
              ),
            ),
          ),
        ));
  }
}

class _WordTileWidget extends StatelessWidget {
  final AnalysisScreenController controller;
  final double allocatedHeight;
  final double allocatedWidth; //tile font size depends on this
  final int wordIndex;
  const _WordTileWidget({
    required this.controller,
    required this.allocatedHeight,
    required this.allocatedWidth,
    required this.wordIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tileBackgroundColour = Colors.white.withOpacity(0.5);
    return (wordIndex < controller.initialList.length)
        ? Stack(
            children: [
              GestureDetector(
                onTap: () {
                  controller.handleOnTapped(wordIndex);
                },
                child: Stack(
                  children: [
                    ValueListenableBuilder(
                        valueListenable: controller.submitCalledNotifier,
                        builder: (context,submitDummyParam,_){
                          return (controller.isWordBeenRemovedNotifierList[wordIndex].value
                              || ! controller.hasUserTriggeredSubmit)
                              ? Container(
                            height: allocatedHeight,
                            width: allocatedWidth,
                            color: tileBackgroundColour,
                          )
                              : Container(
                            height: allocatedHeight,
                            width: allocatedWidth,
                            color: (controller.wordScoreList[wordIndex]>0)
                                ? Colors.green.withOpacity(0.5)
                                : Colors.red.withOpacity(0.5),
                          );
                        }
                    ),
                    Container(
                      padding: EdgeInsets.only(left: allocatedWidth * 0.03),
                      height: allocatedHeight,
                      width: allocatedWidth,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ValueListenableBuilder(
                            valueListenable: controller.isWordBeenRemovedNotifierList[wordIndex],
                            builder: (context,isStrikedThrough,_){
                              return (controller.isWordBeenRemovedNotifierList[wordIndex].value)
                                ? Text(
                                controller.initialList[wordIndex],
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: allocatedWidth/12
                                ))
                                : Text(
                                controller.initialList[wordIndex],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: allocatedWidth/12
                                ));
                            }
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        : Container(
      height: allocatedHeight,
      width: allocatedWidth,
      color: tileBackgroundColour,);
  }
}
