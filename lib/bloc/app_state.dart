// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_bloc.dart';

@immutable
class AppState {
  final int _stage;
  final String _title;
  final DateTime? _startTime;
  final int _period;
  final String? _answer;
  final bool _isAskGived;
  final bool _isAnswerGived;
  final String _calcOperation;
  final int _operationenIndex;
  final int _maxStageAdition;
  final int _maxStageSubtraction;
  final int _maxStageMultiplication;

  final int _maxStageSectioning;

  final int _actualStageAdition;
  final int _actualStageSubtruction;

  final int _actualStageMultiplication;
  final int _actualStageSectioning;
  final int? _firstNumber;
  final int? _secondNumber;
  final String _valuation;
  final int _trueAnswers;
  final int _allAnswers;
  final Player? _player;
  const AppState({
    int stage = 0,
    String title = '',
    DateTime? startTime,
    int period = 0,
    String? answer ,
    bool isAskGived = false,
    bool isAnswerGived = false,
    String calcOperation = '+',
    int operationenIndex = 0,
    int maxStageAdition = 0,
    int maxStageSubtraction = 0,
    int maxStageMultiplication = 0,
    int maxStageSectioning = 0,
    int actualStageAdition = 0,
    int actualStageSubtruction = 0,
    int actualStageMultiplication = 0,
    int actualStageSectioning = 0,
    int? firstNumber,
    int? secondNumber,
    String valuation='',
    int trueAnswers = 0,
    int allAnswers = 0,
    Player? player,
  })  : _stage = stage,
        _title = title,
        _startTime = startTime,
        _period = period,
        _answer = answer,
        _isAskGived = isAskGived,
        _isAnswerGived = isAnswerGived,
        _calcOperation = calcOperation,
        _operationenIndex = operationenIndex,
        _maxStageAdition = maxStageAdition,
        _maxStageSubtraction = maxStageSubtraction,
        _maxStageMultiplication = maxStageMultiplication,
        _maxStageSectioning = maxStageSectioning,
        _actualStageAdition = actualStageAdition,
        _actualStageSubtruction = actualStageSubtruction,
        _actualStageMultiplication = actualStageMultiplication,
        _actualStageSectioning = actualStageSectioning,
        _firstNumber = firstNumber,
        _secondNumber = secondNumber,
        _valuation = valuation,
        _trueAnswers = trueAnswers,
        _allAnswers = allAnswers,
        _player = player;

  int get stage => _stage;
  String get title => _title;
  DateTime? get startTime => _startTime;
  int get period => _period;
  String? get answer => _answer;
  bool get isAskGived => _isAskGived;
  bool get isAnswerGived => _isAnswerGived;
  String get calcOperation => _calcOperation;
  int get operationenIndex => _operationenIndex;
  int get maxStageAdition => _maxStageAdition;
  int get maxStageSubtraction => _maxStageSubtraction;
  int get maxStageMultiplication => _maxStageMultiplication;
  int get maxStageSectioning => _maxStageSectioning;
  int get actualStageAdition => _actualStageAdition;
  int get actualStageSubtruction => _actualStageSubtruction;
  int get actualStageMultiplication => _actualStageMultiplication;
  int get actualStageSectioning => _actualStageSectioning;
  int? get firstNumber => _firstNumber;
  int? get secondNumber => _secondNumber;
  String get valuation => _valuation;
  int get trueAnswers => _trueAnswers;
  int get allAnswers => _allAnswers;
  Player? get player => _player;

  AppState copyWith({
    int Function()? stage,
    String Function()? title,
    DateTime? Function()? startTime,
    int Function()? period,
    String? Function()? answer,
    bool Function()? isAskGived,
    bool Function()? isAnswerGived,
    String Function()? calcOperation,
    int Function()? operationsIndex,
    int Function()? maxStageAdition,
    int Function()? maxStageSubtraction,
    int Function()? maxStageMultiplication,
    int Function()? maxStageSectioning,
    int Function()? actualStageAdition,
    int Function()? actualStageSubtruction,
    int Function()? actualStageMultiplication,
    int Function()? actualStageSectioning,
    int? Function()? firstNumber,
    int? Function()? secondNumber,
    String Function()? valuation,
    int Function()? trueAnswers,
    int Function()? allAnswers,
    Player? Function()? player,
  }) {
    return AppState(
      stage: stage == null ? _stage : stage(),
      title: title == null ? _title : title(),
      startTime: startTime == null ? _startTime : startTime(),
      period: period == null ? _period : period(),
      answer: answer == null ? _answer : answer(),
      isAskGived: isAskGived == null ? _isAskGived : isAskGived(),
      calcOperation: calcOperation == null ? _calcOperation : calcOperation(),
      operationenIndex: operationsIndex == null ? _operationenIndex : operationsIndex(),
      maxStageAdition: maxStageAdition == null ? _maxStageAdition : maxStageAdition(),
      maxStageSubtraction: maxStageSubtraction == null ? _maxStageSubtraction : maxStageSubtraction(),
      maxStageMultiplication: maxStageMultiplication == null ? _maxStageMultiplication : maxStageMultiplication(),
      maxStageSectioning: maxStageSectioning == null ? _maxStageSectioning : maxStageSectioning(),
      actualStageAdition: actualStageAdition == null ? _actualStageAdition : actualStageAdition(),
      actualStageSubtruction: actualStageSubtruction == null ? _actualStageSubtruction : actualStageSubtruction(),
      actualStageMultiplication:
          actualStageMultiplication == null ? _actualStageMultiplication : actualStageMultiplication(),
      actualStageSectioning: actualStageSectioning == null ? _actualStageSectioning : actualStageSectioning(),
      firstNumber: firstNumber == null ? _firstNumber : firstNumber(),
      secondNumber: secondNumber == null ? _secondNumber : secondNumber(),
      valuation: valuation == null ? _valuation : valuation(),
      trueAnswers: trueAnswers == null ? _trueAnswers : trueAnswers(),
      allAnswers: allAnswers == null ? _allAnswers : allAnswers(),
      player: player == null ? _player : player(),
    );
  }
}
