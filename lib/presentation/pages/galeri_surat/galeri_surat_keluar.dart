import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';
import 'package:surat_masuk_keluar_flutter/data/services/surat_service.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class GaleriSuratKeluar extends StatefulWidget {
  const GaleriSuratKeluar({super.key});

  @override
  State<GaleriSuratKeluar> createState() => _GaleriSuratKeluarState();
}

class _GaleriSuratKeluarState extends State<GaleriSuratKeluar> {
  bool _isLoading = true;
  List<Surat> _suratList = [];
  String? _error;
  String _searchQuery = '';
  
  // Tambahkan property baru
  int _selectedTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadSuratKeluar();
  }
  
  Future<void> _loadSuratKeluar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Mengambil semua surat keluar tanpa filter file
      final allSurat = await SuratService.getSuratKeluar();
      print('📊 Total surat keluar: ${allSurat.length}');
      print('📊 Surat dengan file: ${allSurat.where((s) => s.file != null && s.file!.isNotEmpty).length}');
      print('📊 Surat tanpa file: ${allSurat.where((s) => s.file == null || s.file!.isEmpty).length}');
      
      // Tampilkan semua surat (tanpa filter)
      setState(() {
        _suratList = allSurat;
        _isLoading = false;
      });
      
      print('✅ Berhasil memuat ${allSurat.length} surat keluar');
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
      print('❌ Error memuat surat keluar: $e');
    }
  }
  
  // Filter surat berdasarkan query pencarian dan tab
  List<Surat> _getFilteredSuratList() {
    // Pertama filter berdasarkan tab yang dipilih
    List<Surat> filteredByTab;
    
    switch (_selectedTabIndex) {
      case 1: // Dengan File
        filteredByTab = _suratList.where((surat) => 
          surat.file != null && surat.file!.isNotEmpty).toList();
        break;
      case 2: // Tanpa File
        filteredByTab = _suratList.where((surat) => 
          surat.file == null || surat.file!.isEmpty).toList();
        break;
      case 0: // Semua
      default:
        filteredByTab = _suratList;
        break;
    }
    
    // Kemudian filter berdasarkan query pencarian
    if (_searchQuery.isEmpty) {
      return filteredByTab;
    }
    
    return filteredByTab.where((surat) {
      final query = _searchQuery.toLowerCase();
      final nomorSurat = surat.nomorSurat?.toLowerCase() ?? '';
      final perihal = surat.perihal.toLowerCase();
      final tujuan = surat.tujuanSurat?.toLowerCase() ?? '';
      
      return nomorSurat.contains(query) || 
             perihal.contains(query) ||
             tujuan.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        body: RefreshIndicator(
          onRefresh: _loadSuratKeluar,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      'Galeri Surat Keluar',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: AppPallete.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Tab Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TabBar(
                      tabs: const [
                        Tab(text: 'Semua'),
                        Tab(text: 'Dengan File'),
                        Tab(text: 'Tanpa File'),
                      ],
                      onTap: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari surat...',
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
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Content
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadSuratKeluar,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final filteredList = _getFilteredSuratList();
    
    if (filteredList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off, color: Colors.grey.shade400, size: 60),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty 
                  ? 'Tidak ada surat keluar yang memiliki lampiran file'
                  : 'Tidak ditemukan hasil pencarian',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/transaksi-surat-keluar');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                ),
                child: const Text('Lihat Semua Surat Keluar'),
              ),
            ],
          ),
        ),
      );
    }
    
    return _buildFileGrid(filteredList);
  }

  Widget _buildFileGrid(List<Surat> suratList) {
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
      itemCount: suratList.length,
      itemBuilder: (context, index) {
        final surat = suratList[index];
        return _buildFileCard(surat);
      },
    );
  }

  Widget _buildFileCard(Surat surat) {
    // Cek apakah surat memiliki file atau tidak
    final bool hasFile = surat.file != null && surat.file!.isNotEmpty;
    
    // Set default untuk dokumen tanpa file
    Color cardColor = Colors.grey.shade100;
    IconData fileIcon = Icons.description;
    String fileExtension = "DOKUMEN";
    
    // Jika memiliki file, tentukan jenis file
    if (hasFile) {
      fileExtension = _getFileExtension(surat.file!).toUpperCase();
      
      // Set color and icon based on file type
      switch (fileExtension) {
        case 'PDF':
          cardColor = Colors.grey.shade200;
          fileIcon = Icons.picture_as_pdf;
          break;
        case 'DOCX':
        case 'DOC':
          cardColor = Colors.blue.shade100;
          fileIcon = Icons.description;
          break;
        case 'XLS':
        case 'XLSX':
          cardColor = Colors.green.shade100;
          fileIcon = Icons.table_chart;
          break;
        default:
          cardColor = Colors.grey.shade200;
          fileIcon = Icons.insert_drive_file;
      }
    }
    
    // Format tanggal untuk ID
    final formattedDate = surat.tanggalSurat != null 
      ? DateFormat('ddMMyy').format(surat.tanggalSurat!) 
      : '';
    
    // Buat file ID
    final fileId = 'SK-${surat.id ?? formattedDate}';

    return InkWell(
      onTap: () => hasFile ? _openFilePreview(surat) : _showSuratDetail(surat),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  Icon(fileIcon, size: 24, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasFile ? fileExtension : "DOKUMEN",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          fileId,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tampilkan badge jika tidak ada file
                  if (!hasFile)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Text(
                        'No File',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // File Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        surat.perihal,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Bottom action row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // View Button - different text based on whether there's a file
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => hasFile ? _openFilePreview(surat) : _showSuratDetail(surat),
                            icon: Icon(hasFile ? Icons.visibility : Icons.info_outline, size: 14),
                            label: Text(
                              hasFile ? 'Lihat File' : 'Detail',
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppPallete.primaryColor,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(20, 30),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        // Menu Button
                        IconButton(
                          onPressed: () => _showFileOptions(context, surat),
                          icon: const Icon(Icons.more_vert, size: 18),
                          splashRadius: 18,
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
      ));
    }
  
  void _showFileOptions(BuildContext context, Surat surat) {
    final bool hasFile = surat.file != null && surat.file!.isNotEmpty;
    
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
              if (hasFile) ...[
                ListTile(
                  leading: const Icon(Icons.remove_red_eye),
                  title: const Text('Lihat File'),
                  onTap: () {
                    Navigator.pop(context);
                    _openFilePreview(surat);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Unduh'),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadFile(surat);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Bagikan'),
                  onTap: () {
                    Navigator.pop(context);
                    _shareFile(surat);
                  },
                ),
              ],
              if (!hasFile) ...[
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Detail Surat'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSuratDetail(surat);
                  },
                ),
              ],
              // Opsi untuk semua jenis surat
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Surat'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigasi ke halaman edit
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => EditSuratPage(surat: surat)));
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper method untuk membuka preview file
  Future<void> _openFilePreview(Surat surat) async {
    if (surat.file == null || surat.file!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File tidak tersedia'), backgroundColor: Colors.red),
      );
      return;
    }
    
    try {
      print('🔍 Mencoba membuka file: ${surat.file}');
      
      // Tampilkan indikator loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Dapatkan URL file
      final fileUrl = await SuratService.getFileUrl(surat.file!);
      if (fileUrl.isEmpty) {
        throw Exception('URL file tidak valid');
      }
      
      print('🔗 URL File: $fileUrl');
      
      // Download file ke penyimpanan lokal
      final tempFile = await _downloadAndSaveFile(fileUrl, _getFileName(surat.file!));
      
      // Tutup dialog loading
      Navigator.pop(context);
      
      if (tempFile == null) {
        throw Exception('Gagal mengunduh file');
      }
      
      print('💾 File berhasil disimpan di: ${tempFile.path}');
      
      // Buka file lokal menggunakan open_file package
      final result = await OpenFile.open(tempFile.path);
      
      if (result.type != ResultType.done) {
        throw Exception('Tidak dapat membuka file: ${result.message}');
      }
      
      print('✅ File berhasil dibuka');
      
    } catch (e) {
      // Tutup dialog loading jika masih ada
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('❌ Error membuka file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka file: $e'), 
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Lihat URL',
            onPressed: () {
              _showFileUrlDetail(surat);
            },
          ),
        ),
      );
    }
  }
  
  // Tambahkan metode helper untuk download dan simpan file
  Future<File?> _downloadAndSaveFile(String url, String fileName) async {
    try {
      print('📥 Mengunduh file dari: $url');
      
      // Coba download file dengan http
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        print('❌ Download file gagal: HTTP ${response.statusCode}');
        return null;
      }
      
      // Dapatkan directory penyimpanan sementara
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      
      // Simpan file ke storage
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      
      return file;
    } catch (e) {
      print('❌ Error saat download file: $e');
      return null;
    }
  }
  
  // Helper method untuk mendapatkan nama file dari path
  String _getFileName(String filePath) {
    // Extract nama file dari path atau generate nama random jika perlu
    final uri = Uri.parse(filePath);
    String fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    
    if (fileName.isEmpty) {
      // Buat nama file random jika tidak dapat ekstrak
      fileName = 'dokumen_${DateTime.now().millisecondsSinceEpoch}.${_getFileExtension(filePath)}';
    }
    
    return fileName;
  }
  
  // Helper method untuk mengunduh file
  Future<void> _downloadFile(Surat surat) async {
    try {
      final fileUrl = await SuratService.getFileUrl(surat.file!);
      if (fileUrl.isNotEmpty) {
        final uri = Uri.parse(fileUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mengunduh file...'), backgroundColor: Colors.green),
          );
        } else {
          throw Exception('Tidak dapat mengunduh file');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh file: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  // Helper method untuk membagikan file
  Future<void> _shareFile(Surat surat) async {
    try {
      final fileUrl = await SuratService.getFileUrl(surat.file!);
      if (fileUrl.isNotEmpty) {
        await Share.share(
          'Bagikan dokumen: ${surat.perihal}\n$fileUrl',
          subject: 'Dokumen: ${surat.perihal}',
        );
      } else {
        throw Exception('URL file tidak tersedia');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membagikan file: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  // Helper untuk mendapatkan ekstensi file
  String _getFileExtension(String filePath) {
    if (filePath.isEmpty) return '';
    
    final parts = filePath.split('.');
    if (parts.length > 1) {
      return parts.last;
    }
    return '';
  }
  
  void _showSuratDetail(Surat surat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Surat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nomor Surat', surat.nomorSurat ?? '-'),
              _buildDetailRow('Perihal', surat.perihal),
              _buildDetailRow('Tujuan Surat', surat.tujuanSurat ?? '-'),
              _buildDetailRow('Tanggal', surat.tanggalSurat != null 
                ? DateFormat('dd MMMM yyyy').format(surat.tanggalSurat!) 
                : '-'),
              _buildDetailRow('Status', surat.status ?? '-'),
              const Divider(),
              _buildDetailRow('File', 'Dokumen ini tidak memiliki file terlampir', isWarning: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isWarning ? Colors.orange[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Di dalam _openFilePreview, tambahkan opsi ini untuk mengatasi URL yang tidak dapat dibuka langsung
  void _showOpenOptions(File localFile, String fileUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opsi Membuka File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih cara untuk membuka file:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('Buka di Browser'),
              onTap: () async {
                Navigator.pop(context);
                if (await canLaunchUrl(Uri.parse(fileUrl))) {
                  launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Buka dengan Aplikasi Lain'),
              onTap: () async {
                Navigator.pop(context);
                await OpenFile.open(localFile.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Bagikan File'),
              onTap: () async {
                Navigator.pop(context);
                await Share.shareXFiles([XFile(localFile.path)]);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  // Tambahkan fungsi ini setelah _downloadAndSaveFile atau sebelum _downloadFile
  void _showFileUrlDetail(Surat surat) async {
    if (surat.file == null || surat.file!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada file yang tersedia untuk ditampilkan'))
      );
      return;
    }

    final fileUrl = await SuratService.getFileUrl(surat.file!);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail URL File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Original Path: ${surat.file}'),
            const SizedBox(height: 8),
            Text('Generated URL: $fileUrl'),
            const SizedBox(height: 16),
            const Text('Salin URL ini dan coba buka di browser untuk memeriksa apakah file dapat diakses.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fileUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL disalin ke clipboard'))
              );
            },
            child: const Text('Salin URL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}