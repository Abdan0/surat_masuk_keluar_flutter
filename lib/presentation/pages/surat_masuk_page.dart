import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/home_page.dart';

class SuratMasukPage extends StatefulWidget {
  const SuratMasukPage({super.key});

  @override
  State<SuratMasukPage> createState() => _SuratMasukPageState();
}

class _SuratMasukPageState extends State<SuratMasukPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body
      
      // navbar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: AppPallete.secondaryColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 18.0),
          child: GNav(
            gap: 6,
            backgroundColor: AppPallete.secondaryColor,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: AppPallete.primaryColor,
            padding: const EdgeInsets.all(16),
            onTabChange: (index) {
              switch (index) {
                case 0:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                  break;
                case 1:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SuratMasukPage()));
                  break;
                case 2:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                  break;
                case 3:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                  break;
              }
            },
            tabs: const [
              GButton(
                icon: Icons.home_filled,
                text: "Home",
              ),
              GButton(
                icon: Icons.mark_email_read_rounded,
                text: "Surat Masuk",
              ),
              GButton(
                icon: Icons.mark_email_unread,
                text: "Surat Keluar",
              ),
              GButton(
                icon: Icons.bookmark,
                text: "Disposisi",
              ),
            ],
          ),
        ),
      ),
    );
  }
}