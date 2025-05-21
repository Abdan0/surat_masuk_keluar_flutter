import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_profile_card.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/user_greeting_widget.dart';

class MyAppbar extends StatefulWidget {
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const MyAppbar({
    super.key, 
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  State<MyAppbar> createState() => _MyAppbarState();
}

class _MyAppbarState extends State<MyAppbar> {
  User? _userData;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('❌ Error loading user data for AppBar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Using the separated user greeting widget
        const Expanded(child: UserGreetingWidget()),
        
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPallete.borderColor,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  // Notification icon with badge if there are notifications
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: widget.onNotificationTap,
                        child: const Icon(
                          Icons.notifications_active,
                          color: AppPallete.secondaryColor,
                        ),
                      ),
                      if (widget.notificationCount > 0)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              widget.notificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  
                  // User profile avatar
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
                    child: _isLoading
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : CircleAvatar(
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
