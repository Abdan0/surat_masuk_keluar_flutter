import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';

class GaleriSuratMasuk extends StatefulWidget {
  const GaleriSuratMasuk({super.key});

  @override
  State<GaleriSuratMasuk> createState() => _GaleriSuratMasukState();
}

// Sample data model for the files
class FileData {
  final String id;
  final String title;
  final String fileType;
  final String fileUrl;

  FileData({
    required this.id,
    required this.title,
    required this.fileType,
    required this.fileUrl,
  });
}

class _GaleriSuratMasukState extends State<GaleriSuratMasuk> {
  // Sample data
  final List<FileData> _files = [
    FileData(
      id: 'SM-001',
      title: 'Surat Edaran Libur Idul Adha',
      fileType: 'PDF',
      fileUrl: '/path/to/file1.pdf',
    ),
    FileData(
      id: 'SM-002',
      title: 'Surat Edaran Libur Idul Adha',
      fileType: 'PDF',
      fileUrl: '/path/to/file2.pdf',
    ),
    FileData(
      id: 'SM-003',
      title: 'Undangan Rapat Koordinasi',
      fileType: 'PDF',
      fileUrl: '/path/to/file3.pdf',
    ),
    FileData(
      id: 'SM-004',
      title: 'Memo Internal Divisi IT',
      fileType: 'PDF',
      fileUrl: '/path/to/file4.pdf',
    ),
    FileData(
      id: 'SM-005',
      title: 'Pengumuman Jadwal Kegiatan',
      fileType: 'DOCX',
      fileUrl: '/path/to/file5.docx',
    ),
    FileData(
      id: 'SM-006',
      title: 'Laporan Bulanan Departemen',
      fileType: 'XLS',
      fileUrl: '/path/to/file6.xls',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              const MyAppBar2(),

              const SizedBox(height: 20),

              // Judul Halaman
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Galeri Berkas Surat Masuk',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppPallete.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),

              const SizedBox(height: 8),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari berkas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppPallete.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppPallete.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: AppPallete.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Galeri Surat
              _buildFileGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final file = _files[index];
        return _buildFileCard(file);
      },
    );
  }

  Widget _buildFileCard(FileData file) {
    Color cardColor;
    IconData fileIcon;
    
    // Set color and icon based on file type
    switch (file.fileType) {
      case 'PDF':
        cardColor = Colors.grey.shade200;
        fileIcon = Icons.picture_as_pdf;
        break;
      case 'DOCX':
        cardColor = Colors.blue.shade100;
        fileIcon = Icons.description;
        break;
      case 'XLS':
        cardColor = Colors.green.shade100;
        fileIcon = Icons.table_chart;
        break;
      default:
        cardColor = Colors.grey.shade200;
        fileIcon = Icons.insert_drive_file;
    }

    return InkWell(
      onTap: () {
        // Handle file tap - open the file or show details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening file: ${file.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Type Header
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 12),
                  Icon(fileIcon, size: 32, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          file.fileType,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          file.id,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // File Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // View Button
                        OutlinedButton.icon(
                          onPressed: () {
                            // Open view action
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Lihat'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppPallete.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            minimumSize: const Size(60, 30),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        // Action/Menu Button
                        IconButton(
                          onPressed: () {
                            // Show options menu
                            _showFileOptions(context, file);
                          },
                          icon: const Icon(Icons.more_vert),
                          splashRadius: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFileOptions(BuildContext context, FileData file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.remove_red_eye),
                title: const Text('Lihat'),
                onTap: () {
                  Navigator.pop(context);
                  // Open view action
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Unduh'),
                onTap: () {
                  Navigator.pop(context);
                  // Download file action
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Bagikan'),
                onTap: () {
                  Navigator.pop(context);
                  // Share file action
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // Delete file action
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
