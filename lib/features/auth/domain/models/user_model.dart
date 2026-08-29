class UserModel {
  final String id;
  final String nama;
  final String email;
  final String universitas;
  final String role;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.universitas = 'Telkom University',
    this.role = 'mahasiswa',
  });
}
