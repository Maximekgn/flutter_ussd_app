class UssdMenu {
  final int? id;
  final String title;
  final String code;
  final String category;
  final String? description;

  UssdMenu({
    this.id,
    required this.title,
    required this.code,
    required this.category,
    this.description,
  });

  /// Convertit un objet UssdMenu en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'category': category,
      'description': description,
    };
  }

  /// Crée un objet UssdMenu à partir d'un Map (depuis la base de données)
  factory UssdMenu.fromMap(Map<String, dynamic> map) {
    return UssdMenu(
      id: map['id'] as int?,
      title: map['title'] as String,
      code: map['code'] as String,
      category: map['category'] as String,
      description: map['description'] as String?,
    );
  }

  /// Copie l'objet avec de nouvelles valeurs
  UssdMenu copyWith({
    int? id,
    String? title,
    String? code,
    String? category,
    String? description,
  }) {
    return UssdMenu(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}
