import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/user_management/add_user_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/user_management/edit_user_page.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  bool _isLoading = false;
  String? _error;
  List<User> _userList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await UserService.getAllUsers();
      
      setState(() {
        _userList = users;
        _isLoading = false;
      });
      
      print('✅ Loaded ${users.length} users');
    } catch (e) {
      print('❌ Error loading users: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Format role agar lebih mudah dibaca
  String _formatRole(String? role) {
    if (role == null) return 'Pengguna';
    
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'staff':
        return 'Staff';
      case 'dekan':
        return 'Dekan';
      case 'wakil_dekan':
        return 'Wakil Dekan';
      default:
        return role[0].toUpperCase() + role.substring(1);
    }
  }
  
  // Konfirmasi dan delete user
  Future<void> _confirmDelete(User user) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus pengguna "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    
    if (confirmation == true) {
      setState(() => _isLoading = true);
      
      try {
        await UserService.deleteUser(user.id!);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengguna berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadUsers(); // Refresh daftar setelah hapus
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = 'Gagal menghapus pengguna: $e';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus pengguna: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddUserPage(),
            ),
          ).then((_) => _loadUsers()); // Refresh setelah kembali dari tambah user
        },
        backgroundColor: AppPallete.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                const MyAppBar2(),
                
                const SizedBox(height: 16),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari pengguna...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppPallete.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppPallete.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppPallete.primaryColor),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Judul halaman
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Kelola Pengguna',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppPallete.textColor,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                
                // Implementasikan filter berdasarkan search query
                if (_searchQuery.isNotEmpty && !_isLoading && _error == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Hasil pencarian untuk "$_searchQuery"',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppPallete.textColor,
                      ),
                    ),
                  ),

                // Tampilkan loading, error atau daftar user
                _isLoading 
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      )
                    )
                  : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat data: $_error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Coba Lagi'),
                            )
                          ],
                        ),
                      )
                    : _buildUserList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserList() {
    // Filter user berdasarkan search query
    final filteredUserList = _searchQuery.isEmpty
        ? _userList
        : _userList.where((user) {
            final query = _searchQuery.toLowerCase();
            final name = user.name.toLowerCase();
            final nidn = user.nidn?.toLowerCase() ?? '';
            final role = user.role?.toLowerCase() ?? '';
            
            return name.contains(query) || 
                  nidn.contains(query) || 
                  role.contains(query);
          }).toList();

    if (filteredUserList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                _searchQuery.isEmpty ? Icons.people : Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty 
                  ? 'Belum ada data pengguna' 
                  : 'Tidak ada hasil untuk "$_searchQuery"',
                style: TextStyle(
                  color: AppPallete.textColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredUserList.length,
      itemBuilder: (context, index) {
        final user = filteredUserList[index];
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppPallete.primaryColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NIDN: ${user.nidn ?? 'Tidak ada'}'),
                Text('Role: ${_formatRole(user.role)}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserPage(user: user),
                      ),
                    ).then((_) => _loadUsers()); // Refresh setelah edit
                  },
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(user),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}