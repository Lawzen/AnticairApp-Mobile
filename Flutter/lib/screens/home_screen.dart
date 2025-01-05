import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/annoncemodel.dart';
import '../providers/annonce_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annoncesAsync = ref.watch(annoncesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Anticair\'App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final annonces = annoncesAsync.value;
              if (annonces != null) {
                showSearch(
                  context: context,
                  delegate: AnnonceSearchDelegate(allAnnonces: annonces),
                );
              }
            },
          ),
        ],
      ),
      body: annoncesAsync.when(
        data: (annonces) => Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: annonces.length,
            itemBuilder: (context, index) {
              final annonce = annonces[index];
              return _AnnonceGridItem(
                annonce: annonce,
                theme: theme,
                ref: ref,
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refreshNeeded = await Navigator.pushNamed(context, '/create');
          if (refreshNeeded == true) {
            ref.invalidate(annoncesProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle annonce'),
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Erreur: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _AnnonceGridItem extends StatelessWidget {
  const _AnnonceGridItem({
    Key? key,
    required this.annonce,
    required this.theme,
    required this.ref,
  }) : super(key: key);

  final AnnonceModel annonce;
  final ThemeData theme;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final refreshNeeded = await Navigator.pushNamed(
          context,
          '/detail',
          arguments: annonce.id,
        );
        if (refreshNeeded == true) {
          ref.invalidate(annoncesProvider);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.grey[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildImageHeader(annonce),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (annonce.category != null)
                      Chip(
                        label: Text(
                          annonce.category!.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: Colors.green,
                        visualDensity: VisualDensity.compact,
                      ),
                    const SizedBox(height: 6),
                    Text(
                      annonce.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _buildPriceTag(annonce.prix),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(AnnonceModel annonce) {
    final imageVal = annonce.imageUrl;

    // Gestion de l'image si elle est présente
    if (imageVal != null && imageVal.isNotEmpty) {
      try {
        if (imageVal.startsWith('http')) {
          return _networkImage(imageVal, annonce.id!);
        } else {
          final bytes = base64Decode(imageVal);
          return _memoryImage(bytes, annonce.id!);
        }
      } catch (e) {
        return _placeholder();
      }
    }
    return _placeholder();
  }

  Widget _networkImage(String url, int id) {
    return Hero(
      tag: 'annonce-$id',
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          url,
          width: double.infinity,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _memoryImage(Uint8List bytes, int id) {
    return Hero(
      tag: 'annonce-$id',
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.memory(
          bytes,
          width: double.infinity,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.white,
        size: 50,
      ),
    );
  }

  Widget _buildPriceTag(double prix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${prix.toStringAsFixed(2)}€',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}


/// Moteur de recherche pour filtrer localement la liste d'annonces.
class AnnonceSearchDelegate extends SearchDelegate<String> {
  final List<AnnonceModel> allAnnonces;

  AnnonceSearchDelegate({required this.allAnnonces});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allAnnonces.where((annonce) {
      final lowerTitre = annonce.titre.toLowerCase();
      final lowerDesc = annonce.description.toLowerCase();
      final lowerQuery = query.toLowerCase();
      return lowerTitre.contains(lowerQuery) || lowerDesc.contains(lowerQuery);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('Aucun résultat trouvé.'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final annonce = results[index];
        return ListTile(
          title: Text(annonce.titre),
          subtitle: Text('${annonce.prix}€'),
          onTap: () {
            close(context, annonce.titre);
            Navigator.pushNamed(
              context,
              '/detail',
              arguments: annonce.id,
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allAnnonces.where((annonce) {
      final lowerTitre = annonce.titre.toLowerCase();
      final lowerDesc = annonce.description.toLowerCase();
      final lowerQuery = query.toLowerCase();
      return lowerTitre.contains(lowerQuery) || lowerDesc.contains(lowerQuery);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final annonce = suggestions[index];
        return ListTile(
          title: Text(annonce.titre),
          subtitle: Text('${annonce.prix}€'),
          onTap: () {
            query = annonce.titre;
            showResults(context);
          },
        );
      },
    );
  }
}
