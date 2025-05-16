import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/home_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_button2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_textfield.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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

                      // Form Field Email
                      const SizedBox(height: 30.0),
                      MyTextfield(
                          hintText: "Email",
                          controller: emailController,
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
                      MyButton2(
                        text: 'Sign In',
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                        }, 
                      )
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
