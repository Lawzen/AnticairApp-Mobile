import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/annoncemodel.dart';
import '../services/api_service.dart';

class CreateAnnonceScreen extends StatefulWidget {
  const CreateAnnonceScreen({super.key});

  @override
  _CreateAnnonceScreenState createState() => _CreateAnnonceScreenState();
}

class _CreateAnnonceScreenState extends State<CreateAnnonceScreen> {
  final _formKey = GlobalKey<FormState>();

  String titre = '';
  String description = '';
  double prix = 0.0;
  String? imageUrl;
  String? localImagePath;
  AnnonceCategory? category;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  /// Ouvre la galerie et sélectionne une image
  Future<void> _pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      final XFile? xfile = await _picker.pickImage(source: ImageSource.gallery);

      if (xfile != null) {
        _convertImageToBase64(xfile.path);
      }
    } else {
      _handlePermissionDenied(status);
    }
  }

  /// Convertit l'image sélectionnée en base64
  Future<void> _convertImageToBase64(String path) async {
    setState(() {
      localImagePath = path;
    });

    try {
      final bytes = await File(path).readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        imageUrl = base64String;
      });
    } catch (e) {
      _showSnackBar('Erreur lors de la conversion : $e', Colors.red);
    }
  }

  /// Gère les permissions refusées
  void _handlePermissionDenied(PermissionStatus status) {
    if (status.isDenied) {
      _showSnackBar(
        'Permission refusée : impossible de sélectionner une image.',
        Colors.red,
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  /// Affiche une notification en bas de l'écran
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// Soumet le formulaire après validation
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final annonce = AnnonceModel(
        titre: titre,
        description: description,
        prix: prix,
        imageUrl: imageUrl,
        category: category,
      );

      try {
        await _apiService.createAnnonce(annonce);
        _showSnackBar('Annonce créée avec succès', Colors.green);
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        _showSnackBar('Erreur: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Créer une annonce',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: _buildFormCard(),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit l'arrière-plan en dégradé
  Widget _buildBackgroundGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7DDFF8), Color(0xFFB7F8DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  /// Construit la carte du formulaire
  Widget _buildFormCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Nouvelle annonce',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 24),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildTitreField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildPrixField(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit le bouton de sélection d'image
  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
        child: _buildLocalPreview(),
      ),
    );
  }

  /// Affiche un aperçu de l'image sélectionnée ou un placeholder
  Widget _buildLocalPreview() {
    if (localImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(localImagePath!),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 50, color: Colors.blueAccent),
            Text('Ajouter une image',
                style: TextStyle(color: Colors.blueAccent)),
          ],
        ),
      );
    }
  }

  /// Construit le champ de sélection de catégorie
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<AnnonceCategory>(
      value: category,
      decoration: InputDecoration(
        labelText: 'Catégorie',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: AnnonceCategory.values.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(cat.toString().split('.').last),
        );
      }).toList(),
      onChanged: (value) => setState(() => category = value),
      validator: (value) =>
      value == null ? 'Veuillez choisir une catégorie' : null,
    );
  }

  Widget _buildTitreField() => _buildTextField(
    label: 'Titre',
    icon: Icons.title,
    onSaved: (value) => titre = value!,
  );

  Widget _buildDescriptionField() => _buildTextField(
    label: 'Description',
    icon: Icons.description,
    maxLines: 3,
    onSaved: (value) => description = value!,
  );

  Widget _buildPrixField() => _buildTextField(
    label: 'Prix (€)',
    icon: Icons.euro,
    keyboardType: TextInputType.number,
    onSaved: (value) => prix = double.parse(value!),
  );

  Widget _buildTextField({
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) =>
      value!.isEmpty ? 'Veuillez entrer $label' : null,
      onSaved: onSaved,
    );
  }

  /// Bouton de soumission du formulaire
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Publier l\'annonce', style: TextStyle(fontSize: 16)),
    );
  }
}
