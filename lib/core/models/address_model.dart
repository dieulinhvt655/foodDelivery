class AddressModel {
  final int? id;
  final int userId;
  final String label;
  final String address;
  final String? note;
  final bool isDefault;
  final DateTime createdAt;

  const AddressModel({
    this.id,
    required this.userId,
    required this.label,
    required this.address,
    this.note,
    this.isDefault = false,
    required this.createdAt,
  });

  AddressModel copyWith({
    int? id,
    int? userId,
    String? label,
    String? address,
    String? note,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      address: address ?? this.address,
      note: note ?? this.note,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'address': address,
      'note': note,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      label: map['label'] as String,
      address: map['address'] as String,
      note: map['note'] as String?,
      isDefault: (map['is_default'] as int?) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

