import 'package:flutter/material.dart';
import 'package:soireesafe/services/bar_service.dart';
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
      if (!mounted) {
        return;
      }
      setState(() {
        _bars = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
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
    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = _ErrorView(error: _error!, onRetry: _load);
    } else {
      final bars = List<Map<String, dynamic>>.from(_bars)
        ..sort((a, b) {
          final na = (a['note_moy'] as num?)?.toDouble();
          final nb = (b['note_moy'] as num?)?.toDouble();
          if (na == null && nb == null) {
            return 0;
          }
          if (na == null) {
            return 1;
          }
          if (nb == null) {
            return -1;
          }
          return nb.compareTo(na);
        });

      body = ListView.separated(
        itemCount: bars.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final bar = bars[index];
          final id = bar['bar_id'] ?? bar['id'];
          final note = (bar['note_moy'] as num?)?.toDouble();

          return ListTile(
            leading: _NoteBadge(value: note),
            title: Text(bar['nom'] as String? ?? 'Sans nom'),
            subtitle: Text(bar['adresse'] as String? ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BarDetailPage(barId: '$id'),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tous les bars')),
      body: body,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Erreur: $error'),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Reessayer'),
          ),
        ],
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
    Color color;

    if (v == null) {
      color = Colors.grey;
    } else if (v >= 4) {
      color = Colors.green;
    } else if (v >= 2) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        v?.toStringAsFixed(1) ?? 'â€”',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
