import 'package:flutter/material.dart';

//import screens
import 'package:wordblitz/screens/HomeScreen/home_screen_controller.dart';
import 'package:wordblitz/screens/BlitzScreen/blitz_screen.dart';
import 'package:wordblitz/screens/AnalysisScreen/analysis_screen.dart';
import 'package:wordblitz/screens/SettingsScreen/settings_screen.dart';
//

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size? size = MediaQuery.of(context).size;
    final screenSize = Size( ((size.width/size.height)>(5/7)) ? size.height * 5/7 : size.width,size.height );
    size = null; //do not use this variable
    HomeScreenController controller = HomeScreenController(
      context: context,
    );
    return WillPopScope(
      onWillPop: () async{return false;}, //disables back button in main screen, TODO make double tap back to exit
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: Container(
              color: Colors.white,
              padding:
                  EdgeInsets.all(/*50*/ screenSize.width /10), ///[Hardcoded]
              child: Column(
                //
                //
                // --main screen column--
                //
                //
                children: [
                  Image.asset("resources/images/title_screen_image.png"),
                  wordBlitzTitleLettersWidget(titleWidth: screenSize.width * 0.8 / 10),
                  Divider(),

                  ElevatedButton(
                      onPressed: (){controller.handlePlayWordBlitz(isContinuing: false);},
                      child: const Text("Play WordBlitz")),
                  ValueListenableBuilder(
                    valueListenable: controller.continueBlitzScreenDataNotifier,
                    builder: (context,gameData,_) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                                onPressed: (controller.isBlitzContinueEnabled)
                                    ? (){controller.handlePlayWordBlitz(isContinuing: true);}
                                    : null,
                                child: const Text("Continue WordBlitz")),
                          ),
                          /*IconButton(
                              alignment: Alignment.centerRight,
                              onPressed: null,
                              icon: Icon(Icons.delete)),*/
                        ],
                      );
                    }
                  ),

                  ElevatedButton(
                      onPressed: null/*()=>controller.handlePlayPuzzle()*/,
                      child: const Text("Play Puzzle Mode")),

                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context)=> const SettingsScreen()
                            )
                        );
                      },
                      child: const Text("Settings")),
                ],
                //
                //
                // --main screen column--
                //
                //
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class wordBlitzTitleLettersWidget extends StatelessWidget {
  final double titleWidth;
  const wordBlitzTitleLettersWidget({required this.titleWidth,});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
        List<Widget>.generate(4, (index) => Image.asset(
          "resources/images/tile_images/${"word"[index]}_tile.png",
          width: titleWidth,
        ))
            +
            [SizedBox(width: titleWidth/3,)]
            +
            List<Widget>.generate(5, (index) => Image.asset(
              "resources/images/tile_images/${"blitz"[index]}_tile.png",
              width: titleWidth,
            ))
    );
  }
}

