import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/services/agenda_service.dart';
import 'package:surat_masuk_keluar_flutter/data/models/agenda.dart';

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
  final String? file;
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
      file: json['file'],
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
}