import 'package:flutter/material.dart';


// import from other features


import 'package:wordblitz/tools/config.dart';

// import from same features
import '../SettingsScreen/settings_screen.dart';

// import from same screen
import 'home_screen_controller.dart';
//

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size? size = MediaQuery.of(context).size;
    final screenSize = Size( ((size.width/size.height)>(4/7)) ? size.height * 4/7 : size.width,size.height );
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
                  Container(
                    height: screenSize.width * 0.7,
                    width: screenSize.width * 0.7,
                    child: Image.asset("resources/images/title_screen_image.png"),
                  ),
                  wordBlitzTitleLettersWidget(titleWidth: screenSize.width * 0.8 / 10),
                  Divider(),

                  ElevatedButton(
                      onPressed: (){controller.handlePlayWordBlitz(isContinuing: false);},
                      child: const Text("Play WordBlitz")),
                  ValueListenableBuilder(
                    valueListenable: controller.isBlitzContinueEnabled,
                    builder: (context,isContinueEnabled,_) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                                onPressed: (isContinueEnabled)
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

                  ValueListenableBuilder(
                    valueListenable: controller.isPuzzleEnabledNotifier,
                    builder: (context,isPuzzleEnabled,_) {
                      return (isPuzzleEnabled)
                          ? ElevatedButton(
                          onPressed: (Config.shouldPreloadPuzzleCache)?()=>controller.handlePlayPuzzle():null,
                          child: const Text("Play Puzzle Mode"))
                          :Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: screenSize.width/16,width: screenSize.width/16,),
                          ElevatedButton(onPressed: null, child: const Text("Play Puzzle Mode")),
                          SizedBox(height: screenSize.width/16,width: screenSize.width/16,child: CircularProgressIndicator()),
                      ],);
                    }
                  ),

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

                  ElevatedButton(
                      onPressed: null,
                      child: const Text("View Stats")),
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

