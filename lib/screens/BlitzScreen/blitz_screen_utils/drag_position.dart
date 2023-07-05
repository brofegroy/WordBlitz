import 'dart:math';
import 'dart:ui';
import 'package:tuple/tuple.dart';

class DragPosition{
  static const double _containerToGridSizeRatio = 1/5.0; //[Hardcoded] compares size of container compared to parent Grid's size
  static const double _marginToGridSizeRatio = (1 - _containerToGridSizeRatio * 4) / 5.0;
  static const double _halfMarginRatio = _marginToGridSizeRatio / 2.0;
  static const double _circleHitboxModifier = 0.75; //[Hardcoded] leniency given to select tiles within a circular hitbox, 1= full circle, 0=no hit box

  static Tuple2<int,int>? getRowCol(Offset offset,double gridSize){
    double initialX = offset.dx - gridSize* _halfMarginRatio;
    double initialY = offset.dy - gridSize* _halfMarginRatio;
    double cellSize = (gridSize - gridSize * _marginToGridSizeRatio)/4.0;

    //checks pan position within bounds,returns if outside
    if( !(initialX>0 && initialX<(cellSize*4) &&
          initialY>0 && initialY<(cellSize*4))
    ){
      return null;
    }
    //

    int outputCol = (initialX/cellSize).floor();
    int outputRow = (initialY/cellSize).floor();

    //checks pan within an imaginary circle hitbox centered on each container[outputRow][outputCol]
    double gridX = initialX - outputCol * cellSize;
    double gridY = initialY - outputRow * cellSize;
    double xFromCenter = (cellSize/2.0 - gridX);
    double yFromCenter = (cellSize/2.0 - gridY);
    double allowedRadius = cellSize / 2 * _circleHitboxModifier;
    bool isWithinCircle = (sqrt(pow(xFromCenter, 2) + pow(yFromCenter, 2)) < allowedRadius );

    //return outputs
    if (isWithinCircle){
      return Tuple2<int,int>(outputRow,outputCol);
    } else{
      return null;
    }
  }

}