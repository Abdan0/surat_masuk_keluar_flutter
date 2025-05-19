class User {
  int? id;
  String? name;
  String? nidn;
  String? role;
  String? token;
  String? createdAt;
  String? updatedAt;

  User(
      {this.id,
      this.name,
      this.nidn,
      this.role,
      this.token,
      this.createdAt,
      this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      nidn: json['nidn'],
      role: json['role'],
      token: json['token'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
    
  }

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rrole': role,
      'token': token,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
