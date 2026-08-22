class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000/api';
  // For physical device: 'http://192.168.1.x:3000/api'

  // Auth endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authProfile = '/auth/profile';
  static const String authRefresh = '/auth/refresh';
  static const String authVerify = '/auth/verify';
  static const String authLogout = '/auth/logout';

  // User endpoints
  static const String users = '/users';
  static const String usersStats = '/users/stats/dashboard';

  // Task endpoints
  static const String tasks = '/tasks';
  static const String tasksStats = '/tasks/stats/dashboard';
  static const String tasksBatch = '/tasks/batch';
  static const String tasksStatus = '/tasks/status';
}