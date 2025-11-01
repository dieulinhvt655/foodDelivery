class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String displayName;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.displayName,
  });

  // Convert CategoryModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'displayName': displayName,
    };
  }

  // Create CategoryModel from Map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      displayName: map['displayName'] ?? '',
    );
  }

  // Create CategoryModel from JSON (for API)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel.fromMap(json);
  }

  // Copy with method for updating
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? displayName,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, icon: $icon, displayName: $displayName)';
  }
}

