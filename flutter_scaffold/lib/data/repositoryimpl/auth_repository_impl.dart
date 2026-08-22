import '../../domain/entities/user.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/api_client.dart';
import '../services/shared_preference.dart';
import '../dtos/auth_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SharedPreferenceService _prefs = SharedPreferenceService();

  static const String _userKey = 'user_data';

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response != null && response['data'] != null) {
      final authDto = AuthResponseDto.fromJson(response['data']);
      final authData = authDto.toDomain();
      await saveAuthData(authData);
      return authData;
    }
    throw Exception('Registration failed');
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post('/auth/login', body: {
      'email': email,
      'password': password,
    });

    if (response != null && response['data'] != null) {
      final authDto = AuthResponseDto.fromJson(response['data']);
      final authData = authDto.toDomain();
      await saveAuthData(authData);
      return authData;
    }
    throw Exception('Login failed');
  }

  @override
  Future<User> getCurrentUser() async {
    final response = await _apiClient.get('/auth/profile');
    if (response != null && response['data'] != null) {
      final userData = response['data'];
      return User(
        id: userData['id'] ?? '',
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        role: userData['role'] ?? 'USER',
        isActive: userData['isActive'] ?? true,
        createdAt: userData['createdAt'] != null
            ? DateTime.parse(userData['createdAt'])
            : DateTime.now(),
        updatedAt: userData['updatedAt'] != null
            ? DateTime.parse(userData['updatedAt'])
            : DateTime.now(),
      );
    }
    throw Exception('Failed to get user profile');
  }

  @override
  Future<void> logout() async {
    await _apiClient.clearToken();
    await _prefs.delete(_userKey);
  }

  @override
  Future<User?> getStoredUser() async {
    final userData = await _prefs.getObject(_userKey);
    if (userData != null) {
      return User(
        id: userData['id'] ?? '',
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        role: userData['role'] ?? 'USER',
        isActive: userData['isActive'] ?? true,
        createdAt: userData['createdAt'] != null
            ? DateTime.parse(userData['createdAt'])
            : DateTime.now(),
        updatedAt: userData['updatedAt'] != null
            ? DateTime.parse(userData['updatedAt'])
            : DateTime.now(),
      );
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveAuthData(AuthResponse authData) async {
    await _apiClient.setToken(authData.accessToken);
    await _prefs.saveObject(_userKey, {
      'id': authData.user.id,
      'name': authData.user.name,
      'email': authData.user.email,
      'role': authData.user.role,
      'isActive': authData.user.isActive,
      'createdAt': authData.user.createdAt.toIso8601String(),
      'updatedAt': authData.user.updatedAt.toIso8601String(),
    });
  }
}