import 'package:supabase_flutter/supabase_flutter.dart';

class BarService {
  final SupabaseClient _sb = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchBarStats() async {
    final res = await _sb.from('bar_stats').select('*');
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>> fetchBarById(String id) async {
    final res = await _sb.from('bars').select('*').eq('id', id).single();
    return Map<String, dynamic>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchLastReviews(String barId,
      {int limit = 10}) async {
    final res = await _sb
        .from('avis')
        .select('id,type,note,commentaire,created_at')
        .eq('bar_id', barId)
        .order('created_at', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> addReview({
    required String barId,
    required String type,
    required int note,
    String? commentaire,
  }) async {
    await _sb.from('avis').insert({
      'bar_id': barId,
      'type': type,
      'note': note,
      'commentaire':
          (commentaire?.trim().isEmpty ?? true) ? null : commentaire!.trim(),
    });
  }
}
