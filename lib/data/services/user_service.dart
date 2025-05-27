// Login
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'dart:math' as Math;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surat_masuk_keluar_flutter/core/constants/api_constants.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';

// Model untuk API response
class ApiResponse {
  Object? data;
  String? error;
}

// Mendapatkan token yang tersimpan
Future<String> getToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    print('Attempting to get token from SharedPreferences');
    
    // Cek semua kemungkinan kunci token yang tersimpan
    String? token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      token = prefs.getString('token');
    }
    
    // Pastikan token memiliki format yang benar (Bearer prefix)
    if (token != null && token.isNotEmpty) {
      if (!token.startsWith('Bearer ')) {
        token = 'Bearer $token';
      }
      print('Token retrieved successfully: ${token.substring(0, Math.min(20, token.length))}...');
      return token;
    }
    
    print('⚠️ No token found in SharedPreferences');
    return '';
  } catch (e) {
    print('❌ Error getting token: $e');
    return '';
  }
}

// Refresh token jika sudah kedaluwarsa
Future<bool> refreshToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    final currentToken = prefs.getString('auth_token') ?? '';
    
    print('🔄 Attempting to refresh token...');
    print('🔑 Current token: ${currentToken.length > 20 ? currentToken.substring(0, 20) + '...' : currentToken}');
    
    if (refreshToken == null || refreshToken.isEmpty) {
      print('❌ No refresh token available');
      
      // Jika tidak ada refresh token tapi masih ada access token, coba gunakan token yang ada
      if (currentToken.isNotEmpty) {
        print('⚠️ No refresh token, but access token exists. Continuing with current token.');
        return true;
      }
      
      return false;
    }
    
    final response = await http.post(
      Uri.parse('$apiURL/refresh-token'), // Sesuaikan dengan endpoint refresh token API Anda
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );
    
    print('📊 Refresh token response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final newToken = responseData['access_token'];
      final newRefreshToken = responseData['refresh_token']; // Jika API mengembalikan refresh token baru
      
      if (newToken != null) {
        await prefs.setString('auth_token', 'Bearer $newToken');
        print('✅ Access token refreshed successfully');
        
        // Simpan refresh token baru jika ada
        if (newRefreshToken != null) {
          await prefs.setString('refresh_token', newRefreshToken);
          print('✅ Refresh token updated');
        }
        
        return true;
      }
    }
    
    print('❌ Failed to refresh token: ${response.statusCode}');
    return false;
  } catch (e) {
    print('❌ Error refreshing token: $e');
    return false;
  }
}

// Token interceptor untuk menangani 401 Unauthorized
Future<http.Response> authorizedRequest(
  Future<http.Response> Function() requestFunction
) async {
  try {
    var response = await requestFunction();
    
    // Jika token expired, coba refresh dan coba lagi
    if (response.statusCode == 401) {
      print('⚠️ Token expired, attempting to refresh...');
      final refreshed = await refreshToken();
      
      if (refreshed) {
        // Coba lagi request dengan token baru
        response = await requestFunction();
      } else {
        // Jika refresh gagal, logout user
        await logout();
      }
    }
    
    return response;
  } catch (e) {
    rethrow;
  }
}

