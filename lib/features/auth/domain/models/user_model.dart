class UserModel {
  final String id;
  final String nama;
  final String email;
  final String? nim;
  final String universitas;
  final String? fotoProfil;
  final String role;
  final double saldoDummy;

  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.nim,
    this.universitas = 'Telkom University',
    this.fotoProfil,
    this.role = 'mahasiswa',
    this.saldoDummy = 100000.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama_lengkap'] ?? json['nama'] ?? '',
      email: json['email'] ?? '',
      nim: json['nim']?.toString(),
      universitas: json['universitas'] ?? 'Telkom University',
      fotoProfil: json['foto_profil'],
      role: json['role'] ?? 'mahasiswa',
      saldoDummy: (json['saldo_dummy'] as num?)?.toDouble() ?? 100000.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': nama,
      'nama': nama,
      'email': email,
      'nim': nim,
      'universitas': universitas,
      'foto_profil': fotoProfil,
      'role': role,
      'saldo_dummy': saldoDummy,
    };
  }

  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? nim,
    String? universitas,
    String? fotoProfil,
    String? role,
    double? saldoDummy,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      nim: nim ?? this.nim,
      universitas: universitas ?? this.universitas,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      role: role ?? this.role,
      saldoDummy: saldoDummy ?? this.saldoDummy,
    );
  }
}
