import 'package:flutter/material.dart';
import '../services/bar_service.dart';
import 'bar_detail_page.dart';

class BarsListPage extends StatefulWidget {
  const BarsListPage({super.key});
  @override
  State<BarsListPage> createState() => _BarsListPageState();
}

class _BarsListPageState extends State<BarsListPage> {
  final _svc = BarService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _bars = [];

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
      final data = await _svc.fetchBarStats();
      setState(() {
        _bars = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tous les bars')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Erreur: $_error'),
              const SizedBox(height: 8),
              FilledButton(onPressed: _load, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    // Tri par meilleure note (null en dernier)
    _bars.sort((a, b) {
      final na = (a['note_moy'] as num?)?.toDouble();
      final nb = (b['note_moy'] as num?)?.toDouble();
      if (na == null && nb == null) return 0;
      if (na == null) return 1;
      if (nb == null) return -1;
      return nb.compareTo(na);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tous les bars')),
      body: ListView.separated(
        itemCount: _bars.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final b = _bars[i];
          final id = b['bar_id'] ?? b['id']; // selon la vue
          final note = (b['note_moy'] as num?)?.toDouble();
          return ListTile(
            leading: _NoteBadge(value: note),
            title: Text(b['nom'] ?? '—'),
            subtitle: Text('${b['adresse'] ?? ''}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BarDetailPage(barId: id.toString())),
            ),
          );
        },
      ),
    );
  }
}

class _NoteBadge extends StatelessWidget {
  final double? value;
  const _NoteBadge({required this.value});
  @override
  Widget build(BuildContext context) {
    final v = value;
    Color bg;
    if (v == null) {
      bg = Colors.grey;
    } else if (v >= 4) {
      bg = Colors.green;
    } else if (v >= 2) {
      bg = Colors.orange;
    } else {
      bg = Colors.red;
    }
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bg.withAlpha(38), borderRadius: BorderRadius.circular(8)),
      child: Text(v?.toStringAsFixed(1) ?? '—',
          style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
    );
  }
}