// Get user ID from token
Future<int> getUserId() async {
  try {
    print('🔍 Mencoba mendapatkan User ID...');
    final prefs = await SharedPreferences.getInstance();
    
    // Coba ambil dari SharedPreferences
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      if (userData != null && userData['id'] != null) {
        final userId = int.tryParse(userData['id'].toString()) ?? 0;
        print('✅ User ID dari SharedPreferences: $userId');
        if (userId > 0) {
          return userId;
        }
      }
    }
    
    // Jika tidak ada di SharedPreferences, coba ambil dari token JWT
    final token = await getToken();
    if (token.isNotEmpty) {
      // Extract payload from JWT token (format: "Bearer eyJ...")
      try {
        final jwt = token.startsWith('Bearer ') ? token.substring(7) : token;
        final parts = jwt.split('.');
        if (parts.length == 3) {
          // Decode base64 payload
          final payload = parts[1];
          final normalized = base64.normalize(payload);
          final decoded = utf8.decode(base64.decode(normalized));
          final payloadData = json.decode(decoded);
          
          // JWT biasanya menyimpan user ID di field 'sub'
          if (payloadData['sub'] != null) {
            final userId = int.tryParse(payloadData['sub'].toString()) ?? 0;
            print('✅ User ID dari JWT token: $userId');
            
            // Simpan user ID untuk penggunaan di masa depan
            if (userId > 0) {
              await saveUserId(userId);
              return userId;
            }
          }
        }
      } catch (e) {
          print('❌ Error decoding JWT: $e');
      }
        
      // Jika gagal ekstrak dari token, coba api /user
      try {
        print('🔍 Mengambil user data dari API...');
        final response = await http.get(
          Uri.parse('$apiURL/user'),
          headers: {
            'Accept': 'application/json',
            'Authorization': token,
          },
        );
        
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['data'] != null && responseData['data']['id'] != null) {
            final userId = int.tryParse(responseData['data']['id'].toString()) ?? 0;
            print('✅ User ID dari API: $userId');
            
            // Simpan user data untuk penggunaan di masa depan
            if (userId > 0) {
              await prefs.setString('user_data', json.encode(responseData['data']));
              return userId;
            }
          }
        } else {
          print('❌ API response error: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error getting user from API: $e');
      }
    }
    
    // Jika masih tidak dapat mendapatkan user ID yang valid, coba dari fallback
    final fallbackId = await _getFallbackUserId();
    if (fallbackId > 0) {
      return fallbackId;
    }
    
    print('❌ User ID not found in storage or API');
    throw Exception('User ID tidak ditemukan. Silakan login kembali.');
  } catch (e) {
    print('❌ Error getting user ID: $e');
    throw Exception('Gagal mendapatkan User ID: $e');
  }
}

// Fungsi untuk menyimpan user ID
Future<void> saveUserId(int userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    print('✅ User ID $userId disimpan ke SharedPreferences');
  } catch (e) {
    print('❌ Error saving user ID: $e');
  }
}

// Fungsi untuk mencoba mendapatkan user ID dari fallback storage
Future<int> _getFallbackUserId() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    if (userId > 0) {
      print('✅ User ID dari fallback storage: $userId');
      return userId;
    }
    
    // Jika masih tidak ada, coba ambil dari cache lain
    final cachedId = prefs.getString('cached_user_id');
    if (cachedId != null) {
      final userId = int.tryParse(cachedId) ?? 0;
      if (userId > 0) {
        print('✅ User ID dari cache lain: $userId');
        return userId;
      }
    }
    
    return 0;
  } catch (e) {
    print('❌ Error getting fallback user ID: $e');
    return 0;
  }
}

// Login function
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

      // Simpan token dengan format dan kunci yang konsisten
      final token = responseData['token'];
      print('Token from response: $token');

      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final bearerToken = 'Bearer $token';

        // Simpan token dengan kedua kunci untuk kompatibilitas
        await prefs.setString('auth_token', bearerToken);
        await prefs.setString('token', bearerToken);
        print('Token saved to SharedPreferences with both keys');

        // Verifikasi token tersimpan
        final verifyToken = await getToken();
        print('Verified token from getToken(): ${verifyToken.length > 20 ? verifyToken.substring(0, 20) + '...' : verifyToken}');

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

// Fungsi untuk menyimpan data user setelah login
Future<bool> saveUserData(Map<String, dynamic> userData, String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Simpan token
    await prefs.setString('auth_token', 'Bearer $token');
    
    // Simpan user data
    await prefs.setString('user_data', json.encode(userData));
    
    print('✅ User data and token saved successfully');
    return true;
  } catch (e) {
    print('❌ Error saving user data: $e');
    return false;
  }
}

// Fungsi untuk logout
Future<bool> logout() async {
  try {
    // Hapus token dan user data dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Hapus semua token dan data login
    await prefs.remove('token');
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('user_id');
    
    // Hapus juga kredensial Remember Me
    await prefs.remove('saved_nidn');
    await prefs.remove('saved_password');
    await prefs.setBool('remember_me', false);
    
    // Panggil endpoint logout di API jika perlu
    try {
      final token = await getToken();
      if (token.isNotEmpty) {
        await http.post(
          Uri.parse('$apiURL/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': token,
          },
        );
      }
    } catch (apiError) {
      print('⚠️ API logout error: $apiError');
      // Tetap mengembalikan true meskipun API error,
      // karena data lokal sudah dibersihkan
    }
    
    print('✅ Logout berhasil, semua kredensial dihapus');
    return true;
  } catch (e) {
    print('❌ Error during logout: $e');
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

// Menyegarkan data user dari API
Future<User?> refreshUserData() async {
  try {
    final token = await getToken();
    if (token.isEmpty) {
      print('❌ Token not available for user data refresh');
      return null;
    }
    
    // Debug token untuk membantu diagnosa masalah
    print('🔑 Token format check: ${token.substring(0, 20)}...');
    print('🔄 Refreshing user data from API...');
    
    // Coba endpoint /user terlebih dahulu
    final endpoint = '$apiURL/user';
    print('🔗 Trying endpoint: $endpoint');
    
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Accept': 'application/json',
        'Authorization': token,
      },
    );
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['data'] != null) {
        // Simpan user data di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(responseData['data']));
        
        print('✅ User data refreshed successfully');
        // Return User object
        return User.fromJson(responseData['data']);
      }
    } else if (response.statusCode == 404) {
      // Jika endpoint tidak ditemukan, coba alternatif
      print('⚠️ Endpoint /user not found, trying /me endpoint...');
      
      // Coba endpoint /me sebagai alternatif
      final altEndpoint = '$apiURL/me';
      print('🔗 Trying alternative endpoint: $altEndpoint');
      
      final altResponse = await http.get(
        Uri.parse(altEndpoint),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );
      
      if (altResponse.statusCode == 200) {
        final responseData = json.decode(altResponse.body);
        if (responseData['data'] != null) {
          // Simpan user data di SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', json.encode(responseData['data']));
          
          print('✅ User data refreshed successfully from alternative endpoint');
          // Return User object
          return User.fromJson(responseData['data']);
        }
      } else {
        print('❌ Failed to refresh user data from alternative endpoint: ${altResponse.statusCode} - ${altResponse.body}');
        
        // Jika gagal mendapatkan data terbaru, gunakan data tersimpan
        return await getUserData();
      }
    } else {
      print('❌ Failed to refresh user data: ${response.statusCode} - ${response.body}');
      
      // Jika gagal mendapatkan data terbaru, gunakan data tersimpan
      return await getUserData();
    }
    
    // Jika tidak ada data yang berhasil diambil, ambil dari data login
    print('⚠️ Attempting to get data from stored login information...');
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final role = prefs.getString('role');
    final userId = prefs.getInt('userId');
    final nidn = prefs.getString('nidn');
    
    if (name != null && name.isNotEmpty) {
      print('✅ Created user from stored preferences');
      return User(
        id: userId,
        name: name,
        role: role,
        nidn: nidn,
      );
    }
    
    return null;
  } catch (e) {
    print('❌ Error refreshing user data: $e');
    return null;
  }
}

// Mendapatkan data user dari penyimpanan lokal
Future<User?> getUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Cek apakah user data tersimpan di SharedPreferences
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      // Parse JSON to User object
      final userData = json.decode(userDataString);
      print('✅ User data retrieved from SharedPreferences');
      return User.fromJson(userData);
    }
    
    // Jika tidak ada data user di SharedPreferences, cek data login terpisah
    final name = prefs.getString('name');
    final role = prefs.getString('role');
    final userId = prefs.getInt('userId');
    final nidn = prefs.getString('nidn');
    
    if (name != null && name.isNotEmpty) {
      print('✅ Created user from stored login preferences');
      return User(
        id: userId,
        name: name,
        role: role,
        nidn: nidn,
      );
    }
    
    // Jika tidak ada data tersimpan, coba refresh dari API
    print('⚠️ No stored user data, attempting to refresh...');
    return await refreshUserData();
  } catch (e) {
    print('❌ Error getting user data: $e');
    return null;
  }
}

// Fungsi fallback untuk mendapatkan data user minimal dari SharedPreferences
Future<User?> getSimpleUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final role = prefs.getString('role');
    final userId = prefs.getInt('userId');
    final nidn = prefs.getString('nidn');
    
    if (name != null && name.isNotEmpty) {
      print('✅ Created minimal user object from preferences');
      return User(
        id: userId,
        name: name,
        role: role,
        nidn: nidn,
      );
    }
    
    return null;
  } catch (e) {
    print('❌ Error getting simple user data: $e');
    return null;
  }
}

// Mendapatkan daftar semua pengguna (admin only)
Future<List<User>> getAllUsers() async {
  try {
    final token = await getToken();
    if (token.isEmpty) {
      throw Exception('Unauthorized: Token tidak tersedia');
    }
    
    print('🔍 Mengambil daftar pengguna...');
    
    final response = await http.get(
      Uri.parse('$apiURL/users'),
      headers: {
        'Accept': 'application/json',
        'Authorization': token,
      },
    );
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      if (responseData['data'] != null && responseData['data'] is List) {
        final List<dynamic> userData = responseData['data'];
        final userList = userData.map((data) => User.fromJson(data)).toList();
        print('✅ Berhasil mendapatkan ${userList.length} pengguna');
        return userList;
      } else {
        throw Exception('Format response tidak valid');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Session telah habis');
    } else {
      throw Exception('Gagal mendapatkan daftar pengguna: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error getting users list: $e');
    throw Exception('Gagal mengambil daftar pengguna: $e');
  }
}

// Membuat pengguna baru (admin only)
Future<User> createUser(User user, String password) async {
  try {
    final token = await getToken();
    if (token.isEmpty) {
      throw Exception('Unauthorized: Token tidak tersedia');
    }
    
    print('📝 Membuat pengguna baru: ${user.name}');
    
    final response = await http.post(
      Uri.parse('$apiURL/users'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: json.encode({
        'name': user.name,
        'nidn': user.nidn,
        'role': user.role,
        'password': password,
        'password_confirmation': password,
      }),
    );
    
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      
      if (responseData['data'] != null) {
        print('✅ Pengguna berhasil dibuat');
        return User.fromJson(responseData['data']);
      } else {
        throw Exception('Format response tidak valid');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Session telah habis');
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      final errorMsg = errorData['message'] ?? 'Validation error';
      throw Exception('Validasi gagal: $errorMsg');
    } else {
      throw Exception('Gagal membuat pengguna: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error creating user: $e');
    throw Exception('Gagal membuat pengguna: $e');
  }
}

// Mengupdate data pengguna (admin only)
Future<User> updateUser(User user, String? password) async {
  try {
    final token = await getToken();
    if (token.isEmpty) {
      throw Exception('Unauthorized: Token tidak tersedia');
    }
    
    if (user.id == null) {
      throw Exception('User ID tidak valid');
    }
    
    print('🔄 Memperbarui data pengguna ID: ${user.id}');
    
    // Siapkan data untuk update
    final Map<String, dynamic> userData = {
      'name': user.name,
      'nidn': user.nidn,
      'role': user.role,
      '_method': 'PUT',  // Untuk Laravel method spoofing
    };
    
    // Tambahkan password jika diubah
    if (password != null && password.isNotEmpty) {
      userData['password'] = password;
      userData['password_confirmation'] = password;
    }
    
    print('📦 Data yang akan diupdate: ${userData.toString()}');
    
    // Headers untuk request
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': token,
    };
    
    // Endpoint untuk update user berdasarkan API routes
    final updateUri = Uri.parse('$apiURL/users/${user.id}');
    print('🔗 URL Update: $updateUri');
    
    // Kirim request dengan POST + _method=PUT
    final response = await http.post(
      updateUri,
      headers: headers,
      body: json.encode(userData),
    );
    
    print('📡 Status response: ${response.statusCode}');
    
    // Jika endpoint pertama gagal, coba dengan endpoint alternatif
    if (response.statusCode == 404 || response.statusCode == 405) {
      print('⚠️ Endpoint pertama gagal, mencoba endpoint alternatif...');
      
      // Tambahkan user ID ke data
      userData['id'] = user.id;
      
      final alternativeUri = Uri.parse('$apiURL/update-user');
      print('🔗 URL Alternatif: $alternativeUri');
      
      final altResponse = await http.post(
        alternativeUri,
        headers: headers,
        body: json.encode(userData),
      );
      
      print('📡 Status response alternatif: ${altResponse.statusCode}');
      
      if (altResponse.statusCode == 200 || altResponse.statusCode == 201) {
        try {
          final responseData = json.decode(altResponse.body);
          if (responseData['data'] != null) {
            return User.fromJson(responseData['data']);
          } else if (responseData['user'] != null) {
            return User.fromJson(responseData['user']);
          } else {
            return user; // Return original user if response format is unexpected
          }
        } catch (e) {
          print('⚠️ Error parsing response: $e');
          return user; // Return original user on parsing error
        }
      }
    } else if (response.statusCode == 200 || response.statusCode == 201) {
      // Parse response untuk endpoint utama
      try {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return User.fromJson(responseData['data']);
        } else if (responseData['user'] != null) {
          return User.fromJson(responseData['user']);
        } else {
          return user; // Return original user if response format is unexpected
        }
      } catch (e) {
        print('⚠️ Error parsing response: $e');
        return user; // Return original user on parsing error
      }
    }
    
    // Jika semua endpoint gagal, kembalikan user dengan nilai yang diupdate
    print('⚠️ Update gagal di API, mengembalikan user dengan data yang diperbarui');
    return User(
      id: user.id,
      name: user.name,
      nidn: user.nidn,
      role: user.role
    );
    
  } catch (e) {
    print('❌ Error updating user: $e');
    throw Exception('Gagal memperbarui data pengguna: $e');
  }
}

// Menghapus pengguna (admin only)
Future<bool> deleteUser(int userId) async {
  try {
    final token = await getToken();
    if (token.isEmpty) {
      throw Exception('Unauthorized: Token tidak tersedia');
    }
    
    print('🗑️ Menghapus pengguna ID: $userId');
    
    // Headers untuk request
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': token,
    };
    
    // Endpoint untuk delete user
    final deleteUri = Uri.parse('$apiURL/users/$userId');
    print('🔗 URL Delete: $deleteUri');
    
    // Coba dengan metode DELETE standard
    final response = await http.delete(
      deleteUri,
      headers: headers,
    );
    
    print('📡 Status response delete: ${response.statusCode}');
    
    // Jika DELETE tidak berfungsi, coba dengan POST + _method=DELETE (Laravel method spoofing)
    if (response.statusCode == 404 || response.statusCode == 405) {
      print('⚠️ DELETE method gagal, mencoba dengan POST + _method=DELETE');
      
      final postDeleteUri = Uri.parse('$apiURL/users/$userId');
      final postResponse = await http.post(
        postDeleteUri,
        headers: headers,
        body: json.encode({
          '_method': 'DELETE'
        }),
      );
      
      print('📡 Status response POST delete: ${postResponse.statusCode}');
      
      if (postResponse.statusCode == 200) {
        print('✅ Pengguna berhasil dihapus (via POST)');
        return true;
      }
    } else if (response.statusCode == 200) {
      print('✅ Pengguna berhasil dihapus');
      return true;
    }
    
    // Jika semua metode gagal, periksa status error
    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Session telah habis');
    } else if (response.statusCode == 403) {
      throw Exception('Tidak diizinkan: Anda tidak memiliki hak untuk menghapus pengguna ini');
    } else if (response.statusCode == 404) {
      throw Exception('Pengguna tidak ditemukan');
    } else {
      throw Exception('Gagal menghapus pengguna: ${response.statusCode}');
    }
    
  } catch (e) {
    print('❌ Error deleting user: $e');
    throw Exception('Gagal menghapus pengguna: $e');
  }
}
