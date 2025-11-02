import 'account_model.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
    );
  }

  factory UserModel.fromAccount(AccountModel account) {
    return UserModel(
      id: account.id ?? 0,
      name: account.name,
      email: account.email,
      phone: account.phone,
    );
  }
}
