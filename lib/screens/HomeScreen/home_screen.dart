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
    final screenSize = MediaQuery.of(context).size;
    HomeScreenController controller = HomeScreenController(
      context: context,
    );
    return WillPopScope(
      onWillPop: () async{return false;}, //disables back button in main screen, TODO make double tap back to exit
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: Container(
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
                      return ElevatedButton(
                          onPressed: (controller.isBlitzContinueEnabled)
                              ? (){controller.handlePlayWordBlitz(isContinuing: true);}
                              : null,
                          child: const Text("Continue WordBlitz"));
                    }
                  ),

                  const ElevatedButton(
                      onPressed: null,/*() async{
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context)=> const AnalysisScreen(
                              gridLayout: ["G","Q","R","P",
                                "G","Q","R","G",
                                "G","Q","R","G",
                                "G","Q","R","G",],
                              initialList: ["BOY","YOG","YOGA","READER","WWWWWWWWWWWWWWWW","AAAAAAAAAAAAAAAA","IIIIIIIIIIIIIIII",
                                "BOY","YOG","YOGA","READER","WWWWWWWWWWWWWWWW","ACCENT","IIIIIIIIIIIIIIII",
                                "BOY","YOG","YOGA","READER","WWWWWWWWWWWWWWWW","ACCENT","IIIIIIIIIIIIIIII",
                                "BOY","YOG","YOGA","READER","WWWWWWWWWWWWWWWW","ACCENT","IIIIIIIIIIIIIIII",
                                "BOY","YOG","YOGA","READER","WWWWWWWWWWWWWWWW","ACCENT","IIIIIIIIIIIIIIII",
                                "BOY","YOG","YOGA","READER","WWWWWWWWWWWWWWWW","ACCENT","IIIIIIIIIIIIIIII",],//temporarily here for debugging
                            ))
                        );
                        print(result);
                      },*/
                      /// temporarily disabled for alpha release 1
                      child: const Text("navigate to analysis")),
                  const ElevatedButton(
                      onPressed: null,/*() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context)=> const SettingsScreen()
                            )
                        );
                      },*/
                      /// temporarily disabled for alpha release 1
                      child: const Text("navigate to settings")),
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

