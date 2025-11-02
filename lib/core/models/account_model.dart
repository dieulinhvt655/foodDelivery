class AccountModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;

  const AccountModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  AccountModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String?,
    );
  }
}
