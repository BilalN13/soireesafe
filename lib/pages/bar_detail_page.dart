import 'package:flutter/material.dart';
import '../services/bar_service.dart';
import 'add_review_page.dart';

class BarDetailPage extends StatefulWidget {
  final String barId;
  const BarDetailPage({super.key, required this.barId});

  @override
  State<BarDetailPage> createState() => _BarDetailPageState();
}

class _BarDetailPageState extends State<BarDetailPage> {
  final _svc = BarService();
  Map<String, dynamic>? _bar;
  List<Map<String, dynamic>> _avis = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final barFuture = _svc.fetchBarById(widget.barId);
      final reviewsFuture = _svc.fetchLastReviews(widget.barId, limit: 10);
      final bar = await barFuture;
      final reviews = await reviewsFuture;
      if (!mounted) {
        return;
      }
      setState(() {
        _bar = bar;
        _avis = reviews;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bar')),
        body: Center(child: Text('Erreur: $_error')),
      );
    }
    final b = _bar!;
    return Scaffold(
      appBar: AppBar(title: Text(b['nom'] as String? ?? 'Bar')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_comment),
        label: const Text('Ajouter un avis'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReviewPage(barId: widget.barId),
            ),
          );
          await _load(); // refresh apres retour
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            b['nom'] as String? ?? 'Bar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            b['adresse'] as String? ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Derniers avis',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (_avis.isEmpty) const Text('Aucun avis pour le moment.'),
          for (final avis in _avis)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Chip(
                  label: Text(
                    (avis['type'] as String).substring(0, 1).toUpperCase() +
                        (avis['type'] as String).substring(1),
                  ),
                ),
                title: Text('${avis['note']}/5'),
                subtitle: (avis['commentaire'] as String?)?.isNotEmpty == true
                    ? Text(avis['commentaire'] as String)
                    : null,
                dense: true,
              ),
            ),
        ],
      ),
    );
  }
}
