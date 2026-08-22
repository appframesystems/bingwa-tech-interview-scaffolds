import '../entities/user.dart';
import '../entities/auth_response.dart';

abstract class AuthRepository {
  // Register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  });

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  // Get current user
  Future<User> getCurrentUser();

  // Logout
  Future<void> logout();

  // Get stored user
  Future<User?> getStoredUser();

  // Check if logged in
  Future<bool> isLoggedIn();

  // Save auth data
  Future<void> saveAuthData(AuthResponse authData);
}