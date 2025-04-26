import 'package:FitBro/view/menu/menu_view.dart';
import 'package:flutter/material.dart';
import 'tips_details_view.dart';
import '../../common/color_extension.dart';
import '../../common_widget/tip_row.dart';

class TipsView extends StatefulWidget {
  const TipsView({super.key});

  @override
  State createState() => _TipsViewState();
}

class _TipsViewState extends State {
  final List<Map<String, String>> tipsArr = [
    {"name": "About Training"},
    {"name": "How to weight loss?"},
    {"name": "Introducing meal plan"},
    {"name": "Water and Food"},
    {"name": "Drink water"},
    {"name": "How many times a day to eat"},
    {"name": "Become stronger"},
    {"name": "Shoes for Training"},
    {"name": "Appeal Tips"},
  ];
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
  // Define colors for consistency final Map<String, Color> fitColors = { "primary": const Color(0xFF1E5128), "secondary": const Color(0xFF4E9F3D), "accent": const Color(0xFF8FB339), "light": const Color(0xFFD8E9A8), "dark": const Color(0xFF191A19), "black": Colors.black, "background": const Color(0xFFF5F5F5), "darkBackground": const Color(0xFF2A2A2A), };

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

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
            elevation: 0.1,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset(
                "assets/img/black_white.png",
                width: 25,
                height: 25,
              ),
            ),
            title: const Text(
              "Tips",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemBuilder: (context, index) {
              var tObj = tipsArr[index];
              return TipRow(
                tObj: tObj,
                isActive: index == 0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TipsDetailView(tObj: tObj),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                color:
                    isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black26,
                height: 1,
              );
            },
            itemCount: tipsArr.length,
          ),
        );
      },
    );
  }
}
