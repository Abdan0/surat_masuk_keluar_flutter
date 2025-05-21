import 'package:surat_masuk_keluar_flutter/data/models/disposisi.dart';

class Notifikasi {
  final int? id;
  final int userId;
  final String judul;
  final String pesan;
  final String? tipe;
  final int? referenceId; // ID dari disposisi atau surat
  final bool dibaca;
  final DateTime createdAt;
  final DateTime? readAt;

  Notifikasi({
    this.id,
    required this.userId,
    required this.judul,
    required this.pesan,
    this.tipe,
    this.referenceId,
    this.dibaca = false,
    required this.createdAt,
    this.readAt,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      id: json['id'],
      userId: json['user_id'],
      judul: json['judul'],
      pesan: json['pesan'],
      tipe: json['tipe'],
      referenceId: json['reference_id'],
      dibaca: json['dibaca'] == 1 || json['dibaca'] == true,
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'judul': judul,
      'pesan': pesan,
      'tipe': tipe,
      'reference_id': referenceId,
      'dibaca': dibaca ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  // Factory constructor untuk membuat notifikasi disposisi baru
  factory Notifikasi.forNewDisposisi({
    required int userId,
    required String pengirimNama,
    required Disposisi disposisi,
  }) {
    return Notifikasi(
      userId: userId,
      judul: 'Disposisi Baru',
      pesan: 'Anda menerima disposisi baru dari $pengirimNama untuk surat "${disposisi.surat?.perihal ?? 'Perihal tidak tersedia'}"',
      tipe: 'disposisi',
      referenceId: disposisi.id,
      dibaca: false,
      createdAt: DateTime.now(),
    );
  }

  // Untuk menandai notifikasi sebagai dibaca
  Notifikasi markAsRead() {
    return Notifikasi(
      id: id,
      userId: userId,
      judul: judul,
      pesan: pesan,
      tipe: tipe,
      referenceId: referenceId,
      dibaca: true,
      createdAt: createdAt,
      readAt: DateTime.now(),
    );
  }
}