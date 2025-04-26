

import 'package:FitBro/models/data/data.dart';


abstract class StoreState {}

class StoreInitial extends StoreState {}

class LoadingSetExcersiceInfo extends StoreState {}

class SuccessSetExcersiceInfo extends StoreState {}

class ErrorSetExcersiceInfo extends StoreState {
  final String error;

  ErrorSetExcersiceInfo(this.error);
}

class LoadingGetExcersiceInfo extends StoreState {}

class SuccessGetExcersiceInfo extends StoreState {
  final List<WorkoutSession> workoutSessions;

  SuccessGetExcersiceInfo(this.workoutSessions);
}

class ErrorGetExcersiceInfo extends StoreState {
  final String error;

  ErrorGetExcersiceInfo(this.error);
}
