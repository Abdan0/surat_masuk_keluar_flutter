import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';

class UserGreetingWidget extends StatefulWidget {
  const UserGreetingWidget({super.key});

  @override
  State<UserGreetingWidget> createState() => _UserGreetingWidgetState();
}

class _UserGreetingWidgetState extends State<UserGreetingWidget> {
  bool _isLoading = true;
  User? _userData;

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
      
      // Jika tidak bisa mendapatkan data user, coba refresh
      if (userData == null) {
        _refreshUserData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('❌ Error loading user data for greeting: $e');
    }
  }
  
  Future<void> _refreshUserData() async {
    try {
      final userData = await UserService.refreshUserData();
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error refreshing user data for greeting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello.",
          style: GoogleFonts.poppins(
              color: AppPallete.textColor,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        _isLoading
            ? SizedBox(
                height: 20,
                width: 80,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  color: AppPallete.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            : Text(
                _userData?.name ?? "User",
                style: GoogleFonts.poppins(
                    color: AppPallete.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
      ],
    );
  }
}