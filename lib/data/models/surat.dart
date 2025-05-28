import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/services/agenda_service.dart';
import 'package:surat_masuk_keluar_flutter/data/models/agenda.dart';
import 'package:surat_masuk_keluar_flutter/data/services/disposisi_service.dart';
import 'package:surat_masuk_keluar_flutter/data/models/disposisi.dart';
import 'package:surat_masuk_keluar_flutter/data/services/auth_service.dart';
import 'package:surat_masuk_keluar_flutter/data/services/surat_service.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;

class Surat {
  final int? id;
  final String nomorSurat;
  final String tipe;
  final String kategori;
  final String asalSurat;
  final String? tujuanSurat;
  final DateTime tanggalSurat;
  final String perihal;
  final String isi;
  String? file;
  final String status;
  final int userId;
  final String? createdAt;
  final String? updatedAt;

  // Tambahkan field untuk informasi error pembuatan agenda
  String? agendaCreationError;

  Surat({
    this.id,
    required this.nomorSurat,
    required this.tipe,
    required this.kategori,
    required this.asalSurat,
    this.tujuanSurat,
    required this.tanggalSurat,
    required this.perihal,
    required this.isi,
    this.file,
    required this.status,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Surat.fromJson(Map<String, dynamic> json) {
    return Surat(
      id: json['id'],
      nomorSurat: json['nomor_surat'] ?? '',
      tipe: json['tipe'] ?? '',
      kategori: json['kategori'] ?? '',
      asalSurat: json['asal_surat'] ?? '',
      tujuanSurat: json['tujuan_surat'],
      tanggalSurat: json['tanggal_surat'] != null 
        ? DateTime.parse(json['tanggal_surat'].toString())  
        : DateTime.now(),
      perihal: json['perihal'] ?? '',
      isi: json['isi'] ?? '',
      file: json['file'] ?? '',
      status: json['status'] ?? 'draft',
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Tambahkan method untuk konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_surat': nomorSurat,
      'tipe': tipe,
      'kategori': kategori,
      'asal_surat': asalSurat,
      'tujuan_surat': tujuanSurat,
      'tanggal_surat': tanggalSurat.toIso8601String().split('T')[0],
      'perihal': perihal,
      'isi': isi,
      'file': file,
      'status': status,
      'user_id': userId,
    };
  }

  // Helper methods untuk status
  bool isDraft() => status == 'draft';
  bool isDikirim() => status == 'dikirim';
  bool isVerified() => status == 'diverifikasi';
  bool isDitolak() => status == 'ditolak';
  
  // Tambahkan helper methods untuk status baru
  bool isDitindaklanjuti() => status.toLowerCase() == 'ditindaklanjuti';
  bool isSelesai() => status.toLowerCase() == 'selesai';
  
  // Helper methods untuk tipe
  bool isMasuk() => tipe.toLowerCase() == 'masuk';
  bool isKeluar() => tipe.toLowerCase() == 'keluar';
  
  // Helper methods untuk kategori
  bool isInternal() => kategori == 'internal';
  bool isEksternal() => kategori == 'eksternal';

  // Helper method untuk menampilkan toast/snackbar
  void _showToast(BuildContext context, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppPallete.errorColor : AppPallete.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Method untuk membuat Agenda dari Surat ini
  Future<Agenda> createAgendaFromSurat() async {
    // Gunakan AgendaService untuk membuat agenda
    return await AgendaService.createAgendaFromSurat(this);
  }
  
  // Method untuk mendapatkan agenda yang terkait dengan surat ini
  Future<Agenda?> getAgenda() async {
    if (id == null) {
      return null;
    }
    
    try {
      return await AgendaService.getAgendaBySuratId(id!);
    } catch (e) {
      print('Error mendapatkan agenda: $e');
      return null;
    }
  }

  // Method helper untuk mengambil disposisi terkait surat ini
  Future<List<Disposisi>> getDisposisi() async {
    if (id == null) {
      throw Exception('ID Surat tidak valid untuk mendapatkan disposisi');
    }
    
    try {
      return await DisposisiService.getDisposisiBySuratId(id!);
    } catch (e) {
      print('Error getting disposisi for surat: $e');
      return []; // Return empty list instead of throwing
    }
  }

  // Method helper untuk membuat disposisi baru
  Future<Disposisi> createDisposisiForSurat({
    required int dariUserId,
    required int kepadaUserId,
    String? instruksi,
    String status = 'diajukan',
  }) async {
    if (id == null) {
      throw Exception('ID Surat tidak valid untuk membuat disposisi');
    }
    
    try {
      final disposisi = Disposisi(
        suratId: id!,
        dariUserId: dariUserId,
        kepadaUserId: kepadaUserId,
        instruksi: instruksi,
        status: status,
        tanggalDisposisi: DateTime.now(),
      );
      
      return await DisposisiService.createDisposisi(disposisi);
    } catch (e) {
      print('Error creating disposisi for surat: $e');
      rethrow;
    }
  }

  // Method helper untuk membuat disposisi dengan user yang login sebagai pengirim
  Future<Disposisi> disposisikanKe(int kepadaUserId, {String? instruksi}) async {
    if (id == null) {
      throw Exception('ID Surat tidak valid untuk membuat disposisi');
    }
    
    try {
      // Dapatkan ID user yang login menggunakan UserService
      final dariUserId = await UserService.getUserId() ?? 0;
      if (dariUserId == 0) {
        throw Exception('User ID tidak valid');
      }
      
      return createDisposisiForSurat(
        dariUserId: dariUserId,
        kepadaUserId: kepadaUserId,
        instruksi: instruksi,
      );
    } catch (e) {
      print('Error disposisikan surat: $e');
      rethrow;
    }
  }

  // Helper method untuk update status
  Future<bool> updateStatus(String newStatus) async {
    if (id == null) return false;
    
    try {
      // Buat surat baru dengan status yang diperbarui
      final updatedSurat = Surat(
        id: id,
        nomorSurat: nomorSurat,
        tipe: tipe,
        kategori: kategori,
        asalSurat: asalSurat,
        tujuanSurat: tujuanSurat,
        tanggalSurat: tanggalSurat,
        perihal: perihal,
        isi: isi,
        file: file,
        status: newStatus,
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      
      // Update surat menggunakan service
      await SuratService.updateSuratWithFallback(id!, updatedSurat);
      return true;
    } catch (e) {
      print('❌ Error updating surat status: $e');
      return false;
    }
  }

  // Helper method untuk cek status disposisi terkait
  Future<String?> getHighestDisposisiStatus() async {
    if (id == null) return null;
    
    try {
      final disposisiList = await getDisposisi();
      if (disposisiList.isEmpty) return null;
      
      // Cek prioritas status disposisi
      bool adaSelesai = false;
      bool adaTindaklanjut = false;
      
      for (final disposisi in disposisiList) {
        if (disposisi.status.toLowerCase() == 'selesai') {
          adaSelesai = true;
          break; // Prioritaskan status selesai
        } else if (disposisi.status.toLowerCase() == 'ditindaklanjuti') {
          adaTindaklanjut = true;
        }
      }
      
      if (adaSelesai) return 'selesai';
      if (adaTindaklanjut) return 'ditindaklanjuti';
      
      return null;
    } catch (e) {
      print('❌ Error getting disposisi status: $e');
      return null;
    }
  }
}