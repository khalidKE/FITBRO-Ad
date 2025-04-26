import 'package:FitBro/view/menu/menu_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:FitBro/models/blocs/cubit/workoutcubit.dart';
import 'package:FitBro/view/workout/workout_detail_view.dart';
import '../../common/color_extension.dart';

class ExerciseView2 extends StatefulWidget {
  const ExerciseView2({super.key});

  @override
  State<ExerciseView2> createState() => _ExerciseView2State();
}

class _ExerciseView2State extends State<ExerciseView2> {
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
    "white": Colors.white,
  };

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, state) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkModeNotifier,
          builder: (context, isDarkMode, child) {
            return Scaffold(
              backgroundColor:
                  isDarkMode
                      ? fitColors["darkBackground"]
                      : fitColors["background"],
              appBar: AppBar(
                backgroundColor: TColor.primary,
                centerTitle: true,
                elevation: 4,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "assets/img/black_white.png",
                    width: 30,
                    height: 30,
                  ),
                ),
                title: Text(
                  "Exercises",
                  style: TextStyle(
                    color: TColor.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              body: state.when(
                loading:
                    () => Center(
                      child: CircularProgressIndicator(color: TColor.primary),
                    ),
                loaded:
                    (data) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MuscleTabs(muscles: muscles),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return ExerciseCard(
                                  exercise: data[index],
                                  media: media,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                error:
                    (message) => Center(
                      child: Text(
                        "Error: $message",
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? fitColors["white"]
                                  : fitColors["black"],
                          fontSize: 16,
                        ),
                      ),
                    ),
              ),
            );
          },
        );
      },
    );
  }
}

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.exercise, required this.media});

  final dynamic exercise;
  final Size media;

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
      "white": Colors.white,
    };

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDarkMode ? fitColors["darkBackground"] : TColor.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.2),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutDetailView(exercise: exercise),
                ),
              );
            },
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: exercise.image,
                      width: media.width,
                      height: media.width * 0.55,
                      fit: BoxFit.cover,
                      errorWidget:
                          (context, url, error) => Container(
                            width: media.width,
                            height: media.width * 0.55,
                            color:
                                isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey.shade300,
                            child: Icon(
                              Icons.error,
                              color: isDarkMode ? Colors.white70 : Colors.black,
                              size: 50,
                            ),
                          ),
                      placeholder:
                          (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: TColor.primary,
                            ),
                          ),
                    ),
                    Container(
                      width: media.width,
                      height: media.width * 0.55,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 60,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? fitColors["white"]
                                    : TColor.secondaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      WorkoutDetailView(exercise: exercise),
                            ),
                          );
                        },
                        icon: Image.asset(
                          "assets/img/more.png",
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CatagoriesBar extends StatelessWidget {
  final String name;
  final int index;
  final bool isSelected;
  const CatagoriesBar({
    super.key,
    required this.name,
    required this.index,
    required this.isSelected,
  });

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
      "white": Colors.white,
    };

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              context.read<ExerciseCubit>().setSelectedIndex(index);
            },
            child: Chip(
              label: Text(name),
              backgroundColor:
                  isSelected
                      ? fitColors["secondary"]
                      : (isDarkMode
                          ? Colors.grey[700]
                          : const Color(0xfff4caf50)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? fitColors["white"] : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class MuscleTabs extends StatelessWidget {
  const MuscleTabs({super.key, required this.muscles});

  final List<String> muscles;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<ExerciseCubit>().selectedIndex;
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: muscles.length,
        itemBuilder: (context, index) {
          return CatagoriesBar(
            name: muscles[index],
            index: index,
            isSelected: index == selectedIndex,
          );
        },
      ),
    );
  }
}
