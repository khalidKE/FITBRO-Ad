import 'package:FitBro/models/blocs/cubit/StoreCubit/srore_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../data/data.dart';

class SaveCubit extends Cubit<StoreState> {
  SaveCubit() : super(StoreInitial());

  static SaveCubit get(context) => BlocProvider.of(context);

  List<WorkoutSession> workoutSession = [];
  static const String _workoutKey = 'workout_sessions';

  Future<void> setUserExcersiceInfo({
    required String startDate,
    required String endDate,
    required List<WorkoutData> listWorkOuts,
  }) async {
    emit(LoadingSetExcersiceInfo());
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutSession = WorkoutSession(
        startTime: DateTime.parse(startDate),
        finishTime: DateTime.parse(endDate),
        workoutData: listWorkOuts,
      );

      // Get existing sessions
      final String? sessionsJson = prefs.getString(_workoutKey);
      List<WorkoutSession> sessions = [];
      if (sessionsJson != null) {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        sessions = decoded.map((item) => WorkoutSession.fromJson(item as Map<String, dynamic>)).toList();
      }

      // Add new session
      sessions.add(workoutSession);

      // Save updated sessions
      final sessionsToSave = sessions.map((s) => s.toJson()).toList();
      await prefs.setString(_workoutKey, jsonEncode(sessionsToSave));
      emit(SuccessSetExcersiceInfo());
    } catch (e) {
      emit(ErrorSetExcersiceInfo(e.toString()));
    }
  }

  Future<void> getUserExcersiceInfo() async {
    try {
      emit(LoadingGetExcersiceInfo());
      workoutSession.clear();

      final prefs = await SharedPreferences.getInstance();
      final String? sessionsJson = prefs.getString(_workoutKey);
      
      if (sessionsJson != null) {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        workoutSession = decoded.map((item) => WorkoutSession.fromJson(item as Map<String, dynamic>)).toList();
      }

      emit(SuccessGetExcersiceInfo(workoutSession));
    } catch (e) {
      emit(ErrorGetExcersiceInfo(e.toString()));
    }
  }
}
