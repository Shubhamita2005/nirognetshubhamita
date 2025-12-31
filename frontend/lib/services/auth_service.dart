import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:5000';
  final _storage = const FlutterSecureStorage();

  String _cleanToken(String token) {
    return token.trim().replaceAll('\n', '').replaceAll('\r', '');
  }

  Future<String> login(String email, String password) async {
    print('🔵 [AUTH_SERVICE] login() started');
    print('🔵 [AUTH_SERVICE] Email: $email');
    print('🔵 [AUTH_SERVICE] URL: $baseUrl/api/login');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('📡 [AUTH_SERVICE] Status code: ${response.statusCode}');
      print('📡 [AUTH_SERVICE] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['access_token'];

        token = _cleanToken(token);

        print('✅ [AUTH_SERVICE] Token received (length: ${token.length})');

        await _storage.write(key: 'access_token', value: token);
        print('✅ [AUTH_SERVICE] Token saved to storage');

        final savedToken = await _storage.read(key: 'access_token');
        if (savedToken != null) {
          print('✅ [AUTH_SERVICE] Token verified in storage');
        }

        return token;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print('❌ [AUTH_SERVICE] Login exception: $e');
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    print('🔵 [AUTH_SERVICE] register() started');

    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('📡 [AUTH_SERVICE] Register status: ${response.statusCode}');

    if (response.statusCode != 201) {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    print('🔵 [AUTH_SERVICE] getProfile() started');
    token = _cleanToken(token);

    final response = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📡 [AUTH_SERVICE] Profile status: ${response.statusCode}');
    print('📡 [AUTH_SERVICE] Profile response: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - please login again');
    } else if (response.statusCode == 422) {
      throw Exception('Invalid token format');
    } else {
      throw Exception('Failed to fetch profile: ${response.body}');
    }
  }

  Future<void> updateProfile(
    String token,
    Map<String, dynamic> updatedData,
  ) async {
    print('🔵 [AUTH_SERVICE] updateProfile() called');
    print('🔵 [AUTH_SERVICE] Data: $updatedData');

    token = _cleanToken(token);

    final response = await http.put(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    print('📡 [AUTH_SERVICE] Update status: ${response.statusCode}');
    print('📡 [AUTH_SERVICE] Update response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }

    print('✅ [AUTH_SERVICE] Profile updated successfully');
  }

  /// UPDATE HEALTH INFO
  Future<void> updateHealthInfo(
    String token,
    Map<String, dynamic> healthData,
  ) async {
    print('🔵 [AUTH_SERVICE] updateHealthInfo() called');
    print('🔵 [AUTH_SERVICE] Health data: $healthData');

    token = _cleanToken(token);

    final response = await http.put(
      Uri.parse('$baseUrl/api/profile/health'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(healthData),
    );

    print('📡 [AUTH_SERVICE] Health update status: ${response.statusCode}');
    print('📡 [AUTH_SERVICE] Health update response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update health info: ${response.body}');
    }

    print('✅ [AUTH_SERVICE] Health info updated successfully');
  }

  Future<String?> getToken() async {
    print('🔍 [AUTH_SERVICE] getToken() called');
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      print('✅ [AUTH_SERVICE] Token found');
    } else {
      print('❌ [AUTH_SERVICE] No token found');
    }
    return token;
  }

  Future<bool> isLoggedIn() async {
    print('🔍 [AUTH_SERVICE] isLoggedIn() called');
    final token = await _storage.read(key: 'access_token');
    final loggedIn = token != null && token.isNotEmpty;
    print('🔍 [AUTH_SERVICE] isLoggedIn: $loggedIn');
    return loggedIn;
  }

  Future<void> logout() async {
    print('🔴 [AUTH_SERVICE] logout() called');
    await _storage.delete(key: 'access_token');
    print('✅ [AUTH_SERVICE] Token deleted');
  }

  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    print('🔵 [AUTH_SERVICE] getCurrentUserProfile() called');
    final token = await getToken();

    if (token == null) {
      throw Exception('No token found - user not logged in');
    }

    return await getProfile(token);
  }

  Future<void> updateCurrentUserProfile(
    Map<String, dynamic> updatedData,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found - user not logged in');
    }
    return await updateProfile(token, updatedData);
  }
}
