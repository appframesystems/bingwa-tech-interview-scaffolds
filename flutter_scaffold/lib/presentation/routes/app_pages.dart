
import 'package:get/get.dart';
import 'package:task_manager/presentation/bindings/task_binding.dart';
import 'package:task_manager/presentation/routes/app_routes.dart';
import 'package:task_manager/presentation/screen/task_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.tasks,
      page: () => const TaskScreen(),
      binding: TaskBinding(),
    ),
  ];
}