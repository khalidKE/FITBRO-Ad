import 'dart:ui';
import 'package:FitBro/config/admob_config.dart';
import 'package:FitBro/models/blocs/cubit/StoreCubit/srore_cubit.dart';
import 'package:FitBro/view/menu/yoga_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../common/color_extension.dart';
import '../../common_widget/plan_row.dart';
import '../../screens/ExerciseHistoryScreen/ExerciseHistoryScreen.dart';
import '../../screens/presets.dart';
import '../exercise/exercise_view_2.dart';
import '../meal_plan/meal_plan_view_2.dart';
import '../tips/tips_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../services/ad_service.dart';

// Use ValueNotifiers for theme and notification state
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);
final ValueNotifier<bool> isReminderOnNotifier = ValueNotifier<bool>(false);

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController;
  int _currentPage = 0;
  final AdService _adService = AdService();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

  final List<Map<String, dynamic>> carouselItems = [
    {"image": "assets/img/1.png", "subtitle": "Stay fit and healthy"},
    {"image": "assets/img/2.png", "subtitle": "Boost your endurance"},
    {"image": "assets/img/3.png", "subtitle": "Build muscle power"},
    {"image": "assets/img/5.png", "subtitle": "Improve your range of motion"},
  ];

  List planArr = [
    {
      "name": "Support",
      "icon": "assets/img/menu_support.png",
      "right_icon": "",
      "color": 0xFF4E9F3D,
    },
    {
      "name": "Settings",
      "icon": "assets/img/menu_settings.png",
      "right_icon": "",
      "color": 0xFF1E5128,
    },
    {
      "name": "Terms and Conditions",
      "icon": "assets/img/information.png",
      "right_icon": "",
      "color": 0xFF1E5128,
    },
  ];

  List menuArr = [
    {
      "name": "Workout",
      "image": "assets/img/strength.png",
      "tag": "2",
      "color": 0xFF1E5128,
    },
    {
      "name": "Meal Plan",
      "image": "assets/img/menu_meal_plan.png",
      "tag": "5",
      "color": 0xFF1E5128,
    },
    {
      "name": "Exercises",
      "image": "assets/img/menu_running.png",
      "tag": "8",
      "color": 0xFF1E5128,
    },
    {
      "name": "Tips",
      "image": "assets/img/menu_tips.png",
      "tag": "9",
      "color": 0xFF1E5128,
    },
    {
      "name": "Yoga",
      "image": "assets/img/yoga.png",
      "tag": "1",
      "right_icon": "",
      "color": 0xFF1E5128,
    },
    {
      "name": "History",
      "image": "assets/img/time-wall-clock.png",
      "tag": "12",
      "color": 0xFF1E5128,
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);

    _startCarouselTimer();
    _loadSettings();
    _initializeNotifications();

    // Initialize ads and set up listener
    _adService.initialize();
    _setupAdListener();
  }

  void _setupAdListener() {
    // Add listener to rebuild when ad status changes
    _adService.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _adService.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleTrainingReminder(bool isOn) async {
    if (isOn) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Time to Train!',
        'Don\'t forget your workout today. Stay consistent!',
        _nextInstanceOf8AM(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'training_reminder_channel',
            'Training Reminders',
            channelDescription: 'Daily reminders for your training sessions',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF1E5128),
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: fitColors["primary"],
          content: const Text(
            'Training reminders enabled.\n You will receive daily notifications.',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: fitColors["primary"],
          content: const Text(
            'Training reminders disabled.',
            style: TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  tz.TZDateTime _nextInstanceOf8AM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      8,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkModeNotifier.value = prefs.getBool('isDarkMode') ?? false;
    isReminderOnNotifier.value = prefs.getBool('isReminderOn') ?? false;
  }

  Future<void> _saveThemeSetting(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    isDarkModeNotifier.value = isDark;
  }

  Future<void> _saveReminderSetting(bool isOn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isReminderOn', isOn);
    isReminderOnNotifier.value = isOn;
    await _scheduleTrainingReminder(isOn);
  }

  void _startCarouselTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        if (_currentPage < carouselItems.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );

        _startCarouselTimer();
      }
    });
  }

  Widget _buildMenuItem(Map mObj, int index) {
    final double delay = (index / menuArr.length) * 0.5;
    final Animation<double> animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(delay, 1.0, curve: Curves.easeOut),
    );

    Color itemColor = Color(mObj["color"] ?? 0xFF1E5128);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.6 + (0.4 * animation.value),
          child: Opacity(
            opacity: animation.value,
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDarkModeNotifier.value
                        ? fitColors["darkBackground"]
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: itemColor.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.lightImpact();

                    // Check if drawer is open and close it if needed
                    if (Scaffold.of(context).isDrawerOpen) {
                      Navigator.pop(context);
                    }

                    // Handle menu item tap
                    _handleMenuItemTap(mObj["tag"].toString());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: itemColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            mObj["image"] ?? "",
                            width: 30,
                            height: 30,
                            color: itemColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          mObj["name"] ?? "",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Tap to view",
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarouselItem(int index, BuildContext context) {
    final item = carouselItems[index];

    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width * 0.6,
          child: Hero(
            tag: "carousel_${item["subtitle"]}",
            child: Image.asset(
              item["image"],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  isDarkModeNotifier.value
                      ? fitColors["darkBackground"]!.withOpacity(0.7)
                      : fitColors["dark"]!.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["subtitle"],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        carouselItems.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _currentPage == index
                    ? fitColors["secondary"]
                    : fitColors["light"],
          ),
        ),
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color:
                  isDarkModeNotifier.value
                      ? fitColors["darkBackground"]
                      : Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkModeNotifier.value
                                ? Colors.white
                                : fitColors["dark"],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color:
                            isDarkModeNotifier.value
                                ? Colors.white
                                : fitColors["dark"],
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome to FIT BRO! Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use our app.",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.9)
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "1. Information We Collect",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Email Address:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.9)
                                    : fitColors["dark"],
                          ),
                        ),
                        Text(
                          "To use FIT BRO, we require you to sign in using your email address. This helps us authenticate users and provide access to personalized features.",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.8)
                                    : fitColors["dark"]!.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          "We do not collect any additional personal information such as name, phone number, location, or health-related data.",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.8)
                                    : fitColors["dark"]!.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "2. How We Use Your Information",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "We use your email address to:",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.9)
                                    : fitColors["dark"],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "• Authenticate your identity and manage user access",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkModeNotifier.value
                                          ? Colors.white.withOpacity(0.8)
                                          : fitColors["dark"]!.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                "• Communicate important app-related updates or changes",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkModeNotifier.value
                                          ? Colors.white.withOpacity(0.8)
                                          : fitColors["dark"]!.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                "• Maintain the security and functionality of the app",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkModeNotifier.value
                                          ? Colors.white.withOpacity(0.8)
                                          : fitColors["dark"]!.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "3. Data Sharing and Disclosure",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "We do not sell, rent, or share your personal information with third parties for marketing purposes. Your information may only be shared:",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.9)
                                    : fitColors["dark"],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "• To comply with legal obligations",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkModeNotifier.value
                                          ? Colors.white.withOpacity(0.8)
                                          : fitColors["dark"]!.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                "• To enforce our Terms of Service",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkModeNotifier.value
                                          ? Colors.white.withOpacity(0.8)
                                          : fitColors["dark"]!.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                "• To protect the rights, privacy, safety, or property of FIT BRO or others",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDarkModeNotifier.value
                                          ? Colors.white.withOpacity(0.8)
                                          : fitColors["dark"]!.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "4. Data Retention",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "We retain your email address only as long as your account is active or as needed to provide our services. You may request deletion of your account and associated data by contacting us at the email provided below.",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.8)
                                    : fitColors["dark"]!.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "5. Security",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "We take reasonable measures to protect your information from unauthorized access, alteration, or destruction. However, no internet-based service is completely secure.",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.8)
                                    : fitColors["dark"]?.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "6. Children's Privacy",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "FIT BRO is not directed at children under the age of 13. We do not knowingly collect personal data from children. If we learn we have collected such information, we will delete it promptly.",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.8)
                                    : fitColors["dark"]!.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "7. Changes to This Policy",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "We may update this Privacy Policy from time to time. We will notify you of any changes by updating the \"Effective Date\" at the top of this page. Continued use of the app after changes constitutes acceptance of the updated policy.",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.8)
                                    : fitColors["dark"]!.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "8. Contact Us",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "If you have any questions or concerns about this Privacy Policy, you may contact us at:",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkModeNotifier.value
                                    ? Colors.white.withOpacity(0.9)
                                    : fitColors["dark"],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Email: abuelhassan179@gmail.com",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: fitColors["primary"],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fitColors["primary"],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "I Understand",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsView() {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor:
              isDarkMode ? fitColors["darkBackground"] : Colors.white,
          appBar: AppBar(
            backgroundColor: fitColors["primary"],
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              "Settings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? fitColors["darkBackground"] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Appearance",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : fitColors["dark"],
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isDarkModeNotifier,
                      builder: (context, isDarkModeValue, child) {
                        return ListTile(
                          title: Text(
                            "Dark Mode",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDarkModeValue
                                      ? Colors.white
                                      : fitColors["dark"],
                            ),
                          ),
                          trailing: Switch(
                            value: isDarkModeValue,
                            activeColor: fitColors["primary"],
                            onChanged: (value) async {
                              await _saveThemeSetting(value);
                            },
                          ),
                          subtitle: Text(
                            "Toggle between light and dark theme",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkModeValue
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? fitColors["darkBackground"] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : fitColors["dark"],
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isReminderOnNotifier,
                      builder: (context, isReminderOn, child) {
                        return ListTile(
                          title: Text(
                            "Training Reminders",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDarkMode ? Colors.white : fitColors["dark"],
                            ),
                          ),
                          trailing: Switch(
                            value: isReminderOn,
                            activeColor: fitColors["primary"],
                            onChanged: (value) async {
                              await _saveReminderSetting(value);
                            },
                          ),
                          subtitle: Text(
                            "Receive daily reminders for your workouts",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? fitColors["darkBackground"] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? fitColors["darkBackground"] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/img/icon.png", width: 80, height: 80),
                    const SizedBox(height: 10),
                    Text(
                      "FIT BRO",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: fitColors["primary"],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDarkMode
                                ? Colors.white.withOpacity(0.7)
                                : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "© 2025 FIT BRO. All rights reserved.",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDarkMode
                                ? Colors.white.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerAd() {
    if (!_adService.isBannerAdLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 60,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: _adService.bannerWidth,
        height: _adService.bannerHeight,
        alignment: Alignment.center,
        child: _adService.getBannerAd(),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    if (!_adService.isAnyAdShowing) {
      _adService.showInterstitialAd();
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _handleMenuItemTap(String tag) {
    HapticFeedback.lightImpact();

    // Use Builder to get the correct context
    Builder(
      builder: (BuildContext context) {
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
        return const SizedBox.shrink();
      },
    );

    switch (tag) {
      case "2":
        _navigateToScreen(const WorkoutPicker());
        break;
      case "5":
        _navigateToScreen(const MealPlanView2());
        break;
      case "8":
        _navigateToScreen(const ExerciseView2());
        break;
      case "9":
        _navigateToScreen(const TipsView());
        break;
      case "1":
        _navigateToScreen(const YogaView());
        break;
      case "12":
        _navigateToScreen(
          BlocProvider(
            create: (context) => SaveCubit(),
            child: const ExerciseHistoryScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor:
              isDarkMode ? fitColors["darkBackground"] : Colors.white,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: Drawer(
            width: media.width,
            backgroundColor: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5),
              child: Stack(
                children: [
                  Container(
                    width: media.width * 0.78,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? fitColors["darkBackground"]
                              : TColor.white,
                      boxShadow: [
                        BoxShadow(
                          color: fitColors["dark"]!.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(5, 0),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Column(
                          children: [
                            SizedBox(
                              height: kTextTabBarHeight,
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22.5),
                                      border: Border.all(
                                        color: fitColors["secondary"]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22.5),
                                      child: Image.asset(
                                        "assets/img/u1.png",
                                        width: 45,
                                        height: 45,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      "Menu",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: fitColors["primary"],
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Divider(color: fitColors["light"], height: 1),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                itemCount: planArr.length,
                                itemBuilder: (context, index) {
                                  var itemObj = planArr[index] as Map? ?? {};
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: PlanRow(
                                      mObj: itemObj,
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.pop(context);

                                        switch (itemObj["name"]) {
                                          case "Settings":
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        _buildSettingsView(),
                                              ),
                                            );
                                            break;
                                          case "Terms and Conditions":
                                            _showTermsAndConditions();
                                            break;
                                          case "Support":
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor:
                                                    fitColors["primary"],
                                                content: const Text(
                                                  'Contact us at: abuelhassan179@gmail.com',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                duration: const Duration(
                                                  seconds: 5,
                                                ),
                                                action: SnackBarAction(
                                                  label: 'OK',
                                                  textColor: Colors.white,
                                                  onPressed: () {},
                                                ),
                                              ),
                                            );
                                            break;
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: kToolbarHeight - 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.asset(
                                "assets/img/meun_close.png",
                                width: 25,
                                height: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: media.width * 0.6,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: carouselItems.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildCarouselItem(index, context);
                      },
                    ),
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: 54,
                              decoration: BoxDecoration(
                                color: TColor.white,
                                borderRadius: BorderRadius.circular(27),
                                border: Border.all(
                                  color: fitColors["secondary"]!,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.asset(
                                  "assets/img/u1.png",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Welcome",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: TColor.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Let's get fit!",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: TColor.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      left: 0,
                      right: 0,
                      child: _buildIndicator(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? fitColors["darkBackground"] : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Fitness Menu",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : fitColors["dark"],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: fitColors["secondary"]!.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "View All",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: fitColors["secondary"],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: GridView.builder(
                            key: const ValueKey('menu_grid'),
                            padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.9,
                                ),
                            itemCount: menuArr.length,
                            itemBuilder: ((context, index) {
                              var mObj = menuArr[index] as Map? ?? {};
                              return _buildMenuItem(mObj, index);
                            }),
                          ),
                        ),
                      ),
                      // Only show banner when ad is loaded
                      if (_adService.isBannerAdLoaded) _buildBannerAd(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 35),
            ],
          ),
        );
      },
    );
  }
}
