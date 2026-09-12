class UserModel {
  final String id;
  final String nama;
  final String email;
  final String universitas;
  final String role;

  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.universitas = 'Telkom University',
    this.role = 'mahasiswa',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      universitas: json['universitas'] ?? 'Telkom University',
      role: json['role'] ?? 'mahasiswa',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'universitas': universitas,
      'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? universitas,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      universitas: universitas ?? this.universitas,
      role: role ?? this.role,
    );
  }
}
