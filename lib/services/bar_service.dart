import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soireesafe/models.dart';

class BarService {
  static final _client = Supabase.instance.client;

  static Future<List<BarStat>> fetchBarStats() async {
    try {
      final response = await _client
          .from('bar_stats')
          .select('*');
      
      return (response as List)
          .map((json) => BarStat.fromJson(json))
          .toList();
    } catch (e) {
      // Return mock data for development
      return _getMockBarStats();
    }
  }

  static Future<Map<String, dynamic>?> fetchBarById(String id) async {
    try {
      final response = await _client
          .from('bars')
          .select('*')
          .eq('id', id)
          .single();
      
      return response;
    } catch (e) {
      // Return mock data for development
      return _getMockBarById(id);
    }
  }

  static Future<List<AvisItem>> fetchLastReviews(String barId, {int limit = 10}) async {
    try {
      final response = await _client
          .from('avis')
          .select('id,type,note,commentaire,created_at')
          .eq('bar_id', barId)
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) => AvisItem.fromJson(json))
          .toList();
    } catch (e) {
      // Return mock data for development
      return _getMockReviews(barId);
    }
  }

  static Future<void> addReview({
    required String barId,
    required String type,
    required int note,
    String? commentaire,
  }) async {
    try {
      await _client.from('avis').insert({
        'bar_id': barId,
        'type': type,
        'note': note,
        'commentaire': commentaire,
      });
    } catch (e) {
      // Simulate success for development
      print('Review added (mock): $type - $note/5');
    }
  }

  // Mock data for development when Supabase is not configured
  static List<BarStat> _getMockBarStats() {
    return [
      BarStat(
        id: '1',
        nom: 'Le Vieux Port Bar',
        lat: 43.2946,
        lng: 5.3750,
        adresse: '12 Quai du Port, 13002 Marseille',
        nbAvis: 24,
        noteMoy: 4.2,
        moyParType: {
          'hygiene': 4.0,
          'ambiance': 4.5,
          'securite': 4.0,
          'personnel': 4.3,
        },
      ),
      BarStat(
        id: '2',
        nom: 'Bar de la Marine',
        lat: 43.2955,
        lng: 5.3745,
        adresse: '15 Quai de Rive Neuve, 13007 Marseille',
        nbAvis: 18,
        noteMoy: 3.8,
        moyParType: {
          'hygiene': 3.5,
          'ambiance': 4.2,
          'securite': 3.8,
          'personnel': 3.7,
        },
      ),
      BarStat(
        id: '3',
        nom: 'O\'Malley\'s Irish Pub',
        lat: 43.2940,
        lng: 5.3680,
        adresse: '2 Place aux Huiles, 13001 Marseille',
        nbAvis: 32,
        noteMoy: 4.5,
        moyParType: {
          'hygiene': 4.3,
          'ambiance': 4.8,
          'securite': 4.2,
          'personnel': 4.6,
        },
      ),
      BarStat(
        id: '4',
        nom: 'Café Parisien',
        lat: 43.2960,
        lng: 5.3720,
        adresse: '1 Place Sadi Carnot, 13002 Marseille',
        nbAvis: 15,
        noteMoy: 3.6,
      ),
      BarStat(
        id: '5',
        nom: 'Le Comptoir du 7ème',
        lat: 43.2870,
        lng: 5.3600,
        adresse: '45 Rue Sainte, 13007 Marseille',
        nbAvis: 28,
        noteMoy: 4.1,
      ),
    ];
  }

  static Map<String, dynamic>? _getMockBarById(String id) {
    final bars = {
      '1': {
        'id': '1',
        'nom': 'Le Vieux Port Bar',
        'adresse': '12 Quai du Port, 13002 Marseille',
        'lat': 43.2946,
        'lng': 5.3750,
      },
      '2': {
        'id': '2',
        'nom': 'Bar de la Marine',
        'adresse': '15 Quai de Rive Neuve, 13007 Marseille',
        'lat': 43.2955,
        'lng': 5.3745,
      },
      '3': {
        'id': '3',
        'nom': 'O\'Malley\'s Irish Pub',
        'adresse': '2 Place aux Huiles, 13001 Marseille',
        'lat': 43.2940,
        'lng': 5.3680,
      },
    };
    return bars[id];
  }

  static List<AvisItem> _getMockReviews(String barId) {
    return [
      AvisItem(
        id: '1',
        type: 'ambiance',
        note: 5,
        commentaire: 'Excellente ambiance, très animé !',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AvisItem(
        id: '2',
        type: 'hygiene',
        note: 4,
        commentaire: 'Propre, toilettes correctes.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      AvisItem(
        id: '3',
        type: 'personnel',
        note: 5,
        commentaire: 'Personnel très accueillant et professionnel.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      AvisItem(
        id: '4',
        type: 'securite',
        note: 4,
        commentaire: 'Je me suis senti en sécurité.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }
}