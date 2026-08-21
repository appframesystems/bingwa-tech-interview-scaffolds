
import 'package:get/get.dart';
import 'package:task_manager/presentation/controllers/task_controller.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TaskController());
  }
}