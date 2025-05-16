import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_profile_card.dart';

class MyAppBar2 extends StatelessWidget {
  const MyAppBar2({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        // Container(
        //   decoration: BoxDecoration(
        //     color: Colors.grey[200],
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: TextField(
        //     onChanged: (value) {
        //       // Aksi pencarian bisa ditaruh di sini
        //       print('Cari: $value');
        //     },
        //     decoration: const InputDecoration(
        //       hintText: 'Cari sesuatu...',
        //       prefixIcon: Icon(Icons.search),
        //       border: InputBorder.none,
        //       contentPadding:  EdgeInsets.symmetric(vertical: 15),
        //     ),
        //   ),
        // ),

        SizedBox(
          height: 55,
          width: MediaQuery.of(context).size.width * 0.65,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppPallete.borderColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                Text('Cari', style: GoogleFonts.poppins(fontSize: 12, color: AppPallete.textColor))
              ],
            ),
          ),
        ),

        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppPallete.borderColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: AppPallete.secondaryColor,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      try {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyProfileCard(),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error navigating to profile: $e")),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: const AssetImage('lib/assets/abdan.jpg'),
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint("Error loading profile image: $exception");
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
