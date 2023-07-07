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
    HomeScreenController controller = HomeScreenController();
    double titleWidth = screenSize.width * 0.8 / 10;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
              Image.asset(
                  "resources/images/title_screen_image.png"
              ),
              Row(
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
              ),
              Divider(),
              ElevatedButton(
                  onPressed: () async{
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context)=> const BlitzScreen(
                              initialGameTime: 180,
                              initialWordList: [],
                              initialGridLayout: null,//null tells it to random
                            )
                        )
                    );
                    print(result);
                    print("finished awaiting in home");

/*                    if(returnValue["screen"] == BlitzScreen){
                      print(returnValue);
                    }
                    if(returnValue["screen"] == AnalysisScreen){
                      print(returnValue);
                    }//TODO handle return values*/
                  },
                  child: const Text("Play WordBlitz")),
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
    );
  }
}
