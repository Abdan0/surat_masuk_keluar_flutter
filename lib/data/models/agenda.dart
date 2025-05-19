import 'dart:convert';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';

class Agenda {
  final int? id;
  final String nomorAgenda;
  final int suratId;
  final DateTime tanggalAgenda;
  final String? pengirim;
  final String? penerima;
  final String? createdAt;
  final String? updatedAt;
  final Surat? surat;

  Agenda({
    this.id,
    required this.nomorAgenda,
    required this.suratId,
    required this.tanggalAgenda,
    this.pengirim,
    this.penerima,
    this.createdAt,
    this.updatedAt,
    this.surat,
  });

  // Factory constructor untuk membuat objek Agenda dari JSON dengan error handling yang lebih baik
  factory Agenda.fromJson(Map<String, dynamic> json) {
    try {
      // Helper untuk menangani parsing tanggal dengan lebih baik
      DateTime parseTanggalAgenda(dynamic value) {
        if (value == null) return DateTime.now();
        
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            print('Error parsing tanggal_agenda: $value, error: $e');
            return DateTime.now();
          }
        }
        return DateTime.now();
      }
      
      return Agenda(
        id: json['id'],
        nomorAgenda: json['nomor_agenda'] ?? 'No. -',
        suratId: json['surat_id'] != null ? int.parse(json['surat_id'].toString()) : 0,
        tanggalAgenda: parseTanggalAgenda(json['tanggal_agenda']),
        pengirim: json['pengirim'],
        penerima: json['penerima'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        surat: json['surat'] != null ? Surat.fromJson(json['surat']) : null,
      );
    } catch (e) {
      print('Error parsing Agenda from JSON: $e');
      print('JSON data: ${jsonEncode(json)}');
      
      // Return agenda dengan default values daripada throw exception
      return Agenda(
        id: null,
        nomorAgenda: 'Error',
        suratId: 0,
        tanggalAgenda: DateTime.now(),
      );
    }
  }

  // Method untuk mengonversi objek Agenda ke JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nomor_agenda': nomorAgenda,
      'surat_id': suratId,
      'tanggal_agenda': tanggalAgenda.toIso8601String().split('T')[0],
      if (pengirim != null) 'pengirim': pengirim,
      if (penerima != null) 'penerima': penerima,
    };
  }

  // Method untuk mendapatkan nama pengirim dengan fallback ke asal_surat
  String get namaPengirim {
    return pengirim ?? surat?.asalSurat ?? 'Tidak diketahui';
  }

  // Method untuk mendapatkan nama penerima dengan fallback ke tujuan_surat
  String get namaPenerima {
    return penerima ?? surat?.tujuanSurat ?? 'Tidak diketahui';
  }
}