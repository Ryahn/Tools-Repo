import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/promotions/models/promotion.dart';
import 'package:rule7_app/features/promotions/providers/promotion_provider.dart';
import 'package:rule7_app/widgets/confirmation_dialog.dart';

class PromotionFormScreen extends ConsumerStatefulWidget {
  final Promotion? promotion; // If null, create new; otherwise, edit existing

  const PromotionFormScreen({super.key, this.promotion});

  @override
  ConsumerState<PromotionFormScreen> createState() =>
      _PromotionFormScreenState();
}

class _PromotionFormScreenState extends ConsumerState<PromotionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _devNameController;
  late TextEditingController _gameNameController;
  late TextEditingController _threadIdController;
  late TextEditingController _reasonController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final promotion = widget.promotion;
    _devNameController = TextEditingController(text: promotion?.devName ?? '');
    _gameNameController = TextEditingController(
      text: promotion?.gameName ?? '',
    );
    _threadIdController = TextEditingController(
      text: promotion?.threadId.toString() ?? '',
    );
    _reasonController = TextEditingController(text: promotion?.reason ?? '');
  }

  @override
  void dispose() {
    _devNameController.dispose();
    _gameNameController.dispose();
    _threadIdController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await ConfirmationDialog.show(
      context,
      title: widget.promotion == null ? 'Create Promotion' : 'Update Promotion',
      message: widget.promotion == null
          ? 'Are you sure you want to create this promotion?'
          : 'Are you sure you want to update this promotion?',
      confirmText: widget.promotion == null ? 'Create' : 'Update',
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(promotionRepositoryProvider);
      final data = {
        'dev_name': _devNameController.text,
        'game_name': _gameNameController.text,
        'thread_id': int.parse(_threadIdController.text),
        'reason': _reasonController.text,
      };

      if (widget.promotion == null) {
        await repository.createPromotion(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Promotion created successfully')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await repository.updatePromotion(widget.promotion!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Promotion updated successfully')),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.promotion == null ? 'Create Promotion' : 'Edit Promotion',
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _handleSubmit),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Developer Name
              TextFormField(
                controller: _devNameController,
                decoration: const InputDecoration(
                  labelText: 'Developer Name',
                  hintText: 'Enter developer name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a developer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Game Name
              TextFormField(
                controller: _gameNameController,
                decoration: const InputDecoration(
                  labelText: 'Game Name',
                  hintText: 'Enter game name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a game name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Thread ID
              TextFormField(
                controller: _threadIdController,
                decoration: const InputDecoration(
                  labelText: 'Thread ID',
                  hintText: 'Enter F95Zone thread ID',
                  prefixText: 'https://f95zone.to/threads/',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a thread ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Thread ID must be a number';
                  }
                  if (int.parse(value) < 1) {
                    return 'Thread ID must be at least 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Enter the reason for this promotion',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
