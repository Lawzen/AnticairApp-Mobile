import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/annoncemodel.dart';
import '../providers/annonce_provider.dart';

class DetailScreen extends ConsumerWidget {
  final int annonceId;

  const DetailScreen({super.key, required this.annonceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annonceAsync = ref.watch(annonceDetailProvider(annonceId));

    return Scaffold(
      body: annonceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorScreen(error),
        data: (annonce) => _DetailSliverView(
          annonce: annonce,
          annonceId: annonceId,
          ref: ref,
        ),
      ),
    );
  }

  /// Affiche une page d'erreur en cas de problème de chargement
  Widget _buildErrorScreen(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Erreur : $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _DetailSliverView extends StatelessWidget {
  final AnnonceModel annonce;
  final int annonceId;
  final WidgetRef ref;

  const _DetailSliverView({
    super.key,
    required this.annonce,
    required this.annonceId,
    required this.ref,
  });

  /// Construit l'image de l'annonce (URL ou base64)
  Widget _buildAnnonceImage() {
    final imageVal = annonce.imageUrl;

    if (imageVal != null && imageVal.startsWith('http')) {
      return Image.network(
        imageVal,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // Si l'image est en base64
    if (imageVal != null && imageVal.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(imageVal);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    return _buildPlaceholder();
  }

  /// Placeholder pour les images non disponibles ou erreur
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.blueAccent,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.white,
          size: 100,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 250,
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, true),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEdit(context),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'annonce-${annonce.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _buildAnnonceImage(),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAnnonceDetails(context),
        ),
      ],
    );
  }

  /// Navigue vers l'écran de modification de l'annonce
  Future<void> _navigateToEdit(BuildContext context) async {
    final updated = await Navigator.pushNamed(
      context,
      '/update',
      arguments: {'annonce': annonce},
    );
    if (updated == true) {
      ref.invalidate(annonceDetailProvider(annonceId));  // Rafraîchit les données après modification
    }
  }

  /// Construit la partie détails de l'annonce
  Widget _buildAnnonceDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (annonce.category != null)
            Chip(
              label: Text(
                annonce.category!.name,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
            ),
          const SizedBox(height: 16),
          Text(
            annonce.titre,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            annonce.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildPriceCard(),  // Carte affichant le prix
          const SizedBox(height: 32),
          _buildDeleteButton(context),  // Bouton de suppression
        ],
      ),
    );
  }

  /// Construit la carte affichant le prix de l'annonce
  Card _buildPriceCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.euro, color: Colors.blueAccent),
        title: Text(
          '${annonce.prix} €',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Construit le bouton de suppression avec une confirmation
  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showDeleteDialog(context),
        icon: const Icon(Icons.delete),
        label: const Text('Supprimer l\'annonce'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Affiche une boîte de dialogue pour confirmer la suppression
  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'annonce ?'),
        content: const Text('Voulez-vous vraiment supprimer cette annonce ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(apiServiceProvider).deleteAnnonce(annonce.id ?? 0);
      Navigator.pop(context, true);
    }
  }
}
