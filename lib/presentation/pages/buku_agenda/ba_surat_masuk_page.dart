import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/agenda.dart';
import 'package:surat_masuk_keluar_flutter/data/services/agenda_service.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_date_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_table.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/utils/pdf_generator.dart';
// Class untuk wrapper data surat masuk di tabel
class SuratMasukData {
  final String nomorAgenda;
  final String nomorSurat;
  final String pengirim;
  final String tanggalSurat;

  SuratMasukData({
    required this.nomorAgenda,
    required this.nomorSurat,
    required this.pengirim,
    required this.tanggalSurat,
  });

  // Factory untuk membuat SuratMasukData dari objek Agenda
  factory SuratMasukData.fromAgenda(Agenda agenda) {
    print('🔍 Membuat SuratMasukData dari Agenda: ${agenda.nomorAgenda}');
    
    String tanggalFormatted;
    try {
      tanggalFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID')
          .format(agenda.tanggalAgenda);
      print('📅 Format tanggal berhasil: $tanggalFormatted');
    } catch (e) {
      print('⚠️ Error formatting date: $e');
      tanggalFormatted = '-';
    }
    
    String nomorSurat = '-';
    String pengirim = '-';
    
    try {
      if (agenda.surat?.nomorSurat != null) {
        nomorSurat = agenda.surat!.nomorSurat;
        print('📄 Nomor surat diambil: $nomorSurat');
      }
    } catch (e) {
      print('⚠️ Error accessing nomor surat: $e');
    }
    
    try {
      pengirim = agenda.surat?.asalSurat ?? agenda.pengirim ?? '-';
      print('👤 Pengirim diambil: $pengirim');
    } catch (e) {
      print('⚠️ Error accessing asal surat: $e');
    }
    
    final result = SuratMasukData(
      nomorAgenda: agenda.nomorAgenda,
      nomorSurat: nomorSurat,
      pengirim: pengirim,
      tanggalSurat: tanggalFormatted,
    );
    
    print('✅ SuratMasukData berhasil dibuat');
    return result;
  }
}

class AgendaSuratMasuk extends StatefulWidget {
  const AgendaSuratMasuk({super.key});

  @override
  State<AgendaSuratMasuk> createState() => _AgendaSuratMasukState();
}

