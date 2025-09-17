import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soireesafe/models.dart';
import 'package:soireesafe/services/bar_service.dart';
import 'package:soireesafe/widgets/rating_badge.dart';
import 'package:soireesafe/pages/add_review_page.dart';

class BarDetailPage extends StatefulWidget {
  final String barId;

  const BarDetailPage({
    super.key,
    required this.barId,
  });

  @override
  State<BarDetailPage> createState() => _BarDetailPageState();
}

class _BarDetailPageState extends State<BarDetailPage> {
  Map<String, dynamic>? barInfo;
  List<AvisItem> reviews = [];
  bool isLoadingBar = true;
  bool isLoadingReviews = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _loadBarDetails();
    _loadReviews();
  }

  void _checkAuthState() {
    setState(() {
      isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    });
  }

  Future<void> _loadBarDetails() async {
    try {
      final details = await BarService.fetchBarById(widget.barId);
      setState(() {
        barInfo = details;
        isLoadingBar = false;
      });
    } catch (e) {
      setState(() {
        isLoadingBar = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviewsList = await BarService.fetchLastReviews(widget.barId);
      setState(() {
        reviews = reviewsList;
        isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        isLoadingReviews = false;
      });
    }
  }

  Future<void> _navigateToAddReview() async {
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour ajouter un avis'),
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddReviewPage(barId: widget.barId),
      ),
    );

    if (result == true) {
      _loadReviews(); // Refresh reviews after adding a new one
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(barInfo?['nom'] ?? 'Chargement...'),
      ),
      body: isLoadingBar
          ? const Center(child: CircularProgressIndicator())
          : barInfo == null
              ? const Center(child: Text('Bar non trouvé'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBarHeader(),
                      const SizedBox(height: 24),
                      _buildAddReviewButton(),
                      const SizedBox(height: 24),
                      _buildReviewsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBarHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_bar,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    barInfo!['nom'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            if (barInfo!['adresse'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      barInfo!['adresse'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddReviewButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _navigateToAddReview,
        icon: const Icon(Icons.add_comment),
        label: const Text('Ajouter un avis'),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.rate_review,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Derniers avis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (isLoadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (reviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Aucun avis pour le moment'),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewCard(review: review);
            },
          ),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final AvisItem review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AvisItem.getTypeLabel(review.type),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                RatingBadge(
                  rating: review.note.toDouble(),
                  size: 28,
                ),
              ],
            ),
            if (review.commentaire != null) ...[
              const SizedBox(height: 12),
              Text(
                review.commentaire!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              formatter.format(review.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}