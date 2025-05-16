import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_profile_card.dart';

class MyAppbar extends StatelessWidget {
  const MyAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello.",
              style: GoogleFonts.poppins(
                  color: AppPallete.textColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "Abdan",
              style: GoogleFonts.poppins(
                  color: AppPallete.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
          children: [
            Container(
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
