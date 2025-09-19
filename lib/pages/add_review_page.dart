import 'package:flutter/material.dart';
import 'package:soireesafe/models.dart';
import 'package:soireesafe/services/bar_service.dart';

class AddReviewPage extends StatefulWidget {
  final String barId;

  const AddReviewPage({
    super.key,
    required this.barId,
  });

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ctrl = TextEditingController();
  final _svc = BarService();

  String? _type;
  int _note = 3;
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_sending) {
      return;
    }

    final form = _formKey.currentState;
    if (form == null || !form.validate() || _type == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez remplir tous les champs requis'),
          ),
        );
      }
      return;
    }

    setState(() {
      _sending = true;
    });

    final note = _note.round();
    final comment = _ctrl.text;

    try {
      await _svc.addReview(
        barId: widget.barId,
        type: _type!,
        note: note,
        commentaire: comment.isEmpty ? null : comment,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avis ajout? avec succ?s')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un avis'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelection(),
              const SizedBox(height: 24),
              _buildRatingSelection(),
              const SizedBox(height: 24),
              _buildCommentField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type d\'évaluation *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AvisItem.reviewTypes.map((type) {
            final isSelected = _type == type;
            return FilterChip(
              label: Text(AvisItem.getTypeLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _type = selected ? type : null;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _note = rating;
                  });
                },
                child: Icon(
                  Icons.star,
                  size: 40,
                  color: rating <= _note ? Colors.amber : Colors.grey[300],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '$_note/5',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commentaire (optionnel)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _ctrl,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Partagez votre expérience...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Le commentaire ne peut pas dépasser 500 caractères';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _sending ? null : _submitReview,
        child: _sending
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Envoi en cours...'),
                ],
              )
            : const Text('Publier l\'avis'),
      ),
    );
  }
}
