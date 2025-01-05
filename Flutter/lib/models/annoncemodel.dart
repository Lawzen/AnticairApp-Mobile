/// Éventuellement, tu peux déclarer l'énumération si tu en as besoin
enum AnnonceCategory {
  MOBILIER,
  OBJETS,
  CERAMIQUE,
  HORLOGERIE,
  BIJOUX,
  TABLEAUX,
  LIVRES,
  SCULPTURES,
  ARGENTERIE,
  TEXTILES,
  INSTRUMENTS,
  VERRERIE,
  JOUETS,
  LUMINAIRES,
  CARTES,
  CURIOSITE,
  MONNAIE,
  ASIATIQUE,
  MARINE,
  SCIENTIFIQUE,
  AUTRE
}



/// Modèle d'annonce (sans utilisateur)
class AnnonceModel {
  final int? id;
  final String titre;
  final String description;
  final double prix;
  final String? imageUrl;
  final String? status;
  final AnnonceCategory? category;

  AnnonceModel({
    this.id,
    required this.titre,
    required this.description,
    required this.prix,
    this.imageUrl,
    this.category,
    this.status,
  });

  /// Conversion depuis JSON (réponse d'API par exemple)
  factory AnnonceModel.fromJson(Map<String, dynamic> json) {
    return AnnonceModel(
      id: json['id'] as int?,
      titre: json['titre'] as String,
      description: json['description'] as String,
      prix: (json['prix'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String?,
      category: _mapCategory(json['category']),
    );
  }

  /// Conversion en JSON (pour envoyer au serveur)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'prix': prix,
      'imageUrl': imageUrl,
      'status': status,
      'category': category?.name,
    };
  }

  /// Méthode privée pour convertir une chaîne JSON en enum
  static AnnonceCategory? _mapCategory(dynamic cat) {
    if (cat == null) return null;
    // cat est parfois String, on tente une correspondance avec l'enum
    return AnnonceCategory.values.firstWhere(
          (e) => e.name == cat.toString(),
      orElse: () => AnnonceCategory.AUTRE,
    );
  }
}
