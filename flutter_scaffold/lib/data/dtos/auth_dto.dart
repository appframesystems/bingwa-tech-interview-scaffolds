import '../../domain/entities/user.dart';
import '../../domain/entities/auth_response.dart';

class AuthResponseDto {
  final String accessToken;
  final Map<String, dynamic> user;

  AuthResponseDto({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] ?? '',
      user: json['user'] ?? {},
    );
  }

  AuthResponse toDomain() {
    return AuthResponse(
      accessToken: accessToken,
      user: User(
        id: user['id'] ?? '',
        name: user['name'] ?? '',
        email: user['email'] ?? '',
        role: user['role'] ?? 'USER',
        isActive: user['isActive'] ?? true,
        createdAt: user['createdAt'] != null
            ? DateTime.parse(user['createdAt'])
            : DateTime.now(),
        updatedAt: user['updatedAt'] != null
            ? DateTime.parse(user['updatedAt'])
            : DateTime.now(),
      ),
    );
  }
}