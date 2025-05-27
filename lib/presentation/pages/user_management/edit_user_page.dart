import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:http/http.dart' as http;

class EditUserPage extends StatefulWidget {
  final User user;
  
  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _nidnController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  
  String? _selectedRole;
  bool _isLoading = false;
  String? _error;
  bool _changePassword = false;
  
  final List<String> _roles = ['admin', 'dekan', 'wakil_dekan', 'staff'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _nidnController = TextEditingController(text: widget.user.nidn);
    
    // Normalisasi format role sebelum digunakan
    _selectedRole = _normalizeRole(widget.user.role);
    
    print('User role: ${widget.user.role}, Normalized: $_selectedRole');
  }

  // Fungsi untuk menormalisasi format role
  String? _normalizeRole(String? role) {
    if (role == null) return null;
    
    // Mengganti spasi dengan underscore
    String normalized = role.toLowerCase().replaceAll(' ', '_');
    
    // Pastikan role ada dalam daftar yang valid
    if (_roles.contains(normalized)) {
      return normalized;
    }
    
    // Jika role tidak ditemukan, coba gunakan logic khusus
    if (normalized == 'wakil_dekan' || normalized == 'wakil' || normalized == 'wakildekan') {
      return 'wakil_dekan';
    }
    if (normalized == 'administrator') {
      return 'admin';
    }
    
    // Jika masih tidak ditemukan, gunakan default atau null
    return _roles.contains(role.toLowerCase()) ? role.toLowerCase() : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nidnController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Coba dulu dengan API service
      final updatedUser = User(
        id: widget.user.id,
        name: _nameController.text,
        nidn: _nidnController.text,
        role: _selectedRole,
      );
      
      // Jika mengubah password
      final String? password = _changePassword ? _passwordController.text : null;
      
      try {
        await UserService.updateUser(updatedUser, password);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data pengguna berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
        return;
        
      } catch (serviceError) {
        print('⚠️ Service update failed, trying direct update: $serviceError');
        
        // Jika gagal, coba direct update
        final success = await _directUpdateUser();
        
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data pengguna berhasil diperbarui (direct)'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          return;
        } else {
          throw Exception('Gagal update dengan semua metode');
        }
      }
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data pengguna: $_error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Tambahkan fungsi update langsung ini di _EditUserPageState
  Future<bool> _directUpdateUser() async {
    try {
      final token = await UserService.getToken();
      if (token.isEmpty) {
        throw Exception('Token tidak tersedia');
      }
      
      // Siapkan data user untuk update
      final Map<String, dynamic> userData = {
        'id': widget.user.id.toString(), // Konversi ke string untuk form data
        'name': _nameController.text,
        'nidn': _nidnController.text,
        'role': _selectedRole,
      };
      
      // Tambahkan password jika diubah
      if (_changePassword) {
        userData['password'] = _passwordController.text;
        userData['password_confirmation'] = _passwordController.text;
      }
      
      print('🚀 Mencoba direct update: $userData');
      
      // Konfigurasi header yang tepat untuk content type
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': token,
      };
      
      // Coba semua kemungkinan endpoint
      final endpoints = [
        '/api/users/${widget.user.id}', 
        '/api/update-user',
        '/api/user/update',
        '/api/users/update/${widget.user.id}'
      ];
      
      for (final endpoint in endpoints) {
        final uri = Uri.parse('http://192.168.1.12:8000$endpoint');
        print('🔗 Mencoba endpoint: $uri');
        
        // Kirim sebagai form data dengan method POST
        final encodedBody = userData.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
        
        final response = await http.post(
          uri,
          headers: headers,
          body: encodedBody,
        );
        
        print('📡 Response: ${response.statusCode} - ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('✅ Update berhasil via $endpoint');
          return true;
        }
      }
      
      // Semua endpoint gagal, coba alternatif terakhir dengan method GET + query params
      final fallbackUri = Uri.parse('http://192.168.1.12:8000/api/update-user').replace(
        queryParameters: userData
      );
      
      print('🔗 Mencoba fallback GET: $fallbackUri');
      final getResponse = await http.get(
        fallbackUri,
        headers: {'Accept': 'application/json', 'Authorization': token},
      );
      
      print('📡 GET Response: ${getResponse.statusCode}');
      
      return getResponse.statusCode == 200 || getResponse.statusCode == 201;
      
    } catch (e) {
      print('❌ Error in direct update: $e');
      return false;
    }
  }

  // Tambahkan metode alternatif untuk update data
  // Gunakan ini jika _updateUser() gagal
  Future<void> _showCustomUpdateForm() async {
    // Ambil URL API dari konfigurasi aplikasi
    final baseUrl = 'http://192.168.1.12:8000'; // Sesuaikan dengan URL backend Anda
    
    // Dialog untuk meminta user mengisi URL yang benar
    final endpoint = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update URL Manual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('API endpoint tidak ditemukan. Masukkan URL endpoint yang benar:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: '/api/users/[id]',
                labelText: 'URL Endpoint',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: '/api/users/${widget.user.id}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context, 
              '/api/users/${widget.user.id}',  // Default URL yang disugestikan
            ),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
    
    if (endpoint == null) return;
    
    // Tampilkan webview dengan form HTML yang memanggil endpoint yang benar
    setState(() {
      _isLoading = true;
    });
    
    try {
      final token = await UserService.getToken();
      
      // Data yang akan dikirim
      final formData = {
        'name': _nameController.text,
        'nidn': _nidnController.text,
        'role': _selectedRole,
        '_method': 'PUT', // Laravel form method spoofing
      };
      
      if (_changePassword) {
        formData['password'] = _passwordController.text;
        formData['password_confirmation'] = _passwordController.text;
      }
      
      // Kirim request langsung
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': token,
        },
        body: Uri(queryParameters: formData).query,
      );
      
      print('📡 Manual form update response: ${response.statusCode}');
      print('📄 Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pengguna berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Update manual gagal: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Pengguna'),
        backgroundColor: AppPallete.secondaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error message
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // NIDN field
                TextFormField(
                  controller: _nidnController,
                  decoration: InputDecoration(
                    labelText: 'NIDN / Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIDN / Username wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Role dropdown dengan tambahan debug info untuk bantuan troubleshooting
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Role / Jabatan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(_formatRole(role)),
                        );
                      }).toList(),
                      value: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                          print('Selected role changed to: $value');
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Role wajib dipilih';
                        }
                        return null;
                      },
                      hint: const Text('Pilih role/jabatan'),
                    ),
                    
                    // Debug info - bisa dihapus untuk produksi
                    if (_selectedRole == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Role tidak dikenali: "${widget.user.role ?? 'null'}"',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Change password checkbox
                CheckboxListTile(
                  title: const Text('Ubah Password'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _changePassword,
                  onChanged: (value) {
                    setState(() {
                      _changePassword = value ?? false;
                    });
                  },
                ),
                
                // Password fields (only shown when changing password)
                if (_changePassword) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (_changePassword) {
                        if (value == null || value.isEmpty) {
                          return 'Password baru wajib diisi';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordConfirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (_changePassword) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password wajib diisi';
                        }
                        if (value != _passwordController.text) {
                          return 'Password tidak sama';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                
                // Tambahkan tombol manual update
                if (_error != null && _error!.contains('API endpoint')) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _showCustomUpdateForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Coba Update Manual'),
                  ),
                ],
                
                // Tombol untuk update langsung
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _directUpdateUser,
                  icon: const Icon(Icons.construction),
                  label: const Text('Update Langsung (Bypass API)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatRole(String role) {
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
}