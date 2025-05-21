import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/disposisi_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDetailSurat extends StatelessWidget {
  final String nomorSurat;
  final String tanggalSurat;
  final String pengirimSurat;
  final String tujuanSurat;
  final String nomorAgenda;
  final String klasifikasiSurat;
  final String ringkasanSurat;
  final String keteranganSurat;
  final String createByController;
  final String createOnController;
  final String updateOnController;
  final VoidCallback? onDisposisiTap;
  final VoidCallback? onPdfTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const MyDetailSurat({
    super.key,
    required this.nomorSurat,
    required this.tanggalSurat,
    required this.pengirimSurat,
    required this.tujuanSurat,
    required this.nomorAgenda,
    required this.klasifikasiSurat,
    required this.ringkasanSurat,
    required this.keteranganSurat,
    required this.createByController,
    required this.createOnController,
    required this.updateOnController,
    this.onDisposisiTap,
    this.onPdfTap,
    this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    // Buat map untuk detail informasi surat
    final Map<String, String> detailItems = {
      'Tanggal Surat': tanggalSurat,
      'Nomor Surat': nomorSurat,
      'Nomor Agenda': nomorAgenda,
      'Klasifikasi Surat': klasifikasiSurat,
      'Pengirim Surat': pengirimSurat,
      'Tujuan Surat': tujuanSurat,
      'Dibuat Oleh': createByController,
      'Dibuat Pada': createOnController,
      'Diperbarui Pada': updateOnController,
    };
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppPallete.borderColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section - title and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nomorSurat,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppPallete.textColor,
                            ),
                          ),
                          Text(
                            pengirimSurat,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Actions row
                    Row(
                      children: [
                        // Disposisi button
                        if (onDisposisiTap != null)
                          SizedBox(
                            height: 36,
                            width: 80,
                            child: ElevatedButton(
                              onPressed: onDisposisiTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPallete.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Disposisi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        
                        // More options menu
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          offset: const Offset(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                if (onEditTap != null) onEditTap!();
                                break;
                              case 'delete':
                                if (onDeleteTap != null) onDeleteTap!();
                                break;
                              case 'pdf':
                                if (onPdfTap != null) onPdfTap!();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            if (onPdfTap != null)
                              const PopupMenuItem(
                                value: 'pdf',
                                child: Row(
                                  children: [
                                    Icon(Icons.picture_as_pdf, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Lihat PDF'),
                                  ],
                                ),
                              ),
                            if (onEditTap != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                            if (onDeleteTap != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                const Divider(thickness: 1),
                
                // Detail items in a cleaner layout
                Column(
                  children: detailItems.entries.map((entry) {
                    // Skip empty fields
                    if (entry.value.isEmpty || entry.value == '-') return const SizedBox.shrink();
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label - fixed width for alignment
                          SizedBox(
                            width: 120,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF29314F),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          
                          // Separator
                          const Text(
                            " : ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF29314F),
                              fontSize: 14,
                            ),
                          ),
                          
                          // Value with text wrapping
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 14, 
                                color: Color(0xFF29314F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Content section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppPallete.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ringkasanSurat,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppPallete.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        keteranganSurat,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppPallete.textColor,
                        ),
                      ),
                      if (onPdfTap != null) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: onPdfTap,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Buka Lampiran PDF',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}