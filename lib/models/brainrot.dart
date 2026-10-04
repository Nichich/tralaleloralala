enum Rarity {
  common('Обычный'),
  rare('Редкий'),
  legendary('Легендарный');

  const Rarity(this.label);

  final String label;

  static Rarity fromString(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final rarity in Rarity.values) {
      if (rarity.name == normalized) return rarity;
    }
    return Rarity.common;
  }
}

class Brainrot {
  const Brainrot({
    required this.id,
    required this.name,
    required this.description,
    required this.superpower,
    required this.rarity,
    required this.aura,
    required this.image,
    required this.sound,
  });

  final String id;
  final String name;
  final String description;
  final String superpower;
  final Rarity rarity;
  final int aura;
  final String image;
  final String sound;

  factory Brainrot.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String || id.trim().isEmpty || name is! String || name.trim().isEmpty) {
      throw FormatException('Brainrot without id or name', json);
    }

    return Brainrot(
      id: id.trim(),
      name: name.trim(),
      description: _readString(json['description']),
      superpower: _readString(json['superpower']),
      rarity: Rarity.fromString(_readString(json['rarity'])),
      aura: _readInt(json['aura']),
      image: _readString(json['image']).trim(),
      sound: _readString(json['sound']).trim(),
    );
  }
}

String _readString(Object? value) => value is String ? value : '';

int _readInt(Object? value) {
  if (value is num) return value.isFinite ? value.toInt() : 0;
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}