class _AgendaSuratMasukState extends State<AgendaSuratMasuk> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  List<SuratMasukData> _suratMasukList = [];
  List<Agenda> _agendaList = [];
  bool _isLoading = false;
  String? _error;
  
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = ''; // Tambahkan variabel untuk pencarian

  // Tambahkan variabel untuk tracking operasi async
  bool _disposed = false;
  
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadAgendaSuratMasuk();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  
  // Metode helper untuk setState yang aman
  void setStateIfMounted(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }
  
  // Load agenda surat masuk from API
  Future<void> _loadAgendaSuratMasuk() async {
    setStateIfMounted(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Get all agendas with fallback
      print('📥 Memuat data agenda...');
      final agendaList = await AgendaService.getAgendaListWithFallback();
      print('✅ Berhasil memuat ${agendaList.length} agenda');
      
      // Filter only surat masuk agendas
      final suratMasukAgendas = agendaList.where((agenda) {
        // 1. Prioritaskan pemeriksaan nomor agenda
        if (agenda.nomorAgenda.startsWith('AM-')) {
          return true;
        }
        
        // 2. Periksa surat jika ada
        if (agenda.surat != null) {
          try {
            return agenda.surat!.tipe.toLowerCase() == 'masuk';
          } catch (e) {
            print('⚠️ Error accessing surat.tipe: $e');
          }
        }
        
        // 3. Atau menggunakan field pengirim
        if (agenda.pengirim != null && agenda.pengirim!.isNotEmpty) {
          return true;
        }
        
        return false;
      }).toList();
      
      print('📊 Ditemukan ${suratMasukAgendas.length} agenda surat masuk');
      
      // Filter by date if filters are applied
      final filteredAgendas = _filterAgendaByDateRange(suratMasukAgendas);
      
      setStateIfMounted(() {
        _agendaList = filteredAgendas;
        _suratMasukList = filteredAgendas
            .map((agenda) => SuratMasukData.fromAgenda(agenda))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error dalam _loadAgendaSuratMasuk: $e');
      setStateIfMounted(() {
        _error = 'Gagal memuat data agenda: $e';
        _isLoading = false;
      });
      
      if (!_disposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Tambahkan method validasi range tanggal
  bool _isValidDateRange() {
    if (_startDate != null && _endDate != null) {
      // Normalisasi tanggal untuk perbandingan yang adil
      final normalizedStartDate = DateTime(
        _startDate!.year, 
        _startDate!.month, 
        _startDate!.day
      );
      final normalizedEndDate = DateTime(
        _endDate!.year, 
        _endDate!.month, 
        _endDate!.day
      );
      
      if (normalizedStartDate.isAfter(normalizedEndDate)) {
        return false;
      }
    }
    return true;
  }

  // Filter agenda by date range
  List<Agenda> _filterAgendaByDateRange(List<Agenda> agendaList) {
    if (_startDate == null && _endDate == null) {
      print('ℹ️ Tidak ada filter tanggal yang diterapkan');
      return agendaList;
    }
    
    // Validasi range tanggal
    if (!_isValidDateRange()) {
      print('❌ Range tanggal tidak valid');
      return []; // Return list kosong jika range tidak valid
    }
    
    // Normalisasi waktu untuk perbandingan
    final normalizedStartDate = _startDate != null 
        ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day) 
        : null;
    
    final normalizedEndDate = _endDate != null 
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59) 
        : null;
    
    print('🔍 Filter tanggal:');
    if (normalizedStartDate != null) {
      print('  Dari: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(normalizedStartDate)}');
    }
    if (normalizedEndDate != null) {
      print('  Sampai: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(normalizedEndDate)}');
    }
    
    final filteredList = agendaList.where((agenda) {
      // Normalisasi tanggal agenda
      final agendaDate = DateTime(
        agenda.tanggalAgenda.year,
        agenda.tanggalAgenda.month,
        agenda.tanggalAgenda.day,
      );
      
      // Debug info
      print('👉 Memeriksa agenda ${agenda.nomorAgenda} tanggal ${DateFormat('yyyy-MM-dd').format(agendaDate)}');
      
      // Apply start date filter
      if (normalizedStartDate != null) {
        final bool isAfterStart = agendaDate.isAtSameMomentAs(normalizedStartDate) || 
                                 agendaDate.isAfter(normalizedStartDate);
        print('  ✓ Setelah tanggal mulai? $isAfterStart');
        if (!isAfterStart) return false;
      }
      
      // Apply end date filter
      if (normalizedEndDate != null) {
        final bool isBeforeEnd = agendaDate.isAtSameMomentAs(normalizedEndDate) || 
                                agendaDate.isBefore(normalizedEndDate);
        print('  ✓ Sebelum tanggal akhir? $isBeforeEnd');
        if (!isBeforeEnd) return false;
      }
      
      // Jika lolos kedua filter
      print('  ✅ Agenda ${agenda.nomorAgenda} diterima');
      return true;
    }).toList();
    
    // Log hasil filter
    print('📊 Filter tanggal: Dari ${agendaList.length} agenda -> ${filteredList.length} agenda');
    
    return filteredList;
  }

  // Handle filter button click
  void _handleFilter() {
    print('🔍 Memulai filter dengan input:');
    print('  Dari: ${_startDateController.text}');
    print('  Sampai: ${_endDateController.text}');
    
    // Parse input tanggal
    _startDate = _parseDateInput(_startDateController.text);
    _endDate = _parseDateInput(_endDateController.text);
    
    // Validasi range tanggal
    if (!_isValidDateRange()) {
      setState(() {
        _error = 'Tanggal awal tidak boleh lebih besar dari tanggal akhir';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal awal tidak boleh lebih besar dari tanggal akhir'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    if (_startDate != null) {
      print('✓ Tanggal mulai diset: ${DateFormat('dd/MM/yyyy').format(_startDate!)}');
    } else {
      print('ℹ️ Tanggal mulai tidak diatur');
    }
    
    if (_endDate != null) {
      print('✓ Tanggal akhir diset: ${DateFormat('dd/MM/yyyy').format(_endDate!)}');
    } else {
      print('ℹ️ Tanggal akhir tidak diatur');
    }
    
    _loadAgendaSuratMasuk();
  }

  // Parse date from input field
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
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          
          // Validasi tanggal
          if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1900) {
            return DateTime(year, month, day);
          }
        }
        print('⚠️ Format tanggal tidak valid: $date');
      } catch (e2) {
        print('⚠️ Error parsing date dalam format alternatif: $e2');
      }
      
      print('⚠️ Error parsing date: $e');
      return null;
    }
  }

  // Handle print button click
  Future<void> _handlePrint() async {
    // Cek mounted sebelum update state
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
      final pdfFile = await PdfGenerator.generateAgendaSuratMasukPdf(
        _agendaList,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );
      
      // Cek mounted sebelum update state
      if (!mounted) return;
    
      setState(() {
        _isLoading = false;
      });
      
      await PdfGenerator.openPdf(pdfFile);
      
    } catch (e) {
      // Cek mounted sebelum update state
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
        onRefresh: _loadAgendaSuratMasuk,
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
                    'Agenda Surat Masuk',
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
                              onDateSelected: () {
                                // Parse tanggal secara otomatis saat user memilih
                                _startDate = _parseDateInput(_startDateController.text);
                                print('🗓️ Tanggal mulai diubah: ${_startDateController.text}');
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: MyDateField(
                              controller: _endDateController,
                              label: 'Sampai Tanggal',
                              hintText: 'Tanggal Akhir',
                              onDateSelected: () {
                                // Parse tanggal secara otomatis saat user memilih
                                _endDate = _parseDateInput(_endDateController.text);
                                print('🗓️ Tanggal akhir diubah: ${_endDateController.text}');
                              },
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
                      
                      const SizedBox(height: 8),
                      
                      // Di bawah tombol Filter dan Cetak, tambahkan tombol reset
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _startDateController.clear();
                            _endDateController.clear();
                            _startDate = null;
                            _endDate = null;
                          });
                          _loadAgendaSuratMasuk();
                        },
                        tooltip: 'Reset Filter',
                        icon: const Icon(Icons.clear_all),
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
                            onPressed: _loadAgendaSuratMasuk,
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
      ? _suratMasukList 
      : _suratMasukList.where((surat) {
          final query = _searchQuery.toLowerCase();
          final nomorAgenda = surat.nomorAgenda.toLowerCase();
          final nomorSurat = surat.nomorSurat.toLowerCase();
          final pengirim = surat.pengirim.toLowerCase();
          
          return nomorAgenda.contains(query) || 
                 nomorSurat.contains(query) ||
                 pengirim.contains(query);
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
                  ? 'Tidak ada data agenda surat masuk' 
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
      child: ResponsiveTable<SuratMasukData>(
        columns: const [
          'Nomor Agenda',
          'Nomor Surat',
          'Pengirim',
          'Tanggal Surat',
        ],
        data: filteredSuratList,
        cellBuilders: [
          (item) => Text(item.nomorAgenda),
          (item) => Text(item.nomorSurat),
          (item) => Text(item.pengirim),
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
      ));
  }
}
