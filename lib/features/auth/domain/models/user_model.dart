class UserModel {
  final String id;
  final String nama;
  final String email;
  final String? nim;
  final String universitas;
  final String? fotoProfil;
  final String role;
  final double saldoDummy;
  final String username;
  final String bio;
  final String phone;
  final int booksRead;
  final int booksBorrowed;
  final int favorites;

  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.nim,
    this.universitas = 'Telkom University',
    this.fotoProfil,
    this.role = 'mahasiswa',
    this.saldoDummy = 100000.0,
    this.username = 'User',
    this.bio = 'A casual reader',
    this.phone = '+62 8959982898',
    this.booksRead = 12,
    this.booksBorrowed = 3,
    this.favorites = 5,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final activity = json['activity'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama_lengkap'] ?? json['nama'] ?? '',
      email: json['email'] ?? '',
      nim: json['nim']?.toString(),
      universitas: json['universitas'] ?? 'Telkom University',
      fotoProfil: json['foto_profil'],
      role: json['role'] ?? 'mahasiswa',
      saldoDummy: (json['saldo_dummy'] as num?)?.toDouble() ?? 100000.0,
      username: json['username'] ?? 'User',
      bio: json['bio'] ?? 'A casual reader',
      phone: json['phone'] ?? json['nomor_telepon'] ?? '+62 8959982898',
      booksRead: (activity?['books_read'] as num?)?.toInt() ??
          (json['books_read'] as num?)?.toInt() ??
          12,
      booksBorrowed: (activity?['books_borrowed'] as num?)?.toInt() ??
          (json['books_borrowed'] as num?)?.toInt() ??
          3,
      favorites: (activity?['favorites'] as num?)?.toInt() ??
          (json['favorites'] as num?)?.toInt() ??
          5,
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
      'username': username,
      'bio': bio,
      'phone': phone,
      'books_read': booksRead,
      'books_borrowed': booksBorrowed,
      'favorites': favorites,
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
    String? username,
    String? bio,
    String? phone,
    int? booksRead,
    int? booksBorrowed,
    int? favorites,
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
      username: username ?? this.username,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      booksRead: booksRead ?? this.booksRead,
      booksBorrowed: booksBorrowed ?? this.booksBorrowed,
      favorites: favorites ?? this.favorites,
    );
  }
}
