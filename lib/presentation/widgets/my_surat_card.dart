import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MySuratCard extends StatelessWidget {
  final String nomorSurat;
  final String tanggalSurat;
  final String pengirimSurat;
  final String tujuanSurat;
  final String nomorAgenda;
  final String klasifikasiSurat;
  final String ringkasanSurat;
  final String keteranganSurat;
  final VoidCallback? onDisposisiTap;
  final VoidCallback? onPdfTap;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final String? status;
  final String? tipeSurat; // Tambahkan tipeSurat (masuk/keluar)
  final bool canBeDisposed; // Tambahkan flag untuk kontrol tampilan tombol disposisi

  const MySuratCard({
    super.key,
    required this.nomorSurat,
    required this.tanggalSurat,
    required this.pengirimSurat,
    this.tujuanSurat = "-",
    this.nomorAgenda = "",
    this.klasifikasiSurat = "",
    required this.ringkasanSurat,
    this.keteranganSurat = "",
    this.onDisposisiTap,
    this.onPdfTap,
    this.onTap,
    this.onEditTap,
    this.onDeleteTap,
    this.status,
    this.tipeSurat, // Parameter opsional untuk tipe surat
    this.canBeDisposed = true, // Default true untuk backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah tombol disposisi harus ditampilkan berdasarkan tipe surat dan flag
    final bool showDisposisiButton = canBeDisposed && onDisposisiTap != null;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with action buttons
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Surat info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nomor surat with status badge and tipe surat
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nomorSurat,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Tampilkan indikator tipe surat jika tersedia
                            if (tipeSurat != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: _getTipeColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _getTipeColor()),
                                ),
                                child: Text(
                                  _formatTipe(tipeSurat!),
                                  style: TextStyle(
                                    color: _getTipeColor(),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            // Status badge
                            if (status != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _getStatusColor()),
                                ),
                                child: Text(
                                  _formatStatus(status!),
                                  style: TextStyle(
                                    color: _getStatusColor(),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Meta data row
                        Wrap(
                          spacing: 8,
                          children: [
                            if (tipeSurat?.toLowerCase() == 'masuk' && pengirimSurat.isNotEmpty)
                              _buildMetaItem(Icons.person_outline, "Dari: $pengirimSurat"),
                            if (tipeSurat?.toLowerCase() == 'keluar' && tujuanSurat != "-")
                              _buildMetaItem(Icons.person_outline, "Ke: $tujuanSurat"),
                            // Fallback jika tipeSurat tidak disediakan
                            if (tipeSurat == null) ...[
                              if (pengirimSurat.isNotEmpty)
                                _buildMetaItem(Icons.person_outline, pengirimSurat),
                              if (tujuanSurat != "-")
                                _buildMetaItem(Icons.arrow_forward, tujuanSurat),
                            ],
                            _buildMetaItem(Icons.calendar_today_outlined, tanggalSurat),
                            if (klasifikasiSurat.isNotEmpty)
                              _buildMetaItem(Icons.category_outlined, klasifikasiSurat),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Nomor agenda
                        if (nomorAgenda.isNotEmpty)
                          Text(
                            "No. Agenda: $nomorAgenda",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Action buttons column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // PDF button if available
                      if (onPdfTap != null)
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          onPressed: onPdfTap,
                          tooltip: 'Lihat PDF',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        
                      // More options menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context) => [
                          // Tampilkan opsi disposisi hanya jika tersedia dan diizinkan
                          if (showDisposisiButton)
                            const PopupMenuItem(
                              value: 'disposisi',
                              child: Row(
                                children: [
                                  Icon(Icons.send, color: AppPallete.primaryColor),
                                  SizedBox(width: 8),
                                  Text('Disposisi'),
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
                        onSelected: (value) {
                          switch (value) {
                            case 'disposisi':
                              if (onDisposisiTap != null) onDisposisiTap!();
                              break;
                            case 'edit':
                              if (onEditTap != null) onEditTap!();
                              break;
                            case 'delete':
                              if (onDeleteTap != null) onDeleteTap!();
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Perihal/Ringkasan
                  Text(
                    ringkasanSurat,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  if (keteranganSurat.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      keteranganSurat,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Action buttons for mobile view - hanya tampilkan jika diizinkan
                  if (showDisposisiButton) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.send, size: 16),
                          label: const Text('Disposisi'),
                          onPressed: onDisposisiTap,
                          style: TextButton.styleFrom(
                            foregroundColor: AppPallete.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper widget for meta items (from, to, date, category)
  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
  
  // Format status text for display
  String _formatStatus(String statusText) {
    switch (statusText.toLowerCase()) {
      case 'draft':
        return 'DRAFT';
      case 'ditindaklanjuti':
        return 'DITINDAKLANJUTI';
      case 'diajukan':
        return 'DIAJUKAN';
      case 'diverifikasi':
        return 'DIVERIFIKASI';
      case 'selesai':
        return 'SELESAI';
      case 'ditolak':
        return 'DITOLAK';
      default:
        return statusText.toUpperCase();
    }
  }
  
  // Format tipe surat
  String _formatTipe(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'masuk':
        return 'Masuk';
      case 'keluar':
        return 'Keluar';
      default:
        return tipe;
    }
  }
  
  // Get color for status
  Color _getStatusColor() {
    if (status == null) return Colors.grey;
    
    switch (status!.toLowerCase()) {
      case 'draft':
        return Colors.grey.shade700;
      case 'ditindaklanjuti':
        return Colors.orange;
      case 'diajukan':
        return Colors.blue;
      case 'diverifikasi':
        return Colors.green;
      case 'selesai':
        return Colors.green.shade700;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Get color for tipe surat
  Color _getTipeColor() {
    if (tipeSurat == null) return Colors.grey;
    
    switch (tipeSurat!.toLowerCase()) {
      case 'masuk':
        return Colors.blue;
      case 'keluar':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}