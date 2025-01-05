# Anticair App - Application d'Annonces

## Description
Anticair est une application d'annonces développée en utilisant Flutter pour le front-end et Spring Boot pour le back-end. Cette application a été réalisé lors de ma ddernière année à la HELHa celle-ci permet aux utilisateurs de créer, modifier, supprimer et consulter des annonces.

---

## Table des matières
- [Technologies Utilisées](#technologies-utilisées)
- [Architecture du Projet](#architecture-du-projet)
- [Configuration du Back-End (Spring Boot)](#configuration-du-back-end-spring-boot)
- [Configuration du Front-End (Flutter)](#configuration-du-front-end-flutter)
- [Installation et Lancement](#installation-et-lancement)
- [API Endpoints](#api-endpoints)
- [Fonctionnalités](#fonctionnalités)
- [Aperçu du Projet](#aperçu-du-projet)

---

## Technologies Utilisées

### Back-End
- **Java 17**
- **Spring Boot 3+** (REST, JPA, Lombok)
- **Maven**
- **PostgreSQL / MySQL** (Base de données)
- **Hibernate** (ORM)

### Front-End
- **Flutter 3+**
- **Dio (Gestion API HTTP)**
- **Flutter Riverpod (State Management)**
- **Provider**
- **Material Design**

---

## Architecture du Projet

### Structure du Back-End (Spring Boot)
```
src/
└── main/
    └── java/
        └── com.anticair.app/
            ├── config/               # Configuration globale (Swagger, etc.)
            ├── controller/           # Contrôleurs REST
            ├── dto/                  # Objets de transfert de données (DTO)
            ├── entity/               # Entités JPA (Annonce, User)
            ├── exception/            # Gestion des exceptions personnalisées
            ├── repository/           # Repositories JPA
            └── service/              # Services métiers
```

### Structure du Front-End (Flutter)
```
lib/
├── models/               # Modèles d'annonces
├── providers/            # Gestion d'état avec Riverpod
├── screens/              # Pages principales (Home, Détails, Création)
├── services/             # Communication API
└── main.dart             # Point d'entrée de l'application Flutter
```

---

## Configuration du Back-End (Spring Boot)
### Fichier `AnnonceController.java`
```java
@RestController
@RequestMapping("/api/annonces")
@RequiredArgsConstructor
public class AnnonceController {
    private final AnnonceService annonceService;

    @GetMapping
    public ResponseEntity<?> getAllAnnonces() {
        return ResponseEntity.ok(annonceService.getAllAnnonces());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getAnnonceById(@PathVariable Long id) {
        return ResponseEntity.ok(annonceService.getAnnonceById(id));
    }

    @PostMapping
    public ResponseEntity<?> createAnnonce(@RequestBody AnnonceDTO annonceDTO) {
        return ResponseEntity.ok(annonceService.createAnnonce(annonceDTO));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAnnonce(@PathVariable Long id, @RequestBody AnnonceDTO annonceDTO) {
        return ResponseEntity.ok(annonceService.updateAnnonce(id, annonceDTO));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAnnonce(@PathVariable Long id) {
        annonceService.deleteAnnonce(id);
        return ResponseEntity.ok().build();
    }
}
```

---

## Configuration du Front-End (Flutter)
### Fichier `api_service.dart`
```dart
import 'package:dio/dio.dart';
import '../models/annonce.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:8080/api';

  ApiService() {
    _dio.options.baseUrl = baseUrl;
  }

  Future<List<AnnonceModel>> getAllAnnonces() async {
    final response = await _dio.get('/annonces');
    return (response.data as List)
        .map((json) => AnnonceModel.fromJson(json))
        .toList();
  }

  Future<AnnonceModel> createAnnonce(AnnonceModel annonce) async {
    final response = await _dio.post('/annonces', data: annonce.toJson());
    return AnnonceModel.fromJson(response.data);
  }
}
```

---

## Installation et Lancement
### 1. Back-End (Spring Boot)
```bash
cd anticair-backend
./mvnw spring-boot:run
```

### 2. Front-End (Flutter)
```bash
cd anticair-frontend
flutter pub get
flutter run
```

---

## API Endpoints
### Base URL
```
http://localhost:8080/api
```

### Annonces
| Méthode | Endpoint                  | Description                          |
|---------|---------------------------|--------------------------------------|
| GET     | `/annonces`               | Récupérer toutes les annonces         |
| GET     | `/annonces/{id}`          | Récupérer une annonce par ID          |
| POST    | `/annonces`               | Créer une nouvelle annonce            |
| PUT     | `/annonces/{id}`          | Mettre à jour une annonce existante   |
| DELETE  | `/annonces/{id}`          | Supprimer une annonce                 |

---

## Fonctionnalités
- **Création d'annonces** : L'utilisateur peut créer une annonce avec un titre, une description et une image.
- **Liste des annonces** : Consultation des annonces existantes.
- **Détails d'annonce** : Voir les détails d'une annonce spécifique.
- **Mise à jour/Suppression** : Modifier ou supprimer une annonce.

---

## Auteur
- **Lawzen** - Développeur Principal

