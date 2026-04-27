



// gibrnd() {
//   startZeit = DateTime.now();

//   if (berechnungGegeben) {
//     if (rechengang == '/') {
//       firstNumber = gibUnBrimeNummer();
//       secondNumber = gibPassendeTeilNummer();
//     } else if (rechengang == '-') {
//       firstNumber = rnd.nextInt(stages[stageSubtrahieren]);
//       secondNumber = rnd.nextInt(stages[stageSubtrahieren]);
//     } else if (rechengang == '*') {
//       firstNumber = rnd.nextInt(stages[stageMalen]);
//       secondNumber = rnd.nextInt(stages[stageMalen]);
//     } else {
//       firstNumber = rnd.nextInt(stages[stageAddieren]);
//       secondNumber = rnd.nextInt(stages[stageAddieren]);
//     }
//   }
//   berechnungGegeben = false;
// }

// rechenWahl() {
//   if (rechenGangsIndex == 3) {
//     rechenGangsIndex = 0;
//   } else {
//     rechenGangsIndex++;
//   }
//   rechengang = rechenGangsList[rechenGangsIndex];
//   alleAntworten = 0;
//   richtigeAntworten = 0;
//   dieAntwort = null;
//   antwortGegeben = false;
//   bewertung = '';
//   firstNumber = 0;
//   secondNumber = 0;
//   berechnungGegeben = true;

//   dauer = 0;
// }

// stufeWiederholen() {
//   alleAntworten = 0;
//   richtigeAntworten = 0;
//   bewertung = '';

//   dauer = 0;
//   berechnungGegeben = true;
//   bewertung = '$richtigeAntworten / $alleAntworten';
//   firstNumber = 0;
//   secondNumber = 0;
//   dieAntwort = null;
//   antwortGegeben = false;
// }

// naechsteAufgabe() {
//   if (!antwortGegeben) {
//   } else {
//     berechnungGegeben = true;
//     bewertung = '$richtigeAntworten / $alleAntworten';
//     firstNumber = 0;
//     secondNumber = 0;
//     dieAntwort = null;
//     startZeit = null;
//     antwortGegeben = false;
//   }
// }

// pruf() {
//   if (dieAntwort == null) {
//   } else if (antwortBewertung()) {
//     if (startZeit != null) {
//       now = DateTime.now();
//       dauer += now.difference(startZeit!).inMilliseconds;
//     }

//     richtigeAntworten++;
//     alleAntworten++;
//     bewertung = 'Richtig $richtigeAntworten / $alleAntworten';
//     antwortGegeben = true;
//   } else {
//     if (startZeit != null) {
//       now = DateTime.now();
//       dauer += now.difference(startZeit!).inMilliseconds;
//     }

//     alleAntworten++;
//     bewertung = 'Falsch $richtigeAntworten / $alleAntworten';
//     antwortGegeben = true;
//   }
//   if (richtigeAntworten > 7) {
//     bewertung = 'Bestanden';
//   } else if (alleAntworten > 9 && richtigeAntworten < 8) {
//     bewertung = 'durchgefallen';
//   }
// }

// neuStufe() {
//   if (richtigeAntworten > 7) {
//     if (stageAddieren + 1 < stages.length) {
//       if (rechengang == '+') {
//         addiernStufen[stageAddieren].add(dauer);
//         stageAddieren++;
//         spieler.maxStageAddieren++;
//       } else if (rechengang == '-') {
//         subtrahiernStufen[stageSubtrahieren].add(dauer);

//         stageSubtrahieren++;
//         spieler.maxStageSubtrahieren++;
//       } else if (rechengang == '*') {
//         malenStufen[stageMalen].add(dauer);
//         stageMalen++;
//         spieler.maxStageMalen++;
//       } else if (rechengang == '/') {
//         teilenStufen[stageTeilen].add(dauer);

//         stageTeilen++;
//         spieler.maxStageTeilen++;
//       }
//     }
//     alleAntworten = 0;
//     richtigeAntworten = 0;

//     dauer = 0;
//   }
// }

// vorStufe() {
//   if (rechengang == '+') {
//     stageAddieren--;
//   } else if (rechengang == '-') {
//     stageSubtrahieren--;
//   } else if (rechengang == '*') {
//     stageMalen--;
//   } else if (rechengang == '/') {
//     stageTeilen--;
//   }
//   antwortGegeben = true;
//   alleAntworten = 0;
//   richtigeAntworten = 0;
//   firstNumber = 0;
//   secondNumber = 0;

//   dauer = 0;
// }

// nachStufe() {
//   if (rechengang == '+') {
//     stageAddieren++;
//   } else if (rechengang == '-') {
//     stageSubtrahieren++;
//   } else if (rechengang == '*') {
//     stageMalen++;
//   } else if (rechengang == '/') {
//     stageTeilen++;
//   }
//   antwortGegeben = true;
//   alleAntworten = 0;
//   richtigeAntworten = 0;
//   firstNumber = 0;
//   secondNumber = 0;

//   dauer = 0;
// }
