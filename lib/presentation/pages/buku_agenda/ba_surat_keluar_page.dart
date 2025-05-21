import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/agenda.dart';
import 'package:surat_masuk_keluar_flutter/data/services/agenda_service.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_date_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_table.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
// Tambahkan import PdfGenerator
import 'package:surat_masuk_keluar_flutter/utils/pdf_generator.dart';

// Class untuk wrapper data surat keluar di tabel
class SuratKeluarData {
  final String nomorAgenda;
  final String nomorSurat;
  final String tujuan;
  final String tanggalSurat;

  SuratKeluarData({
    required this.nomorAgenda,
    required this.nomorSurat,
    required this.tujuan,
    required this.tanggalSurat,
  });

  // Factory untuk membuat SuratKeluarData dari objek Agenda
  factory SuratKeluarData.fromAgenda(Agenda agenda) {
    String tanggalFormatted;
    
    try {
      tanggalFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID')
          .format(agenda.tanggalAgenda);
    } catch (e) {
      print('Error formatting date: $e');
      tanggalFormatted = '-';
    }
    
    String? nomorSurat;
    String? tujuan; // Rename variabel untuk kejelasan
    
    try {
      nomorSurat = agenda.surat?.nomorSurat;
    } catch (e) {
      print('Error accessing surat.nomorSurat: $e');
    }
    
    try {
      // PERBAIKAN: Mengambil tujuan surat, bukan pengirim
      tujuan = agenda.surat?.tujuanSurat ?? agenda.penerima;
    } catch (e) {
      print('Error accessing tujuan surat: $e');
    }
    
    return SuratKeluarData(
      nomorAgenda: agenda.nomorAgenda,
      nomorSurat: nomorSurat ?? '-',
      tujuan: tujuan ?? '-', // Pastikan tujuan ditampilkan dengan benar
      tanggalSurat: tanggalFormatted,
    );
  }
}

class AgendaSuratKeluar extends StatefulWidget {
  const AgendaSuratKeluar({super.key});

  @override
  State<AgendaSuratKeluar> createState() => _AgendaSuratKeluarState();
}

