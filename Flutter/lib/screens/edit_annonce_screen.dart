import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/annoncemodel.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class EditAnnonceScreen extends StatefulWidget {
  final AnnonceModel annonce;

  const EditAnnonceScreen({super.key, required this.annonce});

  @override
  _EditAnnonceScreenState createState() => _EditAnnonceScreenState();
}

class _EditAnnonceScreenState extends State<EditAnnonceScreen> {
  final _formKey = GlobalKey<FormState>();
  late String titre;
  late String description;
  late double prix;
  late String? imageUrl;
  String? localImagePath;
  AnnonceCategory? category;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    titre = widget.annonce.titre;
    description = widget.annonce.description;
    prix = widget.annonce.prix;
    imageUrl = widget.annonce.imageUrl;

    if (widget.annonce.category != null) {
      category = AnnonceCategory.values.firstWhere(
            (c) => c.name == widget.annonce.category,
        orElse: () => AnnonceCategory.AUTRE,
      );
    }
  }
  /// Fonction pour sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final XFile? xfile = await _picker.pickImage(source: ImageSource.gallery);
      if (xfile != null) {
        setState(() {
          localImagePath = xfile.path;
        });

        try {
          final bytes = await File(xfile.path).readAsBytes();
          final base64String = base64Encode(bytes);

          setState(() {
            imageUrl = base64String;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la conversion : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission refusée : impossible de sélectionner une image.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedAnnonce = AnnonceModel(
        id: widget.annonce.id,
        titre: titre,
        description: description,
        prix: prix,
        imageUrl: imageUrl,
        category: category,
        status: widget.annonce.status,
      );

      try {
        if (updatedAnnonce.id != null) {
          await _apiService.updateAnnonce(updatedAnnonce.id!, updatedAnnonce);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier l\'annonce',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: imageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 50, color: Colors.blueAccent),
                          Text(
                            'Modifier l\'image',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<AnnonceCategory>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: AnnonceCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Veuillez choisir une catégorie' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: titre,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Veuillez entrer un titre' : null,
                  onSaved: (value) => titre = value!,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                  value!.isEmpty ? 'Veuillez entrer une description' : null,
                  onSaved: (value) => description = value!,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: prix.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Prix (€)',
                    prefixIcon: Icon(Icons.euro),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Veuillez entrer un prix' : null,
                  onSaved: (value) => prix = double.parse(value!),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer les modifications',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
