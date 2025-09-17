import 'package:flutter/material.dart';
import 'package:soireesafe/models.dart';
import 'package:soireesafe/services/bar_service.dart';
import 'package:soireesafe/widgets/rating_badge.dart';
import 'package:soireesafe/pages/bar_detail_page.dart';

class BarsListPage extends StatefulWidget {
  const BarsListPage({super.key});

  @override
  State<BarsListPage> createState() => _BarsListPageState();
}

class _BarsListPageState extends State<BarsListPage> {
  List<BarStat> bars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBars();
  }

  Future<void> _loadBars() async {
    try {
      final barStats = await BarService.fetchBarStats();
      // Sort by average rating desc (null values last)
      barStats.sort((a, b) {
        if (a.noteMoy == null && b.noteMoy == null) return 0;
        if (a.noteMoy == null) return 1;
        if (b.noteMoy == null) return -1;
        return b.noteMoy!.compareTo(a.noteMoy!);
      });

      setState(() {
        bars = barStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les bars'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bars.isEmpty
              ? const Center(
                  child: Text('Aucun bar trouvé'),
                )
              : ListView.builder(
                  itemCount: bars.length,
                  itemBuilder: (context, index) {
                    final bar = bars[index];
                    return BarListTile(
                      bar: bar,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BarDetailPage(barId: bar.id),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class BarListTile extends StatelessWidget {
  final BarStat bar;
  final VoidCallback onTap;

  const BarListTile({
    super.key,
    required this.bar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: RatingBadge(
          rating: bar.noteMoy,
          size: 48,
        ),
        title: Text(
          bar.nom,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (bar.adresse != null)
              Text(
                bar.adresse!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  bar.noteMoy?.toStringAsFixed(1) ?? 'Non noté',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.comment,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${bar.nbAvis} avis',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}