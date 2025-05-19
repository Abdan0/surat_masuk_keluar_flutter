// Login
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surat_masuk_keluar_flutter/core/constants/api_constants.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';

// Model untuk API response
class ApiResponse {
  Object? data;
  String? error;
}

// Get token
Future<String> getToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('Attempting to get token from SharedPreferences');
    print('Retrieved token: $token');

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan');
    }

    return token;
  } catch (e) {
    print('Error getting token: $e');
    throw Exception('Token tidak ditemukan');
  }
}

// Get user id
Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId');
}

// Login
Future<ApiResponse> login(String nidn, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    print('Attempting login for NIDN: $nidn');

    final loginResponse = await http.post(
      Uri.parse(loginURL),
      headers: {'Accept': 'application/json'},
      body: {'nidn': nidn, 'password': password},
    );

    print('Login Response Status: ${loginResponse.statusCode}');
    print('Login Response Raw Body: ${loginResponse.body}');

    if (loginResponse.statusCode == 200) {
      final responseData = jsonDecode(loginResponse.body);

      // Simpan token
      final token = responseData['token'];
      print('Token from response: $token');

      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final bearerToken = 'Bearer $token';

        // Simpan token
        await prefs.setString('token', bearerToken);
        print('Token saved to SharedPreferences: $bearerToken');

        // Verifikasi token tersimpan
        final verifyToken = prefs.getString('token');
        print('Verified token in SharedPreferences: $verifyToken');

        // Langsung gunakan data dari respons login jika tersedia
        // atau buat request baru untuk mendapatkan profil user jika tidak tersedia
        User user;

        // Coba cari data user di respons login
        if (responseData['user'] != null) {
          print('User data found in login response');
          user = User.fromJson(responseData['user']);
          user.token = bearerToken;
        } else {
          print('User data not found in login response, fetching from profile endpoint');
          // Dapatkan data user dari endpoint profile
          final profileResponse = await http.get(
            Uri.parse(profileURL),
            headers: {
              'Accept': 'application/json',
              'Authorization': bearerToken,
            },
          );

          print('Profile Response Status: ${profileResponse.statusCode}');
          print('Profile Response Body: ${profileResponse.body}');

          if (profileResponse.statusCode == 200) {
            final userData = jsonDecode(profileResponse.body);
            user = User.fromJson(userData);
            user.token = bearerToken;
          } else {
            throw Exception('Gagal mendapatkan data user: ${profileResponse.statusCode}');
          }
        }

        // Simpan data user di SharedPreferences
        await prefs.setString('name', user.name ?? '');
        await prefs.setString('nidn', user.nidn ?? '');
        await prefs.setString('role', user.role ?? '');
        await prefs.setInt('userId', user.id ?? 0);
        
        apiResponse.data = user;
        print('User data saved successfully: ${user.name}');
      } else {
        throw Exception('Token tidak ditemukan dalam response');
      }
    } else {
      final responseBody = jsonDecode(loginResponse.body);
      throw Exception(responseBody['error'] ?? 'Login gagal');
    }
  } catch (e) {
    print('Error during login: $e');
    apiResponse.error = e.toString().replaceAll('Exception: ', '');
  }
  return apiResponse;
}

// Tambahkan fungsi untuk verifikasi token
Future<bool> verifyToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print('No token found in storage');
      return false;
    }

    // Coba akses endpoint yang memerlukan otentikasi
    final response = await http.get(
      Uri.parse('$baseURL/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': token,
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Error verifying token: $e');
    return false;
  }
}

// Register
Future<ApiResponse> register(String name, String nidn, String role, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    print('Registering user:');
    print('Name: $name');
    print('NIDN: $nidn');
    print('Role: $role');

    final response = await http.post(
      Uri.parse(registerURL),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'nidn': nidn,
        'role': role,
        'password': password,
        'password_confirmation': password
      },
    );

    print('Register Response Status: ${response.statusCode}');
    print('Register Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        apiResponse.data = User.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } else {
      final errors = jsonDecode(response.body);
      if (errors['message'] != null) {
        apiResponse.error = errors['message'];
      } else {
        apiResponse.error = somethingWentWrong;
      }
    }
  } catch (e) {
    print('Error during registration: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Get User Detail
Future<ApiResponse> getUserDetail() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(
      Uri.parse(profileURL),
      headers: {'Accept': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      apiResponse.data = User.fromJson(responseData);
    } else if (response.statusCode == 401) {
      apiResponse.error = unauthorized;
    } else {
      apiResponse.error = somethingWentWrong;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// Logout
Future<bool> logout() async {
  try {
    String token = await getToken();
    final response = await http.post(
      Uri.parse(logoutURL),
      headers: {'Accept': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    }
    return false;
  } catch (e) {
    print('Error during logout: $e');
    return false;
  }
}

// Fungsi untuk mengecek status login
Future<bool> isLoggedIn() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  } catch (e) {
    print('Error checking login status: $e');
    return false;
  }
}
