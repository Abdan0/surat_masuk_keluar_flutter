import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_date_field.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_table.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';

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
}

class AgendaSuratMasuk extends StatefulWidget {
  const AgendaSuratMasuk({super.key});

  @override
  State<AgendaSuratMasuk> createState() => _AgendaSuratMasukState();
}

class _AgendaSuratMasukState extends State<AgendaSuratMasuk> {
  final TextEditingController tanggalController = TextEditingController();
  // Sample data
  final List<SuratMasukData> _suratMasukList = [
    SuratMasukData(
      nomorAgenda: 'AG-001',
      nomorSurat: 'SM-001',
      pengirim: 'Rektorat',
      tanggalSurat: 'Jum\'at, 25 April 2025',
    ),
    SuratMasukData(
      nomorAgenda: 'AG-002',
      nomorSurat: 'SM-002',
      pengirim: 'Rektorat',
      tanggalSurat: 'Jum\'at, 25 April 2025',
    ),
    // Add more sample data as needed
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
                            controller: tanggalController,
                            label: 'Dari Tanggal',
                            hintText: 'Tanggal Mulai',
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: MyDateField(
                            controller: TextEditingController(),
                            label: 'Sampai Tanggal',
                            hintText: 'Tanggal Akhir',
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16), // Increased space
                    
                    // Filter and Print Buttons
                    Row(
                      children: [
                        // Filter Button
                        Expanded(
                          child: MyButton(
                            onTap: () {
                              // Implement filter logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Filtering data...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            text: 'Filter',
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Print Button
                        Expanded(
                          child: MyButton2(
                            onTap: () {
                              // Implement print logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mencetak agenda surat masuk...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
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

              // Use ResponsiveTable
              SizedBox(
                height: 200, // Give it a fixed height constraint
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
