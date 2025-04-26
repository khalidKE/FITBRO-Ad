import 'package:FitBro/view/menu/menu_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:FitBro/common/color_extension.dart';
import 'package:FitBro/models/blocs/cubit/mealcubit.dart';
import 'package:FitBro/models/data/data.dart';
import 'package:FitBro/models/repos/data_repo.dart';
import 'package:FitBro/screens/mealdetalis.dart';

class MealPlanView2 extends StatelessWidget {
  const MealPlanView2({super.key});

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

    return BlocProvider(
      create: (context) => MealCubit(DataRepo())..fetchMeals(),
      child: ValueListenableBuilder<bool>(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Scaffold(
            backgroundColor:
                isDarkMode
                    ? fitColors["darkBackground"]
                    : fitColors["background"],
            appBar: AppBar(
              title: Text(
                "Recommended Meals",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: TColor.primary,
              elevation: 0,
              centerTitle: true,
            ),
            body: BlocBuilder<MealCubit, MealState>(
              builder: (context, state) {
                return state.when(
                  loading:
                      () => Center(
                        child: CircularProgressIndicator(color: TColor.primary),
                      ),
                  loaded: (data) {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder:
                          (context, index) => MealCard(meal: data[index]),
                    );
                  },
                  error:
                      (message) => Center(
                        child: Text(
                          "Error: $message",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final Meal meal;
  const MealCard({super.key, required this.meal});

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
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealDetailView(meal: meal),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.network(
                          meal.image_url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color:
                                  isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey.shade300,
                              height: 220,
                              width: double.infinity,
                              child: Icon(
                                Icons.error,
                                color:
                                    isDarkMode ? Colors.white70 : Colors.white,
                                size: 50,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                color: TColor.primary,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calories',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              meal.calories.toString(),
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meal.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : TColor.secondaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "A delicious and nutritious meal to keep you energized.",
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.white70
                            : TColor.secondaryText.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : TColor.primary.withOpacity(0.2),
                  thickness: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
