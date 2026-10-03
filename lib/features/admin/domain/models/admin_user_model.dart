class AdminUserModel {
  final String id;
  final String nama;
  final String email;
  final String? nim;
  final String universitas;
  final String? fotoProfil;
  final String role;
  final String tanggalDaftar;

  const AdminUserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.nim,
    this.universitas = 'Telkom University',
    this.fotoProfil,
    this.role = 'mahasiswa',
    this.tanggalDaftar = '',
  });

  String get username => '@${email.split('@').first}';

  bool get punyaNim => nim != null && nim!.trim().isNotEmpty;

  bool get punyaFotoOnline {
    final foto = fotoProfil ?? '';
    return foto.startsWith('http://') || foto.startsWith('https://');
  }

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at']?.toString() ?? '';
    return AdminUserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama_lengkap']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nim: json['nim']?.toString(),
      universitas: json['universitas']?.toString() ?? 'Telkom University',
      fotoProfil: json['foto_profil']?.toString(),
      role: json['role']?.toString() ?? 'mahasiswa',
      tanggalDaftar: createdAt.split('T').first,
    );
  }
}
