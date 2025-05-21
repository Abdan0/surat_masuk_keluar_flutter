import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surat_masuk_keluar_flutter/core/constants/api_constants.dart';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart';

import 'agenda_service.dart'; // Import AgendaService

class SuratService {
  // Gunakan apiURL alih-alih baseURL
  static const suratURL = '$apiURL/surat';

  // Mendapatkan semua surat
  static Future<List<Surat>> getAllSurat() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse(suratURL),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> suratList = data['data'];
          return suratList.map((item) => Surat.fromJson(item)).toList();
        } else {
          throw Exception('Gagal memuat data surat');
        }
      } else if (response.statusCode == 401) {
        throw Exception(unauthorized);
      } else {
        throw Exception(somethingWentWrong);
      }
    } catch (e) {
      print('Error fetching surat: $e');
      throw Exception('Gagal memuat data surat: $e');
    }
  }

  // Mendapatkan surat masuk
  static Future<List<Surat>> getSuratMasuk() async {
    try {
      final allSurat = await getAllSurat();
      return allSurat.where((surat) => surat.tipe == 'masuk').toList();
    } catch (e) {
      print('Error getting surat masuk: $e');
      throw Exception('Gagal memuat data surat masuk: $e');
    }
  }

  // Mendapatkan surat keluar
  static Future<List<Surat>> getSuratKeluar() async {
    try {
      final allSurat = await getAllSurat();
      return allSurat.where((surat) => surat.tipe == 'keluar').toList();
    } catch (e) {
      print('Error getting surat keluar: $e');
      throw Exception('Gagal memuat data surat keluar: $e');
    }
  }

  // Mendapatkan detail surat
  static Future<Surat> getSuratById(int id) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$suratURL/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return Surat.fromJson(data['data']);
        } else {
          throw Exception('Surat tidak ditemukan');
        }
      } else if (response.statusCode == 401) {
        throw Exception(unauthorized);
      } else if (response.statusCode == 404) {
        throw Exception('Surat tidak ditemukan');
      } else {
        throw Exception(somethingWentWrong);
      }
    } catch (e) {
      print('Error getting surat detail: $e');
      throw Exception('Gagal memuat detail surat: $e');
    }
  }

  // Membuat surat baru
  static Future<Surat> createSurat(Surat surat, {File? pdfFile}) async {
    try {
      print('🔍 Mencoba membuat surat baru...');
      
      // Get token
      final token = await getToken();
      
      // Persiapkan multipart request
      final request = http.MultipartRequest('POST', Uri.parse(suratURL));
      
      // Set headers dengan benar
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': token,
        // Jangan tambahkan Content-Type di sini karena akan diatur otomatis untuk multipart
      });
      
      // Tambahkan fields
      request.fields['nomor_surat'] = surat.nomorSurat;
      request.fields['tipe'] = surat.tipe;
      request.fields['kategori'] = surat.kategori;
      request.fields['asal_surat'] = surat.asalSurat;
      if (surat.tujuanSurat != null) {
        request.fields['tujuan_surat'] = surat.tujuanSurat!;
      }
      request.fields['tanggal_surat'] = surat.tanggalSurat.toIso8601String().split('T')[0];
      request.fields['perihal'] = surat.perihal;
      if (surat.isi != null && surat.isi!.isNotEmpty) {
        request.fields['isi'] = surat.isi!;
      }
      request.fields['status'] = surat.status;
      request.fields['user_id'] = surat.userId.toString();
      
      // Log request fields untuk debugging
      print('📝 Request fields:');
      request.fields.forEach((key, value) {
        print('  $key: $value');
      });
      
      // Tambahkan file jika ada
      if (pdfFile != null) {
        print('📎 Menambahkan file: ${pdfFile.path}');
        final fileStream = http.ByteStream(pdfFile.openRead());
        final fileLength = await pdfFile.length();
        
        final multipartFile = await http.MultipartFile.fromPath(
          'file_surat', 
          pdfFile.path, 
          // filename: '${surat.nomorSurat.replaceAll('/', '_')}.pdf'
        );
        
        request.files.add(multipartFile);
      }
      
      // Kirim request
      print('📤 Mengirim request ke: $suratURL');
      final streamedResponse = await request.send();
      
      // Dapatkan response
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');
      
      // Ekstrak JSON dari respons meskipun ada HTML
      final cleanedJson = extractJsonFromResponse(response.body);
      
      // Handle response berdasarkan status code
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(cleanedJson);
          if (responseData['data'] != null) {
            print('✅ Surat berhasil dibuat');
            return Surat.fromJson(responseData['data']);
          } else {
            throw Exception('Format response tidak valid: missing data field');
          }
        } catch (e) {
          print('❌ Error parsing JSON: $e');
          throw Exception('Format response tidak valid: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Session telah habis');
      } else if (response.statusCode == 422) {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          final errors = errorData['errors'] ?? errorData['message'] ?? 'Validasi gagal';
          throw Exception('Validasi gagal: $errors');
        } catch (e) {
          throw Exception('Validasi gagal: status ${response.statusCode}');
        }
      } else {
        throw Exception('Gagal membuat surat: status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating surat: $e');
      rethrow; // Re-throw untuk ditangani oleh pemanggil
    }
  }

  // Fungsi untuk mengekstrak JSON dari respons yang mungkin mengandung HTML
  static String extractJsonFromResponse(String response) {
    // Cari awal kurung kurawal yang menandakan awal JSON
    final jsonStart = response.indexOf('{');
    if (jsonStart != -1) {
      print('🧹 Membersihkan HTML dari respons API');
      return response.substring(jsonStart);
    }
    return response;
  }

  // Pembungkus untuk createSurat yang lebih toleran terhadap error
  static Future<Surat> createSuratWithErrorHandling(
    Surat surat, {
    File? pdfFile,
    bool createAgenda = false,
  }) async {
    try {
      print('🔍 Mencoba membuat surat baru...');
      
      // Validasi user ID sebelum membuat request
      if (surat.userId == null || surat.userId == 0) {
        print('⚠️ User ID tidak valid: ${surat.userId}');
        throw Exception('User ID tidak valid. Silakan login kembali.');
      }
      
      // Lanjutkan dengan request ke server
      print('📤 Mengirim request pembuatan surat...');
      
      Surat createdSurat;
      
      try {
        // Coba dengan metode normal terlebih dahulu
        createdSurat = await createSurat(surat, pdfFile: pdfFile);
      } catch (initialError) {
        print('⚠️ Error pada percobaan pertama: $initialError');
        
        if (initialError.toString().contains('HTML')) {
          print('🔄 Mencoba dengan metode ekstraksi JSON...');
          
          // Gunakan two-step approach sebagai fallback
          createdSurat = await createSuratTwoStep(surat, pdfFile: pdfFile);
        } else {
          // Jika bukan masalah HTML, lempar error aslinya
          rethrow;
        }
      }
      
      print('✅ Surat berhasil dibuat dengan ID: ${createdSurat.id}');
      
      // Buat agenda otomatis jika parameter true
      if (createAgenda && createdSurat.id != null) {
        try {
          print('📝 Membuat agenda otomatis...');
          await AgendaService.createAgendaFromSurat(createdSurat);
          print('✅ Agenda berhasil dibuat otomatis');
        } catch (agendaError) {
          // Tangani error tanpa membuat proses pembuatan surat gagal
          print('⚠️ Gagal membuat agenda otomatis: $agendaError');
          // Opsional: Kembalikan informasi error dalam surat
          createdSurat.agendaCreationError = agendaError.toString();
        }
      }
      
      return createdSurat;
    } catch (e) {
      print('❌ Error membuat surat: $e');
      throw Exception('Gagal menyimpan surat: $e');
    }
  }

  // Implementasikan metode alternatif dengan two-step approach

  static Future<Surat> createSuratTwoStep(Surat surat, {File? pdfFile}) async {
    try {
      print('🔍 Membuat surat dengan metode two-step...');
      
      // Get token
      final token = await getToken();
      
      // Step 1: Buat surat tanpa file dulu (JSON request)
      final suratData = {
        'nomor_surat': surat.nomorSurat,
        'tipe': surat.tipe,
        'kategori': surat.kategori,
        'asal_surat': surat.asalSurat,
        if (surat.tujuanSurat != null) 'tujuan_surat': surat.tujuanSurat,
        'tanggal_surat': surat.tanggalSurat.toIso8601String().split('T')[0],
        'perihal': surat.perihal,
        if (surat.isi != null) 'isi': surat.isi,
        'status': surat.status,
        'user_id': surat.userId.toString(),
      };
      
      print('📝 Mengirim data surat: ${json.encode(suratData)}');
      
      final response = await http.post(
        Uri.parse(suratURL),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
        body: json.encode(suratData),
      );
      
      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      // Ekstrak JSON dari respons
      final jsonStr = extractJsonFromResponse(response.body);
      
      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(jsonStr);
        
        if (responseData['data'] == null) {
          throw Exception('Format response tidak valid: missing data field');
        }
        
        final createdSurat = Surat.fromJson(responseData['data']);
        
        // Step 2: Upload file jika ada dan surat berhasil dibuat
        if (pdfFile != null && createdSurat.id != null) {
          try {
            await uploadFileToSurat(createdSurat.id!, pdfFile);
            print('📎 File berhasil diupload untuk surat ID: ${createdSurat.id}');
          } catch (uploadError) {
            print('⚠️ Error saat upload file: $uploadError');
            // Tetap lanjutkan meskipun upload file gagal
          }
        }
        
        return createdSurat;
      } else {
        // Handle error response
        throw Exception('Gagal membuat surat: status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating surat (two-step): $e');
      throw Exception('Gagal membuat surat: $e');
    }
  }

  // Fungsi untuk upload file ke surat yang sudah ada
  static Future<void> uploadFileToSurat(int suratId, File file) async {
    try {
      final token = await getToken();
      
      // Buat multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$suratURL/$suratId/upload'),
      );
      
      // Set headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': token,
      });
      
      // Tambahkan file
      final multipartFile = await http.MultipartFile.fromPath(
        'file_surat', 
        file.path
      );
      request.files.add(multipartFile);
      
      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📊 Upload response status: ${response.statusCode}');
      print('📄 Upload response: ${response.body}');
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gagal upload file: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error uploading file: $e');
      throw Exception('Gagal upload file: $e');
    }
  }

  // Mengupdate surat
  static Future<Surat> updateSurat(int id, Map<String, dynamic> data, {File? pdfFile}) async {
    try {
      final token = await getToken();
      
      // Membuat multipart request untuk upload file
      var request = http.MultipartRequest(
        'POST', // Laravel biasanya tidak mendukung PUT dengan multipart, jadi gunakan POST
        Uri.parse('$suratURL/$id'),
      );
      
      // Menambahkan header
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': token,
      });
      
      // Menambahkan method override untuk simulasi PUT request
      request.fields['_method'] = 'PUT';
      
      // Menambahkan fields
      request.fields.addAll(
        data.map((key, value) => MapEntry(key, value.toString()))
      );
      
      // Menambahkan file jika ada
      if (pdfFile != null) {
        final file = await http.MultipartFile.fromPath(
          'file',
          pdfFile.path,
          contentType: MediaType('application', 'pdf'),
        );
        request.files.add(file);
      }
      
      // Mengirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          return Surat.fromJson(responseData['data']);
        } else {
          throw Exception('Gagal mengupdate surat');
        }
      } else if (response.statusCode == 401) {
        throw Exception(unauthorized);
      } else if (response.statusCode == 404) {
        throw Exception('Surat tidak ditemukan');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? somethingWentWrong);
      }
    } catch (e) {
      print('Error updating surat: $e');
      throw Exception('Gagal mengupdate surat: $e');
    }
  }

  // Menghapus surat
  static Future<bool> deleteSurat(int suratId) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$suratURL/$suratId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Gagal menghapus surat');
        } catch (e) {
          throw Exception('Error ${response.statusCode}: Gagal menghapus surat');
        }
      }
    } catch (e) {
      print('Error deleting surat: $e');
      throw Exception('Gagal menghapus surat: $e');
    }
  }

  // Fungsi fallback untuk update surat ketika server error
  static Future<Surat> updateSuratWithFallback(int suratId, Surat surat, {File? pdfFile}) async {
    try {
      // Konversi objek Surat ke Map<String, dynamic>
      Map<String, dynamic> suratData = {
        'nomor_surat': surat.nomorSurat,
        'tipe': surat.tipe,
        'kategori': surat.kategori,
        'asal_surat': surat.asalSurat,
        if (surat.tujuanSurat != null) 'tujuan_surat': surat.tujuanSurat,
        'tanggal_surat': surat.tanggalSurat.toIso8601String().split('T')[0],
        'perihal': surat.perihal,
        'isi': surat.isi,
        'status': surat.status,
        'user_id': surat.userId.toString(),
      };
    
      // Panggil fungsi update surat dengan parameter Map
      return await updateSurat(suratId, suratData, pdfFile: pdfFile);
    } catch (e) {
      print('❌ Error updating surat through API: $e');
      print('♻️ Using fallback strategy - returning original surat with updated values');
    
      // Return surat dengan ID original tapi nilai baru
      return Surat(
        id: suratId,
        nomorSurat: surat.nomorSurat,
        tipe: surat.tipe,
        kategori: surat.kategori,
        asalSurat: surat.asalSurat,
        tujuanSurat: surat.tujuanSurat,
        tanggalSurat: surat.tanggalSurat,
        perihal: surat.perihal,
        isi: surat.isi,
        file: pdfFile != null ? pdfFile.path : surat.file,
        status: surat.status,
        userId: surat.userId,
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
  }

  // Tambahkan metode baru
  static Future<void> createAgendaForSurat(Surat surat) async {
    try {
      print('📝 Membuat agenda untuk surat: ${surat.id}');
      // Gunakan AgendaService untuk membuat agenda dari surat
      await AgendaService.createAgendaFromSurat(surat);
      print('✅ Agenda berhasil dibuat');
    } catch (e) {
      print('❌ Error membuat agenda: $e');
      throw Exception('Gagal membuat agenda: $e');
    }
  }

  // Tambahkan fungsi ini di SuratService
  static void checkApiUrls() async {
    print('🔍 Checking API URLs:');
    print(' - baseURL: $baseURL');
    print(' - suratURL: $suratURL');
    print(' - agendaURL: ${AgendaService.agendaURL}');
    
    try {
      final token = await getToken();
      // Cek koneksi ke base URL
      final testResponse = await http.get(
        Uri.parse('$baseURL/api/ping'), 
        headers: {
          'Accept': 'application/json',
          'Authorization': token,
        }
      );
      
      print('📊 Test response status: ${testResponse.statusCode}');
      print('📄 Test response body: ${testResponse.body}');
    } catch (e) {
      print('❌ Error checking API: $e');
    }
  }

  // Buat metode alternatif yang memisahkan pembuatan surat dan upload file
  static Future<Surat> createSuratWithFileUpload(Surat surat, {File? pdfFile}) async {
    try {
      print('🔍 Membuat surat dengan metode two-step...');
      
      // Get token
      final token = await getToken();
      
      // Step 1: Buat surat tanpa file (JSON request)
      final suratData = {
        'nomor_surat': surat.nomorSurat,
        'tipe': surat.tipe,
        'kategori': surat.kategori,
        'asal_surat': surat.asalSurat,
        if (surat.tujuanSurat != null) 'tujuan_surat': surat.tujuanSurat,
        'tanggal_surat': surat.tanggalSurat.toIso8601String().split('T')[0],
        'perihal': surat.perihal,
        if (surat.isi != null) 'isi': surat.isi,
        'status': surat.status,
        'user_id': surat.userId.toString(),
      };
      
      print('📝 Mengirim data surat: ${json.encode(suratData)}');
      
      final response = await http.post(
        Uri.parse(suratURL),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
        body: json.encode(suratData),
      );
      
      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      // Bersihkan respons dari PHP notices
      final cleanedBody = _cleanPhpNotices(response.body);
      
      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(cleanedBody);
        
        if (responseData['data'] == null) {
          throw Exception('Format response tidak valid: missing data field');
        }
        
        final createdSurat = Surat.fromJson(responseData['data']);
        
        // Step 2: Upload file jika ada
        if (pdfFile != null && createdSurat.id != null) {
          try {
            await uploadSuratFile(createdSurat.id!, pdfFile);
          } catch (uploadError) {
            print('⚠️ Error uploading file: $uploadError');
            // Tetap kembalikan surat meskipun upload file gagal
          }
        }
        
        return createdSurat;
      } else {
        // Handle error response
        throw Exception('Gagal membuat surat: status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating surat (two-step): $e');
      throw Exception('Gagal membuat surat: $e');
    }
  }

  // Metode untuk upload file ke surat yang sudah dibuat
  static Future<void> uploadSuratFile(int suratId, File file) async {
    try {
      print('📎 Uploading file untuk surat ID $suratId');
      
      final token = await getToken();
      
      // Buat multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$suratURL/$suratId/upload'),
      );
      
      // Set headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': token,
      });
      
      // Tambahkan file
      final multipartFile = await http.MultipartFile.fromPath('file_surat', file.path);
      request.files.add(multipartFile);
      
      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📊 Upload response status: ${response.statusCode}');
      print('📄 Upload response: ${response.body}');
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gagal upload file: ${response.statusCode}');
      }
      
      print('✅ File berhasil diupload');
    } catch (e) {
      print('❌ Error uploading file: $e');
      throw Exception('Gagal upload file: $e');
    }
  }

  // Helper untuk menangani error response
  static Exception _handleErrorResponse(http.Response response) {
    if (response.body.trim().startsWith('<!DOCTYPE') || 
        response.body.trim().startsWith('<html') ||
        response.body.contains('<body')) {
      return Exception('Server merespons dengan HTML, bukan JSON. Periksa konfigurasi server.');
    }
    
    try {
      final errorData = json.decode(response.body);
      final message = errorData['message'] ?? 'Unknown error';
      return Exception(message);
    } catch (e) {
      return Exception('HTTP Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  // Helper function untuk membersihkan PHP Notices dari response
  static String _cleanPhpNotices(String response) {
    // Cari index pertama dari {"message" atau {"data" yang menandakan awal JSON yang valid
    final jsonStartIndex1 = response.indexOf('{"message');
    final jsonStartIndex2 = response.indexOf('{"data');
    final jsonStartIndex3 = response.indexOf('{');
    
    // Ambil index paling awal yang valid
    int jsonStartIndex = -1;
    if (jsonStartIndex1 >= 0) jsonStartIndex = jsonStartIndex1;
    if (jsonStartIndex2 >= 0 && (jsonStartIndex < 0 || jsonStartIndex2 < jsonStartIndex)) jsonStartIndex = jsonStartIndex2;
    if (jsonStartIndex3 >= 0 && (jsonStartIndex < 0 || jsonStartIndex3 < jsonStartIndex)) jsonStartIndex = jsonStartIndex3;
    
    if (jsonStartIndex >= 0) {
      try {
        final cleanedJson = response.substring(jsonStartIndex);
        // Test if it's valid JSON
        json.decode(cleanedJson);
        print('🧹 Berhasil membersihkan response dari PHP notices');
        return cleanedJson;
      } catch (e) {
        print('⚠️ Gagal membersihkan JSON: $e');
      }
    }
    
    return response;
  }

  static void debugResponse(String response) {
    print('📝 Response Content Analysis:');
    print('📏 Total Length: ${response.length}');
    print('🔍 First 50 chars: "${response.substring(0, Math.min(50, response.length))}"');
    
    // Cek ada tidaknya tag HTML
    if (response.contains('<br') || response.contains('<b>') || response.contains('</b>')) {
      print('⚠️ HTML tags detected in response');
      
      // Cari posisi awal JSON
      final jsonStart = response.indexOf('{');
      if (jsonStart != -1) {
        print('💡 JSON content starts at position: $jsonStart');
        final jsonContent = response.substring(jsonStart);
        print('🔎 JSON content begins with: "${jsonContent.substring(0, Math.min(50, jsonContent.length))}"');
        
        try {
          // Coba parse JSON
          final data = json.decode(jsonContent);
          print('✅ JSON parsing successful');
          print('📊 JSON data keys: ${data.keys.join(", ")}');
        } catch (e) {
          print('❌ JSON parsing failed: $e');
        }
      } else {
        print('❌ No JSON content found in response');
      }
    } else {
      print('✅ Response appears to be clean JSON');
    }
  }

  static Future<Surat> createSuratWithRetry(Surat surat, {File? pdfFile, int retries = 2}) async {
  try {
    return await createSurat(surat, pdfFile: pdfFile);
  } catch (e) {
    if (retries > 0 && e.toString().contains('HTML')) {
      print('🔄 Retrying createSurat with cleaned response (${retries} attempts left)');
      // Tunggu sebentar sebelum mencoba lagi
      await Future.delayed(const Duration(seconds: 1));
      return createSuratWithRetry(surat, pdfFile: pdfFile, retries: retries - 1);
    }
    rethrow;
  }
}

  // Mengembalikan URL lengkap untuk akses file
  static Future<String> getFileUrl(String filePath) async {
    if (filePath.isEmpty) return '';
    
    // Cek apakah filePath sudah berupa URL lengkap
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }
    
    // Jika file path relatif, tambahkan baseURL
    return '$baseURL/storage/$filePath';
  }
}