import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/paste/models/paste.dart';
import 'package:rule7_app/features/paste/repositories/paste_repository.dart';

final pasteRepositoryProvider = Provider<PasteRepository>((ref) {
  return PasteRepository();
});

/// Provider for single paste detail
final pasteProvider = FutureProvider.family<Paste, String>((ref, slug) async {
  final repository = ref.read(pasteRepositoryProvider);
  return repository.getPaste(slug);
});
