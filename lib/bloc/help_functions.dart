import 'dart:math';
import 'app_bloc.dart';
import 'global_variablen.dart';

// TODO: verify usage when implementing reverse-question mode.
String numberToOperation(String operation, int number, AppState state) {
  String result = '';
  int firstnumber;
  int secondnumber;
  if (operation == '+') {
    secondnumber = Random().nextInt(stages[state.stage]);
    firstnumber = number - secondnumber;
    result = '$firstnumber+$secondnumber';
    return result;
  }
  if (operation == '-') {
    secondnumber = Random().nextInt(stages[state.stage]);
    firstnumber = number + secondnumber;
    result = '$firstnumber-$secondnumber';
    return result;
  }
  if (operation == '*') {
    List<int> sutable = [];
    for (int i = 1; i <= number; i++) {
      if (number % i == 0) {
        sutable.add(i);
      }
    }
    secondnumber = sutable[Random().nextInt(sutable.length)];
    firstnumber = number ~/ secondnumber;
    result = '$firstnumber*$secondnumber';
    return result;
  }
  return result;
}