class _AgendaSuratKeluarState extends State<AgendaSuratKeluar> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  List<SuratKeluarData> _suratKeluarList = [];
  List<Agenda> _agendaList = [];
  bool _isLoading = false;
  String? _error;
  
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = ''; // Tambahkan variabel untuk pencarian

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadAgendaSuratKeluar();
  }

  // Load agenda surat keluar from API
  Future<void> _loadAgendaSuratKeluar() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get all agendas with fallback
      print('📥 Memuat data agenda...');
      final agendaList = await AgendaService.getAgendaListWithFallback();
      print('✅ Berhasil memuat ${agendaList.length} agenda');
      
      // Filter only surat keluar agendas
      final suratKeluarAgendas = agendaList.where((agenda) {
        // Debug untuk melihat data
        print('🔍 Memeriksa agenda: ${agenda.nomorAgenda}');
        print('  - Surat tipe: ${agenda.surat?.tipe}');
        print('  - Penerima: ${agenda.penerima}');
        print('  - Tujuan surat: ${agenda.surat?.tujuanSurat}');
        
        // 1. Prioritaskan pemeriksaan nomor agenda
        if (agenda.nomorAgenda.startsWith('AK-')) {
          return true;
        }
        
        // 2. Periksa surat jika ada
        if (agenda.surat != null) {
          try {
            final tipe = agenda.surat!.tipe.toLowerCase();
            if (tipe == 'keluar') {
              return true;
            }
          } catch (e) {
            print('⚠️ Error accessing surat.tipe: $e');
          }
        }
        
        // 3. Atau menggunakan field penerima untuk surat keluar (bukan pengirim)
        if (agenda.penerima != null && agenda.penerima!.isNotEmpty) {
          return true;
        }
        
        return false;
      }).toList();
      
      print('📊 Ditemukan ${suratKeluarAgendas.length} agenda surat keluar');
      
      // Filter by date if filters are applied
      final filteredAgendas = _filterAgendaByDateRange(suratKeluarAgendas);
      
      if (!mounted) return;
      
      setState(() {
        _agendaList = filteredAgendas;
        _suratKeluarList = filteredAgendas
            .map((agenda) => SuratKeluarData.fromAgenda(agenda))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error dalam _loadAgendaSuratKeluar: $e');
      if (!mounted) return;
      
      setState(() {
        _error = 'Gagal memuat data agenda: $e';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $_error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Filter agenda by date range
  List<Agenda> _filterAgendaByDateRange(List<Agenda> agendaList) {
    if (_startDate == null && _endDate == null) {
      print('⚠️ Tidak ada filter tanggal yang diterapkan');
      return agendaList; // No filter applied
    }
    
    // Mencatat jumlah agenda sebelum filter
    final beforeCount = agendaList.length;
    
    // Menormalkan waktu untuk perbandingan yang adil
    final normalizedStartDate = _startDate != null 
        ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day) 
        : null;
    
    final normalizedEndDate = _endDate != null 
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59) 
        : null;
    
    final filteredList = agendaList.where((agenda) {
      // Normalisasi tanggal agenda juga
      final agendaDate = DateTime(
        agenda.tanggalAgenda.year,
        agenda.tanggalAgenda.month,
        agenda.tanggalAgenda.day,
      );
      
      // Debug untuk memeriksa pembandingan tanggal
      if (normalizedStartDate != null || normalizedEndDate != null) {
        print('🗓️ Periksa agenda ${agenda.nomorAgenda} tanggal ${DateFormat('dd/MM/yyyy').format(agenda.tanggalAgenda)}');
      }
      
      // Apply start date filter
      if (normalizedStartDate != null) {
        final isAfterStart = agendaDate.isAtSameMomentAs(normalizedStartDate) || 
                            agendaDate.isAfter(normalizedStartDate);
        if (!isAfterStart) {
          print('❌ Agenda ${agenda.nomorAgenda} sebelum tanggal mulai');
          return false;
        }
      }
      
      // Apply end date filter
      if (normalizedEndDate != null) {
        final isBeforeEnd = agendaDate.isAtSameMomentAs(normalizedEndDate) || 
                           agendaDate.isBefore(normalizedEndDate);
        if (!isBeforeEnd) {
          print('❌ Agenda ${agenda.nomorAgenda} setelah tanggal akhir');
          return false;
        }
      }
      
      print('✅ Agenda ${agenda.nomorAgenda} dalam rentang tanggal filter');
      return true;
    }).toList();
    
    // Mencatat jumlah agenda setelah filter
    print('📊 Filter tanggal: ${beforeCount} agenda → ${filteredList.length} agenda');
    
    return filteredList;
  }

  // Handle filter button click
  void _handleFilter() {
    // Parse tanggal dengan mempertimbangkan format yang benar
    _startDate = _parseDateInput(_startDateController.text);
    _endDate = _parseDateInput(_endDateController.text);
    
    // Debug untuk melihat tanggal yang dipilih
    if (_startDate != null) {
      print('🔍 Filter tanggal mulai: ${DateFormat('dd/MM/yyyy').format(_startDate!)}');
    } else {
      print('🔍 Filter tanggal mulai: tidak diatur');
    }
    
    if (_endDate != null) {
      print('🔍 Filter tanggal akhir: ${DateFormat('dd/MM/yyyy').format(_endDate!)}');
    } else {
      print('🔍 Filter tanggal akhir: tidak diatur');
    }
    
    // Reload data dengan filter baru
    _loadAgendaSuratKeluar();
  }

  // Parse date from input field dengan lebih robust
  DateTime? _parseDateInput(String date) {
    if (date.isEmpty) return null;
    
    try {
      // Coba parse dengan format dd/MM/yyyy
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.parse(date);
    } catch (e) {
      // Jika gagal, coba parse dengan format alternatif
      try {
        final parts = date.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e2) {
        print('Error parsing date: $e2');
      }
      
      print('Error parsing date: $e');
      return null;
    }
  }

  // Handle print button click
  Future<void> _handlePrint() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Format dates for PDF header
      String? formattedStartDate;
      String? formattedEndDate;
      
      if (_startDate != null) {
        formattedStartDate = DateFormat('dd/MM/yyyy').format(_startDate!);
      }
      
      if (_endDate != null) {
        formattedEndDate = DateFormat('dd/MM/yyyy').format(_endDate!);
      }
      
      // Generate and open PDF
      final pdfFile = await PdfGenerator.generateAgendaSuratKeluarPdf(
        _agendaList,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      await PdfGenerator.openPdf(pdfFile);
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mencetak: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadAgendaSuratKeluar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                const MyAppBar2(),

                const SizedBox(height: 16),
                
                // Search Bar - tambahkan search bar di sini
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari agenda...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
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

                // Page Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Agenda Surat Keluar',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppPallete.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),

                const SizedBox(height: 16),

                // Filter and Print Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      // Filter Fields
                      Row(
                        children: [
                          // Date Range Filter
                          Expanded(
                            child: MyDateField(
                              controller: _startDateController,
                              label: 'Dari Tanggal',
                              hintText: 'Tanggal Mulai',
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: MyDateField(
                              controller: _endDateController,
                              label: 'Sampai Tanggal',
                              hintText: 'Tanggal Akhir',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Filter and Print Buttons
                      Row(
                        children: [
                          // Filter Button
                          Expanded(
                            child: MyButton(
                              onTap: _handleFilter,
                              text: 'Filter',
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Print Button
                          Expanded(
                            child: MyButton2(
                              onTap: _handlePrint,
                              text: 'Cetak',
                              icon: Icons.print,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                  
                const SizedBox(height: 16),
                
                // Implementasikan filter berdasarkan search query
                if (_searchQuery.isNotEmpty && !_isLoading && _error == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Hasil pencarian untuk "$_searchQuery"',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppPallete.textColor,
                      ),
                    ),
                  ),

                // Display status messages
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, 
                              color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Gagal memuat data agenda',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _error!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadAgendaSuratKeluar,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Muat Ulang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallete.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildAgendaTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAgendaTable() {
    // Filter agenda berdasarkan search query
    final filteredSuratList = _searchQuery.isEmpty 
      ? _suratKeluarList 
      : _suratKeluarList.where((surat) {
          final query = _searchQuery.toLowerCase();
          final nomorAgenda = surat.nomorAgenda.toLowerCase();
          final nomorSurat = surat.nomorSurat.toLowerCase();
          final tujuan = surat.tujuan.toLowerCase();
          
          return nomorAgenda.contains(query) || 
                 nomorSurat.contains(query) ||
                 tujuan.contains(query);
        }).toList();

    if (filteredSuratList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                _searchQuery.isEmpty ? Icons.inbox : Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty 
                  ? 'Tidak ada data agenda surat keluar' 
                  : 'Tidak ada hasil untuk "$_searchQuery"',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      child: ResponsiveTable<SuratKeluarData>(
        columns: const [
          'Nomor Agenda',
          'Nomor Surat',
          'Tujuan',
          'Tanggal Surat',
        ],
        data: filteredSuratList,
        cellBuilders: [
          (item) => Text(item.nomorAgenda),
          (item) => Text(item.nomorSurat),
          (item) => Text(item.tujuan),
          (item) => Text(item.tanggalSurat),
        ],
        headerBackgroundColor: Colors.grey.shade300,
        rowBackgroundColor: Colors.grey.shade200,
        borderColor: Colors.grey.shade400,
        headerStyle: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        cellStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 14,
        ),
        onTap: (item, index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on agenda: ${item.nomorAgenda}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}