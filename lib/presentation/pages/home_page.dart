import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/surat_masuk_page.dart';
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

              // Menu
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Transaksi Surat Section
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaksi Surat', // teks di luar border
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppPallete.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                                height: 8), // jarak antara teks dan border
                            IntrinsicWidth(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppPallete.borderColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MyMenu(
                                            icon: Icons.mark_email_unread,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const TrSuratMasukPage(),
                                                ),
                                              );
                                            },
                                          ),
                                          MyMenu(
                                            icon: Icons.mark_email_read,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SuratMasukPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  
                      //Buku Agenda Section
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buku Agenda', // teks di luar border
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppPallete.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                                height: 8), // jarak antara teks dan border
                            IntrinsicWidth(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppPallete.borderColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MyMenu(
                                            icon: Icons.mark_email_unread,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SuratMasukPage(),
                                                ),
                                              );
                                            },
                                          ),
                                          MyMenu(
                                            icon: Icons.mark_email_read,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SuratMasukPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Galeri Section
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Galeri Surat',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppPallete.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                                height: 8),
                            IntrinsicWidth(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppPallete.borderColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MyMenu(
                                            icon: Icons.mark_email_unread,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SuratMasukPage(),
                                                ),
                                              );
                                            },
                                          ),
                                          MyMenu(
                                            icon: Icons.mark_email_read,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SuratMasukPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
