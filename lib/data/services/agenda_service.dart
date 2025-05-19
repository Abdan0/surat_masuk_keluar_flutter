import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surat_masuk_keluar_flutter/core/constants/api_constants.dart';
import 'package:surat_masuk_keluar_flutter/data/models/agenda.dart';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';

class AgendaService {
  // Ubah URL endpoint mengikuti API Laravel
  static const agendaURL = '$apiURL/agenda'; // Pastikan sesuai dengan routes Laravel
  
  // Debugging helper
  static void _logApiCall(String method, String url, int? statusCode, String? responseBody) {
    print('🌐 API $method: $url');
    if (statusCode != null) {
      print('📊 Status: $statusCode');
    }
    if (responseBody != null) {
      print('📄 Response: ${responseBody.length > 100 ? '${responseBody.substring(0, 100)}...' : responseBody}');
    }
  }

  // Mendapatkan token dari SharedPreferences
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return 'Bearer $token';
  }

  // Mengambil daftar semua agenda dengan error handling yang lebih baik
  static Future<List<Agenda>> getAgendaList() async {
    try {
      _logApiCall('GET', agendaURL, null, null);
      
      final token = await getToken();
      final response = await http.get(
        Uri.parse(agendaURL),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      _logApiCall('GET', agendaURL, response.statusCode, response.body);

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          
          if (responseData['data'] != null && responseData['data'] is List) {
            final List<dynamic> agendaList = responseData['data'];
            print('✅ Berhasil mendapatkan ${agendaList.length} agenda');
            return agendaList.map((json) => Agenda.fromJson(json)).toList();
          } else {
            print('⚠️ Data agenda kosong atau bukan list');
            return [];
          }
        } catch (parseError) {
          print('❌ Error parsing JSON: $parseError');
          throw Exception('Format data tidak valid: $parseError');
        }
      } else if (response.statusCode == 401) {
        print('🔒 Error 401: Unauthorized');
        throw Exception('Unauthorized: Session telah habis');
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Gagal mengambil data agenda (${response.statusCode})');
      }
    } catch (e) {
      print('💥 Exception: $e');
      throw Exception('Error: $e');
    }
  }

  // Mendapatkan detail agenda dengan error handling yang lebih baik
  static Future<Agenda> getAgendaDetail(int id) async {
    try {
      final url = '$agendaURL/$id';
      _logApiCall('GET', url, null, null);
      
      final token = await getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      _logApiCall('GET', url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          
          if (responseData['data'] != null) {
            return Agenda.fromJson(responseData['data']);
          } else {
            throw Exception('Data agenda tidak valid');
          }
        } catch (parseError) {
          print('❌ Error parsing JSON: $parseError');
          throw Exception('Format data tidak valid: $parseError');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Session telah habis');
      } else if (response.statusCode == 404) {
        throw Exception('Agenda tidak ditemukan');
      } else {
        throw Exception('Gagal mengambil detail agenda: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception: $e');
      throw Exception('Error: $e');
    }
  }

  // Menambah metode untuk mendapatkan agenda berdasarkan ID surat
  static Future<Agenda?> getAgendaBySuratId(int suratId) async {
    try {
      // Karena endpoint spesifik untuk pencarian surat belum ada, kita gunakan pendekatan client-side filtering
      final allAgendas = await getAgendaList();
      final filteredAgendas = allAgendas.where((agenda) => agenda.suratId == suratId).toList();
      
      if (filteredAgendas.isNotEmpty) {
        return filteredAgendas.first;
      } else {
        print('ℹ️ Tidak ada agenda untuk surat ID: $suratId');
        return null;
      }
    } catch (e) {
      print('💥 Error mencari agenda untuk surat: $e');
      throw Exception('Error mencari agenda: $e');
    }
  }

  // Fallback method untuk memastikan aplikasi tetap berjalan
  static Future<List<Agenda>> getAgendaListWithFallback() async {
    try {
      return await getAgendaList();
    } catch (e) {
      print('⚠️ Menggunakan data dummy karena error: $e');
      return _getDummyAgendaList();
    }
  }

  // Data dummy untuk fallback
  static List<Agenda> _getDummyAgendaList() {
    return [
      Agenda(
        id: 1,
        nomorAgenda: 'AM-001/05/2023',
        suratId: 1,
        tanggalAgenda: DateTime.now().subtract(const Duration(days: 5)),
        pengirim: 'PT. Maju Bersama',
        penerima: null,
      ),
      Agenda(
        id: 2,
        nomorAgenda: 'AK-001/05/2023',
        suratId: 2,
        tanggalAgenda: DateTime.now().subtract(const Duration(days: 3)),
        pengirim: null,
        penerima: 'Dinas Pendidikan',
      ),
    ];
  }

  // Method untuk membuat Agenda dari parameter surat
  static Future<Agenda> createAgendaFromSuratData(int suratId, String tipe, String asalSurat, String? tujuanSurat) async {
    try {
      // Dapatkan jumlah agenda yang sudah ada untuk menentukan nomor urut
      List<Agenda> agendas;
      try {
        agendas = await getAgendaList();
      } catch (e) {
        print('⚠️ Gagal mendapatkan daftar agenda, menggunakan default counter');
        agendas = [];
      }
      
      final counter = agendas.length + 1;
      
      // Generate nomor agenda
      final nomorAgenda = generateNomorAgenda(tipe, counter);
      
      // Buat objek agenda
      final agenda = Agenda(
        nomorAgenda: nomorAgenda,
        suratId: suratId,
        tanggalAgenda: DateTime.now(),
        pengirim: tipe.toLowerCase() == 'masuk' ? asalSurat : null,
        penerima: tipe.toLowerCase() == 'keluar' ? tujuanSurat : null,
      );
      
      // Kirim ke API
      return await createAgenda(agenda);
    } catch (e) {
      print('💥 Error membuat agenda dari surat: $e');
      throw Exception('Gagal membuat agenda: $e');
    }
  }

  // Membuat agenda baru dari surat yang sudah ada
  static Future<Agenda> createAgendaFromSurat(Surat surat) async {
    if (surat.id == null) {
      throw Exception('ID surat tidak valid untuk membuat agenda');
    }
    
    try {
      // Debug output
      print('📝 Membuat agenda untuk surat ID: ${surat.id}');
      print('🔍 Detail surat:');
      print('  - Tipe: ${surat.tipe}');
      print('  - Asal: ${surat.asalSurat}');
      print('  - Tujuan: ${surat.tujuanSurat}');
      
      // Generate nomor agenda
      final prefix = surat.tipe.toLowerCase() == 'masuk' ? 'AM' : 'AK';
      final now = DateTime.now();
      final counter = now.millisecondsSinceEpoch % 1000; // Gunakan timestamp untuk nomor unik
      final nomorAgenda = '$prefix-${counter.toString().padLeft(3, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      
      // Buat objek agenda
      final agenda = Agenda(
        nomorAgenda: nomorAgenda,
        suratId: surat.id!,
        tanggalAgenda: now,
        // Untuk surat MASUK: pengirim = asal surat, penerima = null
        // Untuk surat KELUAR: pengirim = asal surat, penerima = tujuan surat
        pengirim: surat.asalSurat,
        penerima: surat.tipe.toLowerCase() == 'keluar' ? surat.tujuanSurat : null,
      );
      
      // Debug output
      print('📋 Agenda yang dibuat:');
      print('  - Nomor: ${agenda.nomorAgenda}');
      print('  - Pengirim: ${agenda.pengirim}');
      print('  - Penerima: ${agenda.penerima}');
      
      return await createAgenda(agenda);
    } catch (e) {
      print('❌ Error membuat agenda: $e');
      throw Exception('Gagal membuat agenda: $e');
    }
  }
  
  // Metode fallback untuk mencoba URL alternatif saat endpoint utama gagal
  static Future<Agenda> _createAgendaWithAlternativeUrl(Agenda agenda) async {
    try {
      final alternativeURL = '$baseURL/api/agenda'; // URL alternatif jika ada masalah dengan URL utama
      _logApiCall('POST', alternativeURL, null, null);
      
      final token = await getToken();
      final response = await http.post(
        Uri.parse(alternativeURL),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(agenda.toJson()),
      );

      _logApiCall('POST', alternativeURL, response.statusCode, response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['data'] != null) {
          return Agenda.fromJson(responseData['data']);
        } else {
          throw Exception('Data agenda tidak valid');
        }
      } else {
        throw Exception('Gagal membuat agenda dengan URL alternatif: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception di URL alternatif: $e');
      throw Exception('Error dengan URL alternatif: $e');
    }
  }

  // Implementasi method untuk membuat agenda baru
  static Future<Agenda> createAgenda(Agenda agenda) async {
    try {
      _logApiCall('POST', agendaURL, null, null);
      
      final token = await getToken();
      final response = await http.post(
        Uri.parse(agendaURL),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(agenda.toJson()),
      );

      _logApiCall('POST', agendaURL, response.statusCode, response.body);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['data'] != null) {
          return Agenda.fromJson(responseData['data']);
        } else {
          throw Exception('Data agenda tidak valid');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Session telah habis');
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Validasi gagal');
      } else {
        throw Exception('Gagal membuat agenda: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception: $e');
      throw Exception('Error: $e');
    }
  }

  /**
   * Generate nomor agenda berdasarkan tipe surat dan counter
   * Format: [prefix]-[counter]/[bulan]/[tahun]
   * Contoh: AM-001/05/2023 untuk surat masuk
   * Contoh: AK-001/05/2023 untuk surat keluar
   */
  static String generateNomorAgenda(String tipe, int counter) {
    // Dapatkan tanggal saat ini
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    
    // Tentukan prefix berdasarkan tipe surat
    // AM = Agenda Masuk, AK = Agenda Keluar
    final prefix = tipe.toLowerCase() == 'masuk' ? 'AM' : 'AK';
    
    // Format counter dengan padding 0 di depan
    final formattedCounter = counter.toString().padLeft(3, '0');
    
    // Format nomor agenda - sesuaikan dengan format yang diharapkan
    return '$prefix-$formattedCounter/$month/$year';
  }
}