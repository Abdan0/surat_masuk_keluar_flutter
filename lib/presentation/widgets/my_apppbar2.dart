import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_profile_card.dart';

class MyAppBar2 extends StatelessWidget {
  const MyAppBar2({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate sizes based on available width
        final searchBarWidth = constraints.maxWidth * (isSmallScreen ? 0.58 : 0.62);
        final profileWidth = constraints.maxWidth * (isSmallScreen ? 0.38 : 0.34);
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Bar
            Flexible(
              child: Container(
                height: 55,
                width: searchBarWidth,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 18, 
                  horizontal: isSmallScreen ? 8 : 12
                ),
                margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 10),
                decoration: BoxDecoration(
                  color: AppPallete.borderColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search, 
                      size: isSmallScreen ? 18 : 24
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Expanded(
                      child: Text(
                        'Cari', 
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12, 
                          color: AppPallete.textColor
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile & Notification Section
            Container(
              width: profileWidth,
              margin: EdgeInsets.only(right: isSmallScreen ? 4 : 8),
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 8 : 10,
                horizontal: isSmallScreen ? 8 : 10
              ),
              decoration: BoxDecoration(
                color: AppPallete.borderColor,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: AppPallete.secondaryColor,
                    size: isSmallScreen ? 18 : 24,
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 15),
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
                      radius: isSmallScreen ? 16 : 20,
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
        );
      }
    );
  }
}
