import 'dart:math';

List<String> calcOperationsList = ['+', '-', '*', '/'];
List<int> stages = [11, 21, 31, 51, 61, 101, 201, 301, 401, 501, 601, 1001];
DateTime? now;
Random random = Random();

// import 'package:rechnen_spiel/bloc/bloc_classes.dart';

// const String title = 'Rechnen Spiel';
// var now = DateTime.now();
// var rnd = Random();
// DateTime? startZeit;
// int dauer = 0;
// int? dieAntwort;
// bool berechnungGegeben = true;
// bool antwortGegeben = false;
// String rechengang = '+';
// List<String> rechenGangsList = ['+', '-', '*', '/'];
// int rechenGangsIndex = 0;
// int maxStageAddieren = 0;
// int maxStageSubtrahieren = 0;
// int spielerNmmer = 1;
// int maxStageMalen = 0;

// int maxStageTeilen = 0;

// int stageAddieren = 0;
// int stageSubtrahieren = 0;

// int stageMalen = 0;
// int stageTeilen = 0;

// List<int> stages = [11, 21, 31, 51, 61, 101, 201, 301, 401, 501, 601, 1001];
// int firstNumber = 0;
// int secondNumber = 0;
// String bewertung = '';
// int richtigeAntworten = 0;
// int alleAntworten = 0;
// List<List<int>> addiernStufen = [
//   spieler.addierenZeitS1,
//   spieler.addierenZeitS2,
//   spieler.addierenZeitS3,
//   spieler.addierenZeitS4,
//   spieler.addierenZeitS5,
//   spieler.addierenZeitS6,
//   spieler.addierenZeitS7,
//   spieler.addierenZeitS8,
//   spieler.addierenZeitS9,
//   spieler.addierenZeitS10,
//   spieler.addierenZeitS11,
//   spieler.addierenZeitS12,
// ];
// List<List<int>> subtrahiernStufen = [
//   spieler.subtrahierenZeitS1,
//   spieler.subtrahierenZeitS2,
//   spieler.subtrahierenZeitS3,
//   spieler.subtrahierenZeitS4,
//   spieler.subtrahierenZeitS5,
//   spieler.subtrahierenZeitS6,
//   spieler.subtrahierenZeitS7,
//   spieler.subtrahierenZeitS8,
//   spieler.subtrahierenZeitS9,
//   spieler.subtrahierenZeitS10,
//   spieler.subtrahierenZeitS11,
//   spieler.subtrahierenZeitS12,
// ];
// List<List<int>> malenStufen = [
//   spieler.malenZeitS1,
//   spieler.malenZeitS2,
//   spieler.malenZeitS3,
//   spieler.malenZeitS4,
//   spieler.malenZeitS5,
//   spieler.malenZeitS6,
//   spieler.malenZeitS7,
//   spieler.malenZeitS8,
//   spieler.malenZeitS9,
//   spieler.malenZeitS10,
//   spieler.malenZeitS11,
//   spieler.malenZeitS12,
// ];

// List<List<int>> teilenStufen = [
//   spieler.teilenZeitS1,
//   spieler.teilenZeitS2,
//   spieler.teilenZeitS3,
//   spieler.teilenZeitS4,
//   spieler.teilenZeitS5,
//   spieler.teilenZeitS6,
//   spieler.teilenZeitS7,
//   spieler.teilenZeitS8,
//   spieler.teilenZeitS9,
//   spieler.teilenZeitS10,
//   spieler.teilenZeitS11,
//   spieler.teilenZeitS12,
// ];