import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/buku_agenda/ba_surat_keluar_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/buku_agenda/ba_surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/galeri_surat/galeri_surat_keluar.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/galeri_surat/galeri_surat_masu.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/tr_surat_keluar_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/tr_surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_appbar.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_menu.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_piecard.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_usercard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Page Controller
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              //appbar
              const MyAppbar(),

              const SizedBox(
                height: 30,
              ),

              //pie chart
              SizedBox(
                height: 350,
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  children: const [
                    MyUsercard(),
                    MyPiecard(
                        surat: "Surat Masuk",
                        tahunSurat: "2025",
                        suratDone: 20,
                        suratNew: 10,
                        suratProcess: 10),
                    MyPiecard(
                        surat: "Surat Keluar",
                        tahunSurat: "2025",
                        suratDone: 35,
                        suratNew: 10,
                        suratProcess: 10),
                  ],
                ),
              ),

              SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect:
                    ExpandingDotsEffect(activeDotColor: Colors.grey.shade700),
              ),


              const SizedBox(height: 16,),

              // Menu
              Column(
                children: [
                  // Wrap in LayoutBuilder for responsive sizing
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate dynamic sizes based on available width
                      final availableWidth = constraints.maxWidth;
                      final sectionWidth = availableWidth * 0.48; // Give each section ~48% of width
                      
                      return Column(
                        children: [
                          // First row with Transaksi Surat and Buku Agenda
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Transaksi Surat Section
                              _buildMenuSection(
                                context,
                                'Transaksi Surat',
                                sectionWidth,
                                [
                                  MenuItemData(
                                    icon: Icons.mark_email_unread,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const TrSuratMasukPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  MenuItemData(
                                    icon: Icons.mark_email_read,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const TrSuratKeluarPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              
                              //Buku Agenda Section
                              _buildMenuSection(
                                context,
                                'Buku Agenda',
                                sectionWidth,
                                [
                                  MenuItemData(
                                    icon: Icons.mark_email_unread,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AgendaSuratMasuk(),
                                        ),
                                      );
                                    },
                                  ),
                                  MenuItemData(
                                    icon: Icons.mark_email_read,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AgendaSuratKeluar(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Second row with Galeri Surat (centered)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //Galeri Section
                              _buildMenuSection(
                                context,
                                'Galeri Surat',
                                sectionWidth,
                                [
                                  MenuItemData(
                                    icon: Icons.mark_email_unread,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const GaleriSuratMasuk(),
                                        ),
                                      );
                                    },
                                  ),
                                  MenuItemData(
                                    icon: Icons.mark_email_read,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const GaleriSuratKeluar(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
    // Helper method to create consistent menu sections
  Widget _buildMenuSection(
    BuildContext context,
    String title,
    double width,
    List<MenuItemData> menuItems,
  ) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, // section title
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppPallete.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity, // Take full width of parent
            decoration: BoxDecoration(
              border: Border.all(
                color: AppPallete.borderColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: menuItems.map((item) => 
                Flexible(
                  child: MyMenu(
                    icon: item.icon,
                    onTap: item.onTap,
                  ),
                )
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
class MenuItemData {
  final IconData icon;
  final VoidCallback onTap;

  MenuItemData({required this.icon, required this.onTap});
}
