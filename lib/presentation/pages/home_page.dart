import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
import 'package:surat_masuk_keluar_flutter/data/services/disposisi_service.dart';
import 'package:surat_masuk_keluar_flutter/data/services/notifikasi_service.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;
import 'package:surat_masuk_keluar_flutter/presentation/pages/buku_agenda/ba_surat_keluar_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/buku_agenda/ba_surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/galeri_surat/galeri_surat_keluar.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/galeri_surat/galeri_surat_masu.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/notifikasi/notifikasi_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/tr_surat_keluar_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/tr_surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/user_management/user_management_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_appbar.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_menu.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_piecard.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_usercard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Page Controller
  final _controller = PageController();
  
  // Notifikasi count untuk disposisi yang belum dibaca
  int _notificationCount = 0;
  bool _isLoadingNotifications = false;
  
  // User role untuk menampilkan menu sesuai role
  String? _userRole;
  bool _isLoadingUserData = false;

  @override
  void initState() {
    super.initState();
    _checkNotifications();
    _loadUserData();
  }
  
  // Fungsi untuk load data user
  Future<void> _loadUserData() async {
    if (_isLoadingUserData) return;
    
    setState(() {
      _isLoadingUserData = true;
    });
    
    try {
      final userData = await UserService.getUserData();
      
      setState(() {
        _userRole = userData?.role;
        _isLoadingUserData = false;
      });
      
      print('✅ User role loaded: $_userRole');
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }
  
  Future<void> _checkNotifications() async {
    if (_isLoadingNotifications) return;
    
    setState(() {
      _isLoadingNotifications = true;
    });
    
    try {
      // Mendapatkan jumlah notifikasi yang belum dibaca dari service
      final unreadCount = await NotifikasiService.getUnreadCount();
      
      setState(() {
        _notificationCount = unreadCount;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      print('Error checking notifications: $e');
      setState(() {
        _isLoadingNotifications = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah user adalah admin
    final bool isAdmin = _userRole?.toLowerCase() == 'admin';
    
    return Scaffold(
      // body
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkNotifications();
          await _loadUserData();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                //appbar with notification badge
                Row(
                  children: [
                    // Custom app bar expanded to take most space
                    Expanded(
                      child: MyAppbar(
                        notificationCount: _notificationCount,
                        onNotificationTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotifikasiPage(),
                            ),
                          ).then((_) => _checkNotifications());
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                //pie chart
                SizedBox(
                  height: 350,
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: _controller,
                    children: const [
                      MyUsercard(),
                      MyPiecard(
                          surat: "Surat Masuk",
                          tahunSurat: "2025",
                          suratDone: 20,
                          suratNew: 10,
                          suratProcess: 10),
                      MyPiecard(
                          surat: "Surat Keluar",
                          tahunSurat: "2025",
                          suratDone: 35,
                          suratNew: 10,
                          suratProcess: 10),
                    ],
                  ),
                ),

                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect:
                      ExpandingDotsEffect(activeDotColor: Colors.grey.shade700),
                ),

                const SizedBox(height: 16,),

                // Menu
                Column(
                  children: [
                    // Wrap in LayoutBuilder for responsive sizing
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate dynamic sizes based on available width
                        final availableWidth = constraints.maxWidth;
                        final sectionWidth = availableWidth * 0.48; // Give each section ~48% of width
                        
                        // Daftar section yang akan ditampilkan
                        final List<Widget> sections = [];
                        
                        // Baris pertama: Transaksi Surat dan Buku Agenda
                        sections.add(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Transaksi Surat Section
                              _buildMenuSection(
                                context,
                                'Transaksi Surat',
                                sectionWidth,
                                [
                                  MenuItemData(
                                    icon: Icons.mark_email_unread,
                                    label: 'Surat Masuk',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const TrSuratMasukPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  MenuItemData(
                                    icon: Icons.mark_email_read,
                                    label: 'Surat Keluar',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const TrSuratKeluarPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              
                              //Buku Agenda Section
                              _buildMenuSection(
                                context,
                                'Buku Agenda',
                                sectionWidth,
                                [
                                  MenuItemData(
                                    icon: Icons.mark_email_unread,
                                    label: 'Surat Masuk',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AgendaSuratMasuk(),
                                        ),
                                      );
                                    },
                                  ),
                                  MenuItemData(
                                    icon: Icons.mark_email_read,
                                    label: 'Surat Keluar',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AgendaSuratKeluar(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                        
                        // Spacer
                        sections.add(const SizedBox(height: 16));
                        
                        // Baris kedua: Galeri Surat dan Disposisi
                        sections.add(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //Galeri Section
                              _buildMenuSection(
                                context,
                                'Galeri Surat',
                                sectionWidth,
                                [
                                  MenuItemData(
                                    icon: Icons.mark_email_unread,
                                    label: 'Surat Masuk',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const GaleriSuratMasuk(),
                                        ),
                                      );
                                    },
                                  ),
                                  MenuItemData(
                                    icon: Icons.mark_email_read,
                                    label: 'Surat Keluar',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const GaleriSuratKeluar(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              
                              // Disposisi Section
                              _buildMenuSection(
                                context,
                                'Disposisi',
                                sectionWidth,
                                [
                                  MenuItemData(
                                    icon: Icons.assignment_turned_in,
                                    showBadge: _notificationCount > 0,
                                    badgeCount: _notificationCount,
                                    label: 'Notifikasi',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NotifikasiPage(),
                                        ),
                                      ).then((_) => _checkNotifications());
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                        
                        // Jika user adalah admin, tambahkan menu Kelola Pengguna
                        if (isAdmin) {
                          sections.add(const SizedBox(height: 16));
                          
                          sections.add(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Menu Kelola Pengguna (Admin only)
                                _buildMenuSection(
                                  context,
                                  'Administrasi',
                                  sectionWidth * 1.3, // Buat sedikit lebih lebar
                                  [
                                    MenuItemData(
                                      icon: Icons.people_alt,
                                      label: 'Kelola Pengguna',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const UserManagementPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return Column(
                          children: sections,
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to create consistent menu sections
  Widget _buildMenuSection(
    BuildContext context,
    String title,
    double width,
    List<MenuItemData> menuItems,
  ) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, // section title
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppPallete.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity, // Take full width of parent
            decoration: BoxDecoration(
              border: Border.all(
                color: AppPallete.borderColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: menuItems.map((item) => 
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            MyMenu(
                              icon: item.icon,
                              onTap: item.onTap,
                            ),
                            if (item.showBadge && item.badgeCount > 0)
                              Positioned(
                                right: -5,
                                top: -5,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    '${item.badgeCount}',
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
                        if (item.label != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              item.label!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppPallete.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;
  final String? label;

  MenuItemData({
    required this.icon, 
    required this.onTap, 
    this.showBadge = false, 
    this.badgeCount = 0,
    this.label,
  });
}
