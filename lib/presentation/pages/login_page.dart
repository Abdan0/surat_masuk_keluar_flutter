import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/constants/api_constants.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/home_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nidnController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    nidnController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppPallete.errorColor : AppPallete.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Validasi input
    if (nidnController.text.isEmpty) {
      setState(() => _errorMessage = emailRequired);
      return;
    }
    
    if (passwordController.text.isEmpty) {
      setState(() => _errorMessage = passwordRequired);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Panggil service login
      final response = await login(nidnController.text, passwordController.text);

      // Cek response
      if (response.error != null) {
        setState(() => _errorMessage = response.error);
        _showSnackBar(response.error!, true);
      } else {
        // Login berhasil
        final user = response.data as User;
        _showSnackBar('Selamat datang, ${user.name}', false);
        
        // Navigasi ke home page
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const HomePage())
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      _showSnackBar(e.toString(), true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.secondaryColor,
      body: Column(
        children: [
          // Bagian Atas (30%)
          Expanded(
              flex: 3,
              child: Container(
                color: AppPallete.secondaryColor,
              )),

          // Bagian Bawah (70%)
          Expanded(
              flex: 7,
              child: Container(
                // Decoration Start
                decoration: const BoxDecoration(
                  color: AppPallete.backgroundColor,

                  // Border Radius
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),

                  // Shadow
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, -2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                // Decoration End

                // Padding Start
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login.',
                          style: GoogleFonts.poppins(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4.0,),
                        Text(
                          'Please Sign In To Continue',
                          style: GoogleFonts.poppins(
                              fontSize: 15.0, fontWeight: FontWeight.w300),
                        ),
    
                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppPallete.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppPallete.errorColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: AppPallete.errorColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
    
                        // Form Field NIDN
                        const SizedBox(height: 30.0),
                        MyTextfield(
                            hintText: "NIDN",
                            controller: nidnController,
                            obsecureText: false,
                        ),
    
                        // Form Field Password
                        const SizedBox(height: 15,),
                        MyTextfield(
                          controller: passwordController,
                          hintText: "Password",
                          obsecureText: true,
                        ),
    
                        // Remember Me Check Box
                        const SizedBox(height: 5.0,),
                        Row(
                          children: [
                            Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              ),
                              value: isChecked,
                              activeColor: const Color.fromARGB(235, 135, 206, 235),
                              onChanged: (newBool){
                                setState(() {
                                  isChecked = newBool!;
                                });
                              },
                            ),
                            Text('Remember Me', style: GoogleFonts.poppins(fontSize: 15, color: AppPallete.textColor, fontWeight: FontWeight.w500),)
                          ],
                        ),
    
                        // Login Button
                        const SizedBox(height: 15.0,),
                        _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : MyButton2(
                              text: 'Sign In',
                              onTap: _handleLogin,
                            )
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
