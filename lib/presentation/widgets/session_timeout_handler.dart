import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;
import 'package:surat_masuk_keluar_flutter/presentation/pages/login_page.dart';


class SessionTimeoutHandler extends StatefulWidget {
  final Widget child;
  
  const SessionTimeoutHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SessionTimeoutHandler> createState() => _SessionTimeoutHandlerState();
}

class _SessionTimeoutHandlerState extends State<SessionTimeoutHandler> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void handleSessionTimeout() {
    // Tampilkan dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Sesi Anda telah berakhir. Silahkan login kembali.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Login'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk diekspos ke global untuk menangani 401 error di mana saja
  static void handleAuthError(BuildContext context) {
    UserService.logout().then((_) {
      // Navigasi ke login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
      
      // Tampilkan snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session Anda telah berakhir. Silakan login kembali.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }
}