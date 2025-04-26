import 'package:FitBro/view/menu/menu_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:FitBro/common/color_extension.dart';
import 'package:FitBro/models/blocs/cubit/workoutcubit.dart';
import 'package:FitBro/models/data/data.dart';
import 'package:FitBro/screens/exercising.dart';
import 'package:FitBro/view/exercise/exercise_view_2.dart';

class WorkoutPicker extends StatelessWidget {
  const WorkoutPicker({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> muscles = [
      'All',
      'Chest',
      'Triceps',
      'Shoulders',
      'Lats',
      'Upper Chest',
      'Back',
      'Biceps',
      'Traps',
      'Legs',
      'Gluteus',
      'Lower Back',
      'Core',
      'Full Body',
      'Cardio',
    ];

    // Define colors for consistency
    final Map<String, Color> fitColors = {
      "primary": const Color(0xFF1E5128),
      "secondary": const Color(0xFF4E9F3D),
      "accent": const Color(0xFF8FB339),
      "light": const Color(0xFFD8E9A8),
      "dark": const Color(0xFF191A19),
      "black": Colors.black,
      "background": const Color(0xFFF5F5F5),
      "darkBackground": const Color(0xFF2A2A2A),
    };

    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, state) {
        return state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded:
              (data) => ValueListenableBuilder<bool>(
                valueListenable: isDarkModeNotifier,
                builder: (context, isDarkMode, child) {
                  return Scaffold(
                    backgroundColor:
                        isDarkMode
                            ? fitColors["darkBackground"]
                            : Colors.grey[50],
                    appBar: AppBar(
                      elevation: 0,
                      title: Text(
                        "Pick Your Workout",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: TColor.primary,
                    ),
                    body: Column(
                      children: [
                        MuscleTabs(
                          muscles: muscles,
                        ), // Update MuscleTabs separately if needed
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return ExerciseTile(exercise: data[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                    floatingActionButton: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WorkoutSessionScreen(),
                          ),
                        );
                      },
                      backgroundColor: TColor.primary,
                      icon: const Icon(FontAwesomeIcons.play),
                      label: const Text("Start Workout"),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                  );
                },
              ),
          error:
              (message) => ValueListenableBuilder<bool>(
                valueListenable: isDarkModeNotifier,
                builder: (context, isDarkMode, child) {
                  return Center(
                    child: Text(
                      "Error: $message",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ),
        );
      },
    );
  }
}

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  const ExerciseTile({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    // Define colors for consistency
    final Map<String, Color> fitColors = {
      "primary": const Color(0xFF1E5128),
      "secondary": const Color(0xFF4E9F3D),
      "accent": const Color(0xFF8FB339),
      "light": const Color(0xFFD8E9A8),
      "dark": const Color(0xFF191A19),
      "black": Colors.black,
      "background": const Color(0xFFF5F5F5),
      "darkBackground": const Color(0xFF2A2A2A),
    };

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          color: isDarkMode ? fitColors["darkBackground"] : Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor:
                  isDarkMode ? fitColors["darkBackground"] : Colors.white,
              backgroundImage: NetworkImage(exercise.image),
              radius: 28,
            ),
            title: Text(
              exercise.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? fitColors["primary"] : Colors.black,
              ),
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor:
                        isDarkMode ? fitColors["darkBackground"] : Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder:
                        (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: SingleChildScrollView(
                            child: ModelSheet(exercise: exercise),
                          ),
                        ),
                  );
                },
                icon: const Icon(FontAwesomeIcons.plus, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ModelSheet extends StatefulWidget {
  final Exercise exercise;
  const ModelSheet({super.key, required this.exercise});

  @override
  _ModelSheetState createState() => _ModelSheetState();
}

class _ModelSheetState extends State<ModelSheet> {
  final List<TextEditingController> weightControllers = [];

  // Define colors for consistency
  final Map<String, Color> fitColors = {
    "primary": const Color(0xFF1E5128),
    "secondary": const Color(0xFF4E9F3D),
    "accent": const Color(0xFF8FB339),
    "light": const Color(0xFFD8E9A8),
    "dark": const Color(0xFF191A19),
    "black": Colors.black,
    "background": const Color(0xFFF5F5F5),
    "darkBackground": const Color(0xFF2A2A2A),
  };

  @override
  void initState() {
    super.initState();
    _addNewRow();
  }

  @override
  void dispose() {
    for (var controller in weightControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewRow() {
    final controller = TextEditingController();
    controller.addListener(() => setState(() {}));
    setState(() => weightControllers.add(controller));
  }

  void _removeRow(int index) {
    if (weightControllers.length > 1) {
      setState(() {
        weightControllers[index].dispose();
        weightControllers.removeAt(index);
      });
    }
  }

  bool get _hasEmptyFields =>
      weightControllers.any((controller) => controller.text.isEmpty);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add sets for ${widget.exercise.name}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(weightControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: weightControllers[index],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Weight ${index + 1}',
                            labelStyle: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    isDarkMode ? Colors.white70 : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: fitColors["primary"]!,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.red),
                        onPressed: () => _removeRow(index),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed:
                        _hasEmptyFields
                            ? null
                            : () {
                              final weights =
                                  weightControllers
                                      .map((controller) => controller.text)
                                      .toList();
                              context.read<ExerciseCubit>().addWorkoutData(
                                WorkoutData(
                                  exercise: widget.exercise,
                                  weights: weights,
                                ),
                              );
                              Navigator.pop(context);
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _hasEmptyFields ? Colors.grey : fitColors["primary"],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Add Exercise'),
                  ),
                  ElevatedButton(
                    onPressed: _addNewRow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode ? fitColors["secondary"] : Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Add Row'),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }
}
