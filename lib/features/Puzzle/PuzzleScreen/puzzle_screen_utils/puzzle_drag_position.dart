
class GetPuzzleDragPosition{
  static int? getDragIndex(double X,double Y,double gridsize){
    ///this is a swipe detector for a 2x2 grid

    //reject outside box
    if( (X>gridsize) || (X<0) || (Y>gridsize) || (Y<0) ){return null;}

    double center = gridsize/2;
    int outputIndex = 0;

    //reject diamond shaped center,for ease of diagonal swipes
    double proportionOffsetX = (X-center)/center;
    double proportionOffsetY = (Y-center)/center;
    if((proportionOffsetX.abs() + proportionOffsetY.abs())<0.5){return null;}

    if(X>center){outputIndex += 1;}
    if(Y>center){outputIndex += 2;}

    return outputIndex;
  }
}