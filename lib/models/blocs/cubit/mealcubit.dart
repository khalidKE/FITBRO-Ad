import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:FitBro/models/data/data.dart';
import 'package:FitBro/models/repos/data_repo.dart';

part 'mealcubit.freezed.dart';

@freezed
class MealState with _$MealState {
  const factory MealState.loading() = _Loading;
  const factory MealState.loaded(List<Meal> data) = _Loaded;
  const factory MealState.error(String message) = _Error;
}

class MealCubit extends Cubit<MealState> {
  final DataRepo _dataRepo;
  MealCubit(this._dataRepo) : super(const MealState.loading());
  Future<void> fetchMeals() async {
    try {
      emit(const MealState.loading());
      final meals = await _dataRepo.getMeals();
      emit(MealState.loaded(meals));
    } catch (e) {
      emit(MealState.error(e.toString()));
    }
  }
}
