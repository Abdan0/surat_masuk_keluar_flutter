import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:surat_masuk_keluar_flutter/core/constants/api_constants.dart';
import 'package:surat_masuk_keluar_flutter/data/models/disposisi.dart';
import 'package:surat_masuk_keluar_flutter/data/models/notifikasi.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;

class NotifikasiService {
  static const notifikasiURL = '$apiURL/notifikasi';

  // Get token dari storage
  static Future<String> getToken() async {
    try {
      final token = await UserService.getToken();
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      throw Exception('Token tidak ditemukan');
    }
  }

  // Mendapatkan semua notifikasi untuk user yang login
  static Future<List<Notifikasi>> getNotifikasiUser() async {
    try {
      print('🔍 Mengambil data notifikasi...');
      final token = await UserService.getToken();
      
      if (token.isEmpty) {
        print('⚠️ Token kosong, tidak dapat mengambil notifikasi');
        return [];
      }
      
      // Tambahkan log token untuk debugging
      print('🔑 Token untuk notifikasi: ${token.length > 20 ? token.substring(0, 20) + '...' : token}');
      
      // Dapatkan user ID untuk logging
      final userId = await UserService.getUserId();
      print('👤 Mengambil notifikasi untuk user ID: $userId');
      
      final response = await http.get(
        Uri.parse('$notifikasiURL'), // URL endpoint notifikasi
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body.substring(0, min(100, response.body.length))}...');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['data'] != null) {
          final List<dynamic> notifikasiData = responseData['data'];
          print('📢 Mendapatkan ${notifikasiData.length} notifikasi dari API');
          
          if (notifikasiData.isEmpty) {
            print('⚠️ Daftar notifikasi kosong dari server');
            return [];
          }
          
          try {
            final notifikasiList = notifikasiData
                .map((data) => Notifikasi.fromJson(data))
                .toList();
            print('✅ Berhasil mem-parsing ${notifikasiList.length} notifikasi');
            
            // Log detail notifikasi untuk debugging
            for (var notif in notifikasiList) {
              print('📣 Notif: ${notif.id} - ${notif.judul} - Tipe: ${notif.tipe}');
            }
            
            return notifikasiList;
          } catch (parseError) {
            print('❌ Error parsing notifikasi: $parseError');
            return [];
          }
        } else {
          print('⚠️ Tidak ada field data dalam respons');
          return [];
        }
      } else {
        print('❌ Error response: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Gagal mendapatkan notifikasi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      return []; // Return empty list instead of throwing
    }
  }

  // Membuat notifikasi baru untuk disposisi
  static Future<Notifikasi> createDisposisiNotifikasi({
    required int userId,
    required String pengirimName,
    required Disposisi disposisi,
  }) async {
    try {
      print('🔔 Membuat notifikasi disposisi...');
      final token = await getToken();
      
      // Buat objek notifikasi terlebih dahulu
      final notifikasi = Notifikasi.forNewDisposisi(
        userId: userId,
        pengirimNama: pengirimName,
        disposisi: disposisi,
      );
      
      final response = await http.post(
        Uri.parse(notifikasiURL),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode(notifikasi.toJson()),
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final createdNotifikasi = Notifikasi.fromJson(responseData['data']);
          print('✅ Berhasil membuat notifikasi: ${createdNotifikasi.id}');
          return createdNotifikasi;
        } else {
          throw Exception('Format response tidak valid: missing data field');
        }
      } else {
        throw Exception('Gagal membuat notifikasi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating notifikasi: $e');
      throw Exception('Gagal membuat notifikasi: $e');
    }
  }

  // Menandai notifikasi sebagai dibaca
  static Future<Notifikasi> markAsRead(int notifikasiId) async {
    try {
      print('👁️ Menandai notifikasi sebagai dibaca...');
      final token = await getToken();
      
      final response = await http.put(
        Uri.parse('$notifikasiURL/$notifikasiId/read'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final updatedNotifikasi = Notifikasi.fromJson(responseData['data']);
          print('✅ Berhasil menandai notifikasi sebagai dibaca');
          return updatedNotifikasi;
        } else {
          throw Exception('Format response tidak valid: missing data field');
        }
      } else {
        throw Exception('Gagal memperbarui notifikasi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating notifikasi: $e');
      throw Exception('Gagal memperbarui notifikasi: $e');
    }
  }

  // Menghitung jumlah notifikasi yang belum dibaca
  static Future<int> getUnreadCount() async {
    try {
      final notifikasiList = await getNotifikasiUser();
      final unreadCount = notifikasiList.where((n) => !n.dibaca).length;
      return unreadCount;
    } catch (e) {
      print('❌ Error counting unread notifications: $e');
      return 0;
    }
  }

  // Mendapatkan notifikasi dummy untuk fallback
  static List<Notifikasi> getDummyNotifications() {
    final now = DateTime.now();
    return [
      Notifikasi(
        id: 1,
        userId: 1,
        judul: 'Contoh Notifikasi #1',
        pesan: 'Ini adalah contoh notifikasi ketika API tidak tersedia.',
        tipe: 'info',
        dibaca: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Notifikasi(
        id: 2,
        userId: 1,
        judul: 'Contoh Disposisi',
        pesan: 'Contoh notifikasi disposisi baru.',
        tipe: 'disposisi',
        referenceId: 1,
        dibaca: true,
        createdAt: now.subtract(const Duration(days: 1)),
        readAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }
}