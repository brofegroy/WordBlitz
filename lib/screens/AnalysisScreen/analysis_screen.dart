import 'package:flutter/material.dart';

//import screens
import 'package:wordblitz/screens/AnalysisScreen/analysis_screen_controller.dart';
//

class AnalysisScreen extends StatelessWidget{
  const AnalysisScreen({
    Key? key
  }) : super(key : key);

  @override
  Widget build(BuildContext context){
    final controller = AnalysisScreenController();

    return WillPopScope(
      onWillPop: ()async{
        Navigator.pop(context,{
          "screen": AnalysisScreen,
          "list": ["test","List"],
          "time": "i have unlimited time"
        });
        return true;
      },
      child: Scaffold(
        body: Text("this analysis screen is built"),
      ),
    );
  }
}