import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/disposisi.dart';
import 'package:surat_masuk_keluar_flutter/data/services/disposisi_service.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/detail_surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';

class DetailDisposisiPage extends StatefulWidget {
  final Disposisi disposisi;
  
  const DetailDisposisiPage({
    super.key,
    required this.disposisi,
  });

  @override
  State<DetailDisposisiPage> createState() => _DetailDisposisiPageState();
}

class _DetailDisposisiPageState extends State<DetailDisposisiPage> {
  late Disposisi _disposisi;
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _disposisi = widget.disposisi;
    
    // Load detail disposisi untuk mendapatkan data terkini
    _loadDisposisiDetail();
  }
  
  Future<void> _loadDisposisiDetail() async {
    if (_disposisi.id == null) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final updatedDisposisi = await DisposisiService.getDisposisiById(_disposisi.id!);
      
      setState(() {
        _disposisi = updatedDisposisi;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat detail disposisi: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updateStatus(String newStatus) async {
    if (_disposisi.id == null) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final updatedDisposisi = await DisposisiService.updateStatusDisposisi(
        _disposisi.id!,
        newStatus,
      );
      
      setState(() {
        _disposisi = updatedDisposisi;
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status disposisi diubah menjadi ${newStatus.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Gagal mengubah status disposisi: $e';
        _isLoading = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $_error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  const MyAppBar2(),
                  
                  const SizedBox(height: 12),
                  
                  // Judul
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Detail Disposisi',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _getStatusColor()),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(),
                          color: _getStatusColor(),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Status: ${_disposisi.statusFormatted}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Info Disposisi
                  _buildDisposisiInfo(),
                  
                  const SizedBox(height: 20),
                  
                  // Info Surat
                  if (_disposisi.surat != null)
                    _buildSuratCard(),
                    
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDisposisiInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Disposisi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoField('Dari', _disposisi.dariUserName),
            _buildInfoField('Kepada', _disposisi.kepadaUserName),
            _buildInfoField('Tanggal Disposisi', DateFormat('dd MMMM yyyy').format(_disposisi.tanggalDisposisi)),
            
            const SizedBox(height: 12),
            
            const Text(
              'Instruksi:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _disposisi.instruksi ?? '-',
                style: const TextStyle(height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuratCard() {
    final surat = _disposisi.surat!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informasi Surat',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // View Surat Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Lihat Surat'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailSuratMasuk(surat: surat),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoField('Nomor Surat', surat.nomorSurat),
            _buildInfoField('Perihal', surat.perihal),
            _buildInfoField('Tanggal Surat', DateFormat('dd MMMM yyyy').format(surat.tanggalSurat)),
            _buildInfoField('Asal Surat', surat.asalSurat),
            if (surat.tujuanSurat != null && surat.tujuanSurat!.isNotEmpty)
              _buildInfoField('Tujuan Surat', surat.tujuanSurat!),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    // Show different buttons depending on current status
    if (_disposisi.status.toLowerCase() == 'diajukan') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateStatus('ditindaklanjuti'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Tindak Lanjuti'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateStatus('selesai'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Selesai'),
              ),
            ),
          ],
        ),
      );
    } else if (_disposisi.status.toLowerCase() == 'ditindaklanjuti') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateStatus('selesai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Tandai Selesai'),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
  
  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor() {
    switch (_disposisi.status.toLowerCase()) {
      case 'diajukan':
        return Colors.blue;
      case 'ditindaklanjuti':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon() {
    switch (_disposisi.status.toLowerCase()) {
      case 'diajukan':
        return Icons.mark_email_unread;
      case 'ditindaklanjuti':
        return Icons.pending_actions;
      case 'selesai':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}