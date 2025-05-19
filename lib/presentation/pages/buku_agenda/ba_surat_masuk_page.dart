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

  // Filter agenda by date range
  List<Agenda> _filterAgendaByDateRange(List<Agenda> agendaList) {
    if (_startDate == null && _endDate == null) {
      return agendaList; // No filter applied
    }
    
    return agendaList.where((agenda) {
      // Apply start date filter
      if (_startDate != null && agenda.tanggalAgenda.isBefore(_startDate!)) {
        return false;
      }
      
      // Apply end date filter
      if (_endDate != null) {
        // Add 1 day to include the end date in results
        final endDatePlusOne = _endDate!.add(const Duration(days: 1));
        if (agenda.tanggalAgenda.isAfter(endDatePlusOne)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  // Handle filter button click
  void _handleFilter() {
    _startDate = _parseDateInput(_startDateController.text);
    _endDate = _parseDateInput(_endDateController.text);
    
    _loadAgendaSuratMasuk();
  }

  // Parse date from input field
  DateTime? _parseDateInput(String date) {
    if (date.isEmpty) return null;
    
    try {
      // Parse from dd/MM/yyyy format
      final parts = date.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
      return null;
    } catch (e) {
      print('Error parsing date: $e');
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

                const SizedBox(height: 20),

                // Page Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Agenda Surat Masuk',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
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
                  
                const SizedBox(height: 20),

                // Display status messages
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                // Ganti tampilan error dengan yang lebih informatif
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
                else if (_suratMasukList.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, 
                              color: Colors.grey.shade400, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada data agenda surat masuk',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Use ResponsiveTable with real data
                  Container(
                    constraints: const BoxConstraints(minHeight: 200),
                    child: ResponsiveTable<SuratMasukData>(
                      columns: const [
                        'Nomor Agenda',
                        'Nomor Surat',
                        'Pengirim',
                        'Tanggal Surat',
                      ],
                      data: _suratMasukList,
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
                      // Ubah onRowTap menjadi onTap
                      onTap: (item, index) {
                        // Navigate to agenda detail page
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tapped on agenda: ${item.nomorAgenda}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
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
