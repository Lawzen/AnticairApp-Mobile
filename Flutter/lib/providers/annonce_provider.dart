import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/annoncemodel.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final annoncesProvider = FutureProvider<List<AnnonceModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getAllAnnonces();
});

final annonceDetailProvider = FutureProvider.family<AnnonceModel, int>((ref, id) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getAnnonceById(id);
});
