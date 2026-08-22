import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'access_token';

  // Get headers with token
  Future<Map<String, String>> getHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Set token
  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Clear token
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Handle response
  dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Something went wrong');
    }
  }

  // GET request
  Future<dynamic> get(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      headers: headers,
    );
    return handleResponse(response);
  }

  // POST request
  Future<dynamic> post(String endpoint, {dynamic body}) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return handleResponse(response);
  }

  // PUT request
  Future<dynamic> put(String endpoint, {dynamic body}) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return handleResponse(response);
  }

  // PATCH request
  Future<dynamic> patch(String endpoint, {dynamic body}) async {
    final headers = await getHeaders();
    final response = await http.patch(
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return handleResponse(response);
  }

  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
      headers: headers,
    );
    return handleResponse(response);
  }
}