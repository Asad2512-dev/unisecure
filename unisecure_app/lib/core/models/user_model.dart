class UserModel {
  final int id;
  final String name, email, role;
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: (j['id'] as num?)?.toInt() ?? 0,
    name: '${j['name'] ?? ''}',
    email: '${j['email'] ?? ''}',
    role: '${j['role'] ?? ''}',
  );
}
