import 'dict_and_dice.dart';

class Global{
  static bool get isDictDiceLoading => (Dice.isDiceLoading || Dict.isDictLoading);

  static void init(){
    Dict.load();
    Dice.load();
  }
}