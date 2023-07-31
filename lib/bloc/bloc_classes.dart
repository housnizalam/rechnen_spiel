// ignore_for_file: public_member_api_docs, sort_constructors_first

class Player {
  String? name;
  Player({this.name});
  int maxStageAdition = 0;
  int maxStageSubtruction = 0;
  int maxStageMultiplication = 0;
  int maxStageSection = 0;
  CalcOperation adition = CalcOperation('+');
  CalcOperation subtraction = CalcOperation('-');
  CalcOperation multiblication = CalcOperation('*');
  CalcOperation sectioning = CalcOperation('/');
}

class CalcOperation {
  String operation;
  CalcOperation(this.operation);
  OperationStage operationStage = OperationStage();
  int maxStage = 0;
  List<int> stages = [];
  // int stage1 = 0;
  // int stage2 = 0;
  // int stage3 = 0;
  // int stage4 = 0;
  // int stage5 = 0;
  // int stage6 = 0;
  // int stage7 = 0;
  // int stage8 = 0;
  // int stage9 = 0;
  // int stage10 = 0;
  // int stage11 = 0;
  // int stage12 = 0;

  int? calculate(int firstNumber, int secondNumber) {
    if (operation == '+') {
      return firstNumber + secondNumber;
    }
    if (operation == '-') {
      return firstNumber - secondNumber;
    }
    if (operation == '*') {
      return firstNumber * secondNumber;
    }
    if (operation == '/') {
      return firstNumber / secondNumber as int;
    }
    return null;
  }
}

class OperationStage {
  int stageNumber = 0;
  List<int> bestScores = [];
}




  // List<int> addierenZeitS1 = [];

  // List<int> addierenZeitS2 = [];

  // List<int> addierenZeitS3 = [];

  // List<int> addierenZeitS4 = [];

  // List<int> addierenZeitS5 = [];

  // List<int> addierenZeitS6 = [];

  // List<int> addierenZeitS7 = [];

  // List<int> addierenZeitS8 = [];

  // List<int> addierenZeitS9 = [];

  // List<int> addierenZeitS10 = [];

  // List<int> addierenZeitS11 = [];

  // List<int> addierenZeitS12 = [];

  // List<int> subtrahierenZeitS1 = [];

  // List<int> subtrahierenZeitS2 = [];

  // List<int> subtrahierenZeitS3 = [];

  // List<int> subtrahierenZeitS4 = [];

  // List<int> subtrahierenZeitS5 = [];

  // List<int> subtrahierenZeitS6 = [];

  // List<int> subtrahierenZeitS7 = [];

  // List<int> subtrahierenZeitS8 = [];

  // List<int> subtrahierenZeitS9 = [];

  // List<int> subtrahierenZeitS10 = [];

  // List<int> subtrahierenZeitS11 = [];

  // List<int> subtrahierenZeitS12 = [];

  // List<int> malenZeitS1 = [];

  // List<int> malenZeitS2 = [];

  // List<int> malenZeitS3 = [];

  // List<int> malenZeitS4 = [];

  // List<int> malenZeitS5 = [];

  // List<int> malenZeitS6 = [];

  // List<int> malenZeitS7 = [];

  // List<int> malenZeitS8 = [];

  // List<int> malenZeitS9 = [];

  // List<int> malenZeitS10 = [];

  // List<int> malenZeitS11 = [];

  // List<int> malenZeitS12 = [];

  // List<int> teilenZeitS1 = [];

  // List<int> teilenZeitS2 = [];

  // List<int> teilenZeitS3 = [];

  // List<int> teilenZeitS4 = [];

  // List<int> teilenZeitS5 = [];

  // List<int> teilenZeitS6 = [];

  // List<int> teilenZeitS7 = [];

  // List<int> teilenZeitS8 = [];

  // List<int> teilenZeitS9 = [];

  // List<int> teilenZeitS10 = [];

  // List<int> teilenZeitS11 = [];

  // List<int> teilenZeitS12 = [];