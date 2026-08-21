import 'package:get/get.dart';
import 'package:task_manager/data/repositoryimpl/local_task_repository_impl.dart';
import 'package:task_manager/data/services/shared_preference.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SharedPreference>(() {
      final sharedPreference = SharedPreference();
      sharedPreference.init();
      return sharedPreference;
    });
    
    Get.lazyPut<TaskRepository>(() => LocalTaskRepositoryImpl(Get.find()));
  }
}