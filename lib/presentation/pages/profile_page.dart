import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_profile_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),

        child: Column(
          children: [
            //Porfile Card
            MyProfileCard(),
          ],
        ),
      ),
    );
  }
}