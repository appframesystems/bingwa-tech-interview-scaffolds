import 'package:get/get.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositoryimpl/auth_repository_impl.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepositoryImpl();

  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    isLoading.value = true;
    try {
      final loggedIn = await _authRepository.isLoggedIn();
      if (loggedIn) {
        final user = await _authRepository.getStoredUser();
        if (user != null) {
          currentUser.value = user;
          isAuthenticated.value = true;
        } else {
          // Try to fetch from API
          try {
            final freshUser = await _authRepository.getCurrentUser();
            currentUser.value = freshUser;
            isAuthenticated.value = true;
          } catch (e) {
            await _authRepository.logout();
            isAuthenticated.value = false;
          }
        }
      } else {
        isAuthenticated.value = false;
      }
    } catch (e) {
      error.value = e.toString();
      isAuthenticated.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      final authData = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      currentUser.value = authData.user;
      isAuthenticated.value = true;
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      final authData = await _authRepository.login(
        email: email,
        password: password,
      );
      currentUser.value = authData.user;
      isAuthenticated.value = true;
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authRepository.logout();
      currentUser.value = null;
      isAuthenticated.value = false;
      Get.offAllNamed(AppRoutes.landing);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh user
  Future<void> refreshUser() async {
    if (!isAuthenticated.value) return;
    try {
      final user = await _authRepository.getCurrentUser();
      currentUser.value = user;
    } catch (e) {
      error.value = e.toString();
    }
  }

  void clearError() {
    error.value = '';
  }
}