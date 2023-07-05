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
    HomeScreenController controller = HomeScreenController();
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Container(
          padding:
              EdgeInsets.all(/*50*/ screenWidth /6), ///[Hardcoded]
          child: Column(
            //
            //
            // --main screen column--
            //
            //
            children: [
              ElevatedButton(
                  onPressed: () async{
                    var returnValue = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context)=> const BlitzScreen(
                              initialGameTime: 10,
                              initialWordList: ["1","2","3"],
                            )
                        )
                    );
                    print("finished awaiting in home");
                    if(returnValue["screen"] == BlitzScreen){
                      print(returnValue);
                    }
                    if(returnValue["screen"] == AnalysisScreen){
                      print(returnValue);
                    }//TODO handle return values
                  },
                  child: const Text("navigate to blitzscreen")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context)=> const AnalysisScreen()
                        )
                    );
                  },
                  child: const Text("navigate to analysis")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context)=> const SettingsScreen()
                        )
                    );
                  },
                  child: const Text("navigate to settings")),
              
              Image.asset(
                "resources/images/title_screen_image.png"
              ),
              
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  color: Colors.blue,
                  child: const Text("remaining space"),
                ),
              ),
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
