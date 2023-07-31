// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'rechner_bloc.dart';

@immutable
abstract class AppEvent {}

class StartGameEvent extends AppEvent {}

class TestingEvent extends AppEvent {
  final int? answer;
  TestingEvent({
    required this.answer,
  });
}

class GiveNameEvent extends AppEvent {
  final String name;
  GiveNameEvent({
    required this.name,
  });
}

class WinToNextStageEvent extends AppEvent {}

class PreviosStageEvent extends AppEvent {}

class NextTaskEvent extends AppEvent {}

class NextStageEvent extends AppEvent {}

class ChooseOperationEvent extends AppEvent {}

class RepeatStageEvent extends AppEvent {}

// class WinNewStageEvent extends AppEvent {}
