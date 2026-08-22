import 'package:get/get.dart';
import '../screen/splash_screen.dart';
import '../screen/landing_screen.dart';
import '../screen/auth/login_screen.dart';
import '../screen/auth/register_screen.dart';
import '../screen/home/home_screen.dart';
import '../screen/home/task_list_screen.dart';
import '../screen/home/task_stats_screen.dart';
import '../screen/home/profile_screen.dart';
import '../bindings/app_binding.dart';
import '../bindings/task_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: AppRoutes.landing,
      page: () => const LandingScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: AppBinding(),
    ),
    GetPage(
      name: AppRoutes.tasks,
      page: () => const TaskListScreen(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: AppRoutes.taskStats,
      page: () => const TaskStatsScreen(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: AppBinding(),
    ),
  ];
}