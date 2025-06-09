import 'package:FitBro/models/blocs/cubit/StoreCubit/srore_cubit.dart';
import 'package:FitBro/models/blocs/cubit/StoreCubit/srore_state.dart';
import 'package:FitBro/view/menu/menu_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../common/color_extension.dart';

class ExerciseHistoryScreen extends StatefulWidget {
  const ExerciseHistoryScreen({super.key});

  @override
  _ExerciseHistoryScreenState createState() => _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState extends State<ExerciseHistoryScreen> {
  // Define colors for consistency with MenuView
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
    // Fetch exercise history when the screen is initialized
    context.read<SaveCubit>().getUserExcersiceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor:
              isDarkMode
                  ? fitColors["darkBackground"]
                  : fitColors["background"],
          appBar: AppBar(
            title: Text(
              "Exercise History",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: TColor.primary,
          ),
          body: BlocBuilder<SaveCubit, StoreState>(
            builder: (context, state) {
              if (state is LoadingGetExcersiceInfo) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fitColors["primary"]!,
                    ),
                  ),
                );
              } else if (state is SuccessGetExcersiceInfo) {
                if (state.workoutSessions.isEmpty) {
                  return Center(
                    child: Text(
                      "No exercise history available.",
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.workoutSessions.length,
                  itemBuilder: (context, index) {
                    final workoutSession = state.workoutSessions[index];

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: isDarkMode ? fitColors["darkBackground"] : Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Session ${index + 1}: ${DateFormat('yMMMd').format(workoutSession.startTime)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: fitColors["primary"],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Start: ${DateFormat('jm').format(workoutSession.startTime)} - End: ${DateFormat('jm').format(workoutSession.finishTime)}",
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...workoutSession.workoutData.map((workoutData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDarkMode ? Colors.white24 : Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: workoutData.exercise.image,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              workoutData.exercise.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Muscles: ${workoutData.exercise.muscles.join(", ")}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              "Equipment: ${workoutData.exercise.equipment}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              "Weights: ${workoutData.weights.join(", ")}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: fitColors["primary"]!.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          workoutData.exercise.difficulty,
                                          style: TextStyle(
                                            color: fitColors["primary"],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is ErrorGetExcersiceInfo) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Error loading history: ${state.error}",
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.red[300] : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            () =>
                                context
                                    .read<SaveCubit>()
                                    .getUserExcersiceInfo(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: fitColors["primary"],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }
              return Center(
                child: Text(
                  "No exercise history available.",
                  style: TextStyle(
                    fontSize: 18,
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
