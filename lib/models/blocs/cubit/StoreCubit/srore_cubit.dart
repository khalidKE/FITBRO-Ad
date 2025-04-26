import 'package:FitBro/models/blocs/cubit/StoreCubit/srore_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../consts/Collections.dart';
import '../../../data/Local/SharedKeys.dart';
import '../../../data/Local/SharedPerfrence.dart';
import '../../../data/data.dart';



class SaveCubit extends Cubit<StoreState> {
  SaveCubit() : super(StoreInitial());

  static SaveCubit get(context) => BlocProvider.of(context);

  List<WorkoutSession> workoutSession = [];

  Future<void> setUserExcersiceInfo({
    required String startDate,
    required String endDate,
    required List<WorkoutData> listWorkOuts,
  }) async {
    emit(LoadingSetExcersiceInfo());
    try {
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(LocalData.getData(key: SharedKey.uid))
          .collection("Excersice")
          .add({
            "Start": startDate,
            "Ends": endDate,
            "WorkOutList": [
              for (var item in listWorkOuts)
                {
                  "name": item.exercise.name,
                  "muscles": item.exercise.muscles,
                  "equipment": item.exercise.equipment,
                  "id": item.exercise.id,
                  "image": item.exercise.image,
                  "weights": item.weights, // Store as list directly
                  "instruction": item.exercise.instruction,
                  "difficulty": item.exercise.difficulty,
                },
            ],
          });
      emit(SuccessSetExcersiceInfo());
    } catch (e) {
      emit(ErrorSetExcersiceInfo(e.toString()));
    }
  }

  Future<void> getUserExcersiceInfo() async {
    try {
      emit(LoadingGetExcersiceInfo());
      workoutSession.clear(); // Clear previous sessions to avoid duplicates
      var userDoc = FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(LocalData.getData(key: SharedKey.uid));

      var exerciseSnapshot = await userDoc.collection("Excersice").get();

      for (var doc in exerciseSnapshot.docs) {
        var docData = doc.data();
        List<WorkoutData> workoutData = [];

        for (var workoutItem in docData["WorkOutList"] ?? []) {
          workoutData.add(
            WorkoutData(
              exercise: Exercise(
                id: workoutItem["id"] != null ? workoutItem["id"] as int : 0,
                name: workoutItem["name"] ?? "Unnamed Exercise",
                muscles: List<String>.from(workoutItem["muscles"] ?? []),
                equipment: workoutItem["equipment"] ?? "No equipment",
                image: workoutItem["image"] ?? "",
                instruction: workoutItem["instruction"] ?? "No instruction",
                difficulty: workoutItem["difficulty"] ?? "Basic",
              ),
              weights: List<String>.from(workoutItem["weights"] ?? []),
            ),
          );
        }

        workoutSession.add(
          WorkoutSession(
            startTime:
                DateTime.tryParse(docData["Start"] ?? '') ?? DateTime.now(),
            finishTime:
                DateTime.tryParse(docData["Ends"] ?? '') ?? DateTime.now(),
            workoutData: workoutData,
          ),
        );
      }

      emit(SuccessGetExcersiceInfo(workoutSession));
    } catch (e) {
      emit(ErrorGetExcersiceInfo(e.toString()));
    }
  }
}
