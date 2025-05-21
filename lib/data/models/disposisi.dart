import 'dart:convert';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
import 'package:intl/intl.dart';

class Disposisi {
  final int? id;
  final int suratId;
  final int dariUserId;
  final int kepadaUserId;
  final String? instruksi;
  final String status;
  final DateTime tanggalDisposisi;
  final String? createdAt;
  final String? updatedAt;
  // Relasi
  final Surat? surat;
  final User? dariUser;
  final User? kepadaUser;

  Disposisi({
    this.id,
    required this.suratId,
    required this.dariUserId,
    required this.kepadaUserId,
    this.instruksi,
    required this.status,
    required this.tanggalDisposisi,
    this.createdAt,
    this.updatedAt,
    this.surat,
    this.dariUser,
    this.kepadaUser,
  });

  // Factory constructor untuk membuat objek Disposisi dari JSON dengan error handling
  factory Disposisi.fromJson(Map<String, dynamic> json) {
    try {
      // Helper untuk menangani parsing tanggal dengan lebih baik
      DateTime parseTanggalDisposisi(dynamic value) {
        if (value == null) return DateTime.now();
        
        if (value is String) {
          try {
            // Mencoba parse tanggal dalam berbagai format
            return DateTime.parse(value);
          } catch (e) {
            print('Error parsing tanggal_disposisi: $value, error: $e');
            try {
              // Coba format lain jika gagal
              final df = DateFormat('dd-MM-yyyy');
              return df.parse(value);
            } catch (e2) {
              print('Error parsing with DateFormat: $e2');
              return DateTime.now();
            }
          }
        }
        return DateTime.now();
      }

      // Helper untuk parsing ID
      int parseId(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) {
          try {
            return int.parse(value);
          } catch (e) {
            print('Error parsing ID: $value, error: $e');
            return 0;
          }
        }
        return 0;
      }

      return Disposisi(
        id: parseId(json['id']),
        suratId: parseId(json['surat_id']),
        dariUserId: parseId(json['dari_user_id']),
        kepadaUserId: parseId(json['kepada_user_id']),
        instruksi: json['instruksi']?.toString(),
        status: json['status']?.toString() ?? 'diajukan',
        tanggalDisposisi: parseTanggalDisposisi(json['tanggal_disposisi']),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
        surat: json['surat'] != null ? Surat.fromJson(json['surat']) : null,
        dariUser: json['dari_user'] != null ? User.fromJson(json['dari_user']) : null,
        kepadaUser: json['kepada_user'] != null ? User.fromJson(json['kepada_user']) : null,
      );
    } catch (e) {
      print('Error parsing Disposisi from JSON: $e');
      print('JSON data: ${jsonEncode(json)}');
      
      // Return disposisi dengan default values daripada throw exception
      return Disposisi(
        id: null,
        suratId: 0,
        dariUserId: 0,
        kepadaUserId: 0,
        status: 'diajukan',
        tanggalDisposisi: DateTime.now(),
      );
    }
  }

  // Method untuk mengonversi objek Disposisi ke JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'surat_id': suratId,
      'dari_user_id': dariUserId,
      'kepada_user_id': kepadaUserId,
      if (instruksi != null && instruksi!.isNotEmpty) 'instruksi': instruksi,
      'status': status,
      'tanggal_disposisi': tanggalDisposisi.toIso8601String().split('T')[0],
    };
  }
  
  // Menambahkan getter untuk mempermudah mengakses nama user
  String get dariUserName => dariUser?.name ?? 'User ID: $dariUserId';
  String get kepadaUserName => kepadaUser?.name ?? 'User ID: $kepadaUserId';
  
  // Getter untuk format tanggal yang sudah diformat
  String get tanggalDisposisiFormatted {
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(tanggalDisposisi);
    } catch (e) {
      return tanggalDisposisi.toString().split(' ')[0];
    }
  }
  
  // Getter untuk status yang lebih user-friendly
  String get statusFormatted {
    switch (status.toLowerCase()) {
      case 'diajukan':
        return 'Diajukan';
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai Ditindaklanjuti';
      default:
        return status;
    }
  }
}