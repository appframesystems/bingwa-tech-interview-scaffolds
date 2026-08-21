
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/presentation/bindings/app_binding.dart';
import 'package:task_manager/presentation/routes/app_pages.dart';
import 'package:task_manager/presentation/routes/app_routes.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.tasks,
      getPages: AppPages.pages,
      initialBinding: AppBinding(),
      debugShowCheckedModeBanner: false,
    );
  }
}