import 'dart:math';

double calculateLotto(int embeddedInt){
  //input embedded int, output calculated lotto
  List<double> binaryString = embeddedInt
      .toRadixString(2)
      .padLeft(32,"0")
      .split("")
      .map(double.parse)
      .toList();
  double mastery = 0;  //50 for no knowledge,100 for max, 0 is for purposely wrong
  for(int i=0;i<32;i++){mastery += (weights[i] * binaryString[i]);}

  double tickets =0;
  //for recent positive AND negative streak exactly 2 or 3 streaks, we impose a temporary ticket increase to increase tests.
  if(binaryString[31] == binaryString[30]){
    if(binaryString[30] != binaryString [29]){tickets += 1;}
    if(binaryString[30] != binaryString[28]){tickets += 1;} //double counting was intended
  }
  else{ //for brokenStreak 3 or longer imposes huge ticket increase
    if((binaryString[30] == binaryString[29])
        && (binaryString[30] == binaryString[28])
        && (binaryString[30] == binaryString[27]))
    {tickets += 5;}
  }
  /// Tickets Formula Version 1
  if (mastery>50){tickets += 1.33489797668 / (pow(((mastery - 25) / 30), 6) + 1);} //will always be less or equal to 1
  else{tickets += 1;}

  return tickets;
}

//created using logistic equation with coefficients A=0.3 and B=8, A-A/(1+e^{-A(x-B)}),then normalised to 100 for summation
///Note: weights must add up to 100
final List<double> weights = [
  0.011510039282569154, 0.015531457292594392, 0.020955314565879863, 0.028268588139488616,
  0.03812562138507623, 0.05140423190174956, 0.06927947435621366, 0.09331966396448337,
  0.12560966085877193, 0.16890605265758038, 0.22682689428563094, 0.3040736131406134,
  0.4066722810072427, 0.5422025076546448, 0.7199511423161985, 0.9508827478738929,
  1.2472636994566049, 1.6217308812546412, 2.085603697747107, 2.6463707347427645,
  3.3046076754086693, 4.051080696324685, 4.865241672451927, 5.716315497498483,
  6.567389322545038, 7.381550298672282, 8.128023319588296, 8.786260260254203,
  9.34702729724986, 9.810900113742322, 10.185367295540361, 10.481748247123074
];