class BarStat {
  final String id;
  final String nom;
  final double lat;
  final double lng;
  final String? adresse;
  final int nbAvis;
  final double? noteMoy;
  final Map<String, double?>? moyParType;

  BarStat({
    required this.id,
    required this.nom,
    required this.lat,
    required this.lng,
    this.adresse,
    required this.nbAvis,
    this.noteMoy,
    this.moyParType,
  });

  factory BarStat.fromJson(Map<String, dynamic> json) {
    return BarStat(
      id: json['id'],
      nom: json['nom'],
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      adresse: json['adresse'],
      nbAvis: json['nb_avis'] ?? 0,
      noteMoy: json['note_moy']?.toDouble(),
      moyParType: json['moy_par_type'] != null
          ? Map<String, double?>.from(json['moy_par_type'])
          : null,
    );
  }
}

class AvisItem {
  final String id;
  final String type;
  final int note;
  final String? commentaire;
  final DateTime createdAt;

  AvisItem({
    required this.id,
    required this.type,
    required this.note,
    this.commentaire,
    required this.createdAt,
  });

  factory AvisItem.fromJson(Map<String, dynamic> json) {
    return AvisItem(
      id: json['id'],
      type: json['type'],
      note: json['note'],
      commentaire: json['commentaire'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static const List<String> reviewTypes = [
    'hygiene',
    'ambiance',
    'securite',
    'personnel'
  ];

  static String getTypeLabel(String type) {
    switch (type) {
      case 'hygiene':
        return 'Hygiène';
      case 'ambiance':
        return 'Ambiance';
      case 'securite':
        return 'Sécurité';
      case 'personnel':
        return 'Personnel';
      default:
        return type;
    }
  }
}