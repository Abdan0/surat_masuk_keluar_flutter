class User {
  final int? id;
  final String name;
  final String? email;
  final String? role;
  final String? profilePhoto;
  String? nidn;
  String? token;

  User({
    this.id,
    required this.name,
    this.email,
    this.role,
    this.profilePhoto,
    this.nidn,
    this.token
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Cek apakah data berada dalam nested structure atau tidak
    Map<String, dynamic> userData = json;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      userData = json['data'];
    }
    
    try {
      // Parse safely dengan memberikan nilai default jika field tidak ditemukan
      return User(
        id: userData['id'] != null 
            ? int.tryParse(userData['id'].toString()) 
            : null,
        name: userData['name'] ?? userData['nama'] ?? 'User',  // Try alternative fields
        email: userData['email'],
        role: userData['role'] ?? userData['jabatan'], // Try alternative fields 
        profilePhoto: userData['profile_photo'] ?? userData['foto'], // Try alternative fields
        nidn: userData['nidn'] ?? userData['nip'] ?? userData['username'], // Try alternative fields
      );
    } catch (e) {
      print('❌ Error parsing user data: $e');
      // Return fallback user jika parsing gagal
      return User(name: 'User');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_photo': profilePhoto,
    };
  }
}
