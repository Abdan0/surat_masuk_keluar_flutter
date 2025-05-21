import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:surat_masuk_keluar_flutter/core/constants/api_constants.dart';
import 'package:surat_masuk_keluar_flutter/data/models/disposisi.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
// Ganti import AuthService dengan UserService yang dibuat sebagai library functions
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;

class DisposisiService {
  static const disposisiURL = '$apiURL/disposisi';

  // Get token dari storage - Menggunakan UserService alih-alih AuthService
  static Future<String> getToken() async {
    try {
      final token = await UserService.getToken();
      // UserService.getToken() sudah mengembalikan 'Bearer token', jadi tidak perlu ditambahkan lagi
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      throw Exception('Token tidak ditemukan');
    }
  }

  // Mendapatkan semua data disposisi
  static Future<List<Disposisi>> getDisposisiList() async {
    try {
      print('🔍 Mengambil data disposisi...');
      final token = await getToken();
      
      // Tambahkan parameter untuk include relasi
      final response = await http.get(
        Uri.parse('$disposisiURL?include=surat,dariUser,kepadaUser'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('📄 Response body (first 100 chars): ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');
        
        // Bersihkan respons dari PHP notices jika ada
        final cleanedBody = _cleanResponse(response.body);
        
        final Map<String, dynamic> responseData = json.decode(cleanedBody);
        if (responseData['data'] != null) {
          final List<dynamic> disposisiData = responseData['data'];
          final disposisiList = disposisiData
              .map((data) => Disposisi.fromJson(data))
              .toList();
          print('✅ Berhasil mengambil ${disposisiList.length} disposisi');
          return disposisiList;
        } else {
          throw Exception('Format response tidak valid: missing data field');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Session telah habis');
      } else {
        throw Exception('Gagal mendapatkan data disposisi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting disposisi list: $e');
      throw Exception('Gagal mendapatkan data disposisi: $e');
    }
  }

  // Helper untuk membersihkan response dari PHP notices
  static String _cleanResponse(String response) {
    final jsonStart = response.indexOf('{');
    if (jsonStart > 0) {
      return response.substring(jsonStart);
    }
    return response;
  }

  // Mendapatkan detail disposisi berdasarkan ID
  static Future<Disposisi> getDisposisiById(int id) async {
    try {
      print('🔍 Mengambil detail disposisi id: $id...');
      final token = await getToken();
      final response = await http.get(
        // Tambahkan parameter include relasi
        Uri.parse('$disposisiURL/$id?include=surat,dariUser,kepadaUser'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final cleanedBody = _cleanResponse(response.body);
        final Map<String, dynamic> responseData = json.decode(cleanedBody);
        if (responseData['data'] != null) {
          final disposisi = Disposisi.fromJson(responseData['data']);
          print('✅ Berhasil mengambil detail disposisi');
          return disposisi;
        } else {
          throw Exception('Format response tidak valid: missing data field');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Disposisi tidak ditemukan');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Session telah habis');
      } else {
        throw Exception('Gagal mendapatkan detail disposisi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting disposisi detail: $e');
      throw Exception('Gagal mendapatkan detail disposisi: $e');
    }
  }

  // Membuat disposisi baru
  static Future<Disposisi> createDisposisi(Disposisi disposisi) async {
    try {
      print('📝 Membuat disposisi baru...');
      print('📄 Data: Surat ID=${disposisi.suratId}, Dari=${disposisi.dariUserId}, Kepada=${disposisi.kepadaUserId}');
      
      final token = await getToken();
      
      final response = await http.post(
        Uri.parse(disposisiURL),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode({
          'surat_id': disposisi.suratId,
          'dari_user_id': disposisi.dariUserId,
          'kepada_user_id': disposisi.kepadaUserId,
          'instruksi': disposisi.instruksi,
          'status': disposisi.status,
          'tanggal_disposisi': DateFormat('yyyy-MM-dd').format(disposisi.tanggalDisposisi),
        }),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body.substring(0, min(100, response.body.length))}...');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final cleanedBody = _cleanResponse(response.body);
        
        final Map<String, dynamic> responseData = json.decode(cleanedBody);
        if (responseData['data'] != null) {
          final createdDisposisi = Disposisi.fromJson(responseData['data']);
          print('✅ Berhasil membuat disposisi: ${createdDisposisi.id}');
          return createdDisposisi;
        } else {
          throw Exception('Format response tidak valid: missing data field');
        }
      } else if (response.statusCode == 401) {
        print('⚠️ Unauthorized: Session telah habis');
        throw Exception('Unauthorized: Session telah habis');
      } else if (response.statusCode == 422) {
        // Validasi error
        final errorData = json.decode(response.body);
        final errorMsg = errorData['message'] ?? 'Validation error';
        print('⚠️ Validation error: $errorMsg');
        throw Exception('Validasi data gagal: $errorMsg');
      } else {
        print('⚠️ Gagal membuat disposisi: ${response.statusCode}');
        throw Exception('Gagal membuat disposisi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating disposisi: $e');
      throw Exception('Gagal membuat disposisi: $e');
    }
  }

  // Mengupdate disposisi
  static Future<Disposisi> updateDisposisi(int id, Map<String, dynamic> data) async {
    try {
      print('🔄 Mengupdate disposisi id: $id...');
      final token = await getToken();
      
      final response = await http.put(  // Ubah dari patch ke put untuk kompatibilitas dengan Laravel
        Uri.parse('$disposisiURL/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
        body: json.encode(data),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final cleanedBody = _cleanResponse(response.body);
        final Map<String, dynamic> responseData = json.decode(cleanedBody);
        if (responseData['data'] != null) {
          final updatedDisposisi = Disposisi.fromJson(responseData['data']);
          print('✅ Disposisi berhasil diupdate');
          return updatedDisposisi;
        } else {
          throw Exception('Format response tidak valid: missing data field');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Disposisi tidak ditemukan');
      } else if (response.statusCode == 422) {
        final cleanedBody = _cleanResponse(response.body);
        final Map<String, dynamic> errorData = json.decode(cleanedBody);
        throw Exception('Validasi gagal: ${errorData['message'] ?? "Unknown validation error"}');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Session telah habis');
      } else {
        throw Exception('Gagal mengupdate disposisi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating disposisi: $e');
      throw Exception('Gagal mengupdate disposisi: $e');
    }
  }

  // Menghapus disposisi
  static Future<bool> deleteDisposisi(int id) async {
    try {
      print('🗑️ Menghapus disposisi id: $id...');
      final token = await getToken();
      
      final response = await http.delete(
        Uri.parse('$disposisiURL/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Disposisi berhasil dihapus');
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Disposisi tidak ditemukan');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Session telah habis');
      } else {
        throw Exception('Gagal menghapus disposisi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting disposisi: $e');
      throw Exception('Gagal menghapus disposisi: $e');
    }
  }

  // Mendapatkan disposisi berdasarkan surat ID
  static Future<List<Disposisi>> getDisposisiBySuratId(int suratId) async {
    try {
      print('🔍 Mengambil disposisi untuk surat id: $suratId...');
      
      // Gunakan endpoint khusus jika tersedia di API
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$apiURL/surat/$suratId/disposisi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final cleanedBody = _cleanResponse(response.body);
        final Map<String, dynamic> responseData = json.decode(cleanedBody);
        if (responseData['data'] != null) {
          final List<dynamic> disposisiData = responseData['data'];
          final filteredList = disposisiData
              .map((data) => Disposisi.fromJson(data))
              .toList();
          print('✅ Berhasil mendapatkan ${filteredList.length} disposisi untuk surat id: $suratId');
          return filteredList;
        } else {
          throw Exception('Format response tidak valid: missing data field');
        }
      } else if (response.statusCode == 404) {
        // Endpoint khusus tidak tersedia, fallback ke filter manual
        print('⚠️ Endpoint khusus tidak tersedia, mencoba filter manual...');
        final disposisiList = await getDisposisiList();
        final filteredList = disposisiList.where((item) => item.suratId == suratId).toList();
        print('✅ Berhasil mendapatkan ${filteredList.length} disposisi untuk surat id: $suratId (filter manual)');
        return filteredList;
      } else {
        print('⚠️ Respons error: ${response.statusCode}, mencoba filter manual...');
        final disposisiList = await getDisposisiList();
        final filteredList = disposisiList.where((item) => item.suratId == suratId).toList();
        print('✅ Berhasil mendapatkan ${filteredList.length} disposisi untuk surat id: $suratId (filter manual)');
        return filteredList;
      }
    } catch (e) {
      print('❌ Error getting disposisi by surat id: $e');
      print('⚠️ Mencoba mendapatkan semua disposisi dan filter secara manual...');
      
      try {
        final disposisiList = await getDisposisiList();
        final filteredList = disposisiList.where((item) => item.suratId == suratId).toList();
        print('✅ Berhasil mendapatkan ${filteredList.length} disposisi untuk surat id: $suratId (filter manual)');
        return filteredList;
      } catch (fallbackError) {
        print('❌ Gagal fallback: $fallbackError');
        throw Exception('Gagal mendapatkan disposisi untuk surat: $e');
      }
    }
  }

  // Mendapatkan disposisi untuk user tertentu (sebagai penerima)
  static Future<List<Disposisi>> getDisposisiByKepadaUserId(int userId) async {
    try {
      print('🔍 Mengambil disposisi untuk kepada user id: $userId...');
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$disposisiURL?kepada_user_id=$userId&include=surat,dariUser,kepadaUser'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final cleanedBody = _cleanResponse(response.body);
        final Map<String, dynamic> responseData = json.decode(cleanedBody);
        if (responseData['data'] != null) {
          final List<dynamic> disposisiData = responseData['data'];
          final filteredList = disposisiData
              .map((data) => Disposisi.fromJson(data))
              .toList();
          print('✅ Berhasil mendapatkan ${filteredList.length} disposisi untuk kepada user id: $userId');
          return filteredList;
        } else {
          // Fallback ke filter manual
          final disposisiList = await getDisposisiList();
          final filteredList = disposisiList.where((item) => item.kepadaUserId == userId).toList();
          print('✅ Berhasil mendapatkan ${filteredList.length} disposisi untuk kepada user id: $userId (filter manual)');
          return filteredList;
        }
      } else {
        // Fallback ke filter manual
        final disposisiList = await getDisposisiList();
        final filteredList = disposisiList.where((item) => item.kepadaUserId == userId).toList();
        print('✅ Berhasil mendapatkan ${filteredList.length} disposisi untuk kepada user id: $userId (filter manual)');
        return filteredList;
      }
    } catch (e) {
      print('❌ Error getting disposisi by kepada user id: $e');
      throw Exception('Gagal mendapatkan disposisi untuk user: $e');
    }
  }

  // Mendapatkan disposisi yang dibuat oleh user tertentu
  static Future<List<Disposisi>> getDisposisiByDariUserId(int userId) async {
    try {
      print('🔍 Mengambil disposisi dari user id: $userId...');
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$disposisiURL?dari_user_id=$userId&include=surat,dariUser,kepadaUser'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final cleanedBody = _cleanResponse(response.body);
        final Map<String, dynamic> responseData = json.decode(cleanedBody);
        if (responseData['data'] != null) {
          final List<dynamic> disposisiData = responseData['data'];
          final filteredList = disposisiData
              .map((data) => Disposisi.fromJson(data))
              .toList();
          print('✅ Berhasil mendapatkan ${filteredList.length} disposisi dari user id: $userId');
          return filteredList;
        } else {
          // Fallback ke filter manual
          final disposisiList = await getDisposisiList();
          final filteredList = disposisiList.where((item) => item.dariUserId == userId).toList();
          print('✅ Berhasil mendapatkan ${filteredList.length} disposisi dari user id: $userId (filter manual)');
          return filteredList;
        }
      } else {
        // Fallback ke filter manual
        final disposisiList = await getDisposisiList();
        final filteredList = disposisiList.where((item) => item.dariUserId == userId).toList();
        print('✅ Berhasil mendapatkan ${filteredList.length} disposisi dari user id: $userId (filter manual)');
        return filteredList;
      }
    } catch (e) {
      print('❌ Error getting disposisi by dari user id: $e');
      throw Exception('Gagal mendapatkan disposisi dari user: $e');
    }
  }

  // Mengubah status disposisi
  static Future<Disposisi> updateStatusDisposisi(int id, String status) async {
    try {
      print('🔄 Mengubah status disposisi id: $id menjadi $status...');
      return await updateDisposisi(id, {'status': status});
    } catch (e) {
      print('❌ Error updating disposisi status: $e');
      throw Exception('Gagal mengubah status disposisi: $e');
    }
  }

  // Mendapatkan daftar user untuk dropdown
  static Future<List<User>> getUsersForDropdown() async {
    try {
      print('🔍 Mengambil data users untuk dropdown...');
      final token = await getToken();
      print('🔐 Token: ${token.length > 10 ? token.substring(0, 10) + '...' : token}');
      
      // Ubah endpoint dari 'user-profile' ke 'users'
      final response = await http.get(
        Uri.parse('$apiURL/users'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body.substring(0, min(100, response.body.length))}...');
      
      if (response.statusCode == 200) {
        final cleanedBody = _cleanResponse(response.body);
        
        try {
          final Map<String, dynamic> responseData = json.decode(cleanedBody);
          
          // Cek apakah data ada di respons
          if (responseData['data'] != null) {
            final List<dynamic> userData = responseData['data'];
            final userList = userData
                .map((data) => User.fromJson(data))
                .toList();
            print('✅ Berhasil mengambil ${userList.length} users');
            print('👤 Users: ${userList.map((u) => "${u.id}: ${u.name}").join(', ')}');
            return userList;
          } else {
            // Jika tidak ada field 'data', coba periksa apakah respons adalah array langsung
            if (responseData is List) {
              final userList = (responseData as List)
                  .map((data) => User.fromJson(data))
                  .toList();
              print('✅ Berhasil mengambil ${userList.length} users (dari array)');
              return userList;
            }
            
            // Jika responseData adalah Map yang berisi array users
            if (responseData['users'] != null && responseData['users'] is List) {
              final List<dynamic> userData = responseData['users'];
              final userList = userData
                  .map((data) => User.fromJson(data))
                  .toList();
              print('✅ Berhasil mengambil ${userList.length} users (dari field users)');
              return userList;
            }
            
            // Fallback - coba gunakan keseluruhan respons sebagai objek user tunggal
            // Ini untuk mendukung endpoint 'user-profile' jika tidak ada endpoint 'users'
            if (responseData['id'] != null && responseData['name'] != null) {
              final currentUser = User.fromJson(responseData);
              print('⚠️ Hanya mendapatkan current user: ${currentUser.name}');
              return [currentUser];
            }
            
            print('⚠️ Format response tidak valid: missing data field');
            print('⚠️ Response data format: ${responseData.keys.join(', ')}');
            
            // Buat daftar pengguna dummy sementara agar UI tetap berfungsi
            print('⚠️ Membuat daftar pengguna dummy untuk sementara');
            return [
              User(id: 1, name: "Admin", role: "admin"),
              User(id: 2, name: "Dekan", role: "dekan"),
              User(id: 3, name: "Wakil Dekan", role: "wakil_dekan"),
              User(id: 4, name: "Staff 1", role: "staff"),
              User(id: 5, name: "Staff 2", role: "staff")
            ];
          }
        } catch (parseError) {
          print('❌ Error parsing JSON: $parseError');
          throw Exception('Format respons tidak valid: $parseError');
        }
      } else if (response.statusCode == 401) {
        print('⚠️ Unauthorized: Session telah habis');
        throw Exception('Unauthorized: Session telah habis');
      } else {
        print('⚠️ Gagal mendapatkan data users: ${response.statusCode}');
        throw Exception('Gagal mendapatkan data users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting users list: $e');
      throw Exception('Gagal mendapatkan data users: $e');
    }
  }

  // Tambahkan method untuk mendukung disposisi surat keluar

  // Get disposisi surat keluar
  static Future<List<Disposisi>> getDisposisiSuratKeluar() async {
    try {
      print('🔍 Mengambil data disposisi surat keluar...');
      final token = await getToken();
      
      final response = await http.get(
        Uri.parse('$disposisiURL/keluar?include=surat,dariUser,kepadaUser'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final cleanedBody = _cleanResponse(response.body);
        
        final Map<String, dynamic> responseData = json.decode(cleanedBody);
        if (responseData['data'] != null) {
          final List<dynamic> disposisiData = responseData['data'];
          final disposisiList = disposisiData
              .map((data) => Disposisi.fromJson(data))
              .toList();
          print('✅ Berhasil mengambil ${disposisiList.length} disposisi surat keluar');
          return disposisiList;
        } else {
          throw Exception('Format response tidak valid: missing data field');
        }
      } else {
        throw Exception('Gagal mendapatkan data disposisi surat keluar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting disposisi surat keluar: $e');
      throw Exception('Gagal mendapatkan data disposisi surat keluar: $e');
    }
  }
}