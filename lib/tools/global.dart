import 'dart:async';

import 'dict_and_dice.dart';


class Global{
  static bool get isDictDiceLoading => (Dice.isDiceLoading || Dict.isDictLoading);

  static Completer<bool> isPuzzleLoaded = Completer<bool>();
}