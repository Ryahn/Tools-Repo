import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/features/dmca/models/dmca.dart';
import 'package:rule7_app/features/dmca/providers/dmca_provider.dart';
import 'package:rule7_app/widgets/confirmation_dialog.dart';

class DmcaFormScreen extends ConsumerStatefulWidget {
  final Dmca? dmca; // If null, create new; otherwise, edit existing

  const DmcaFormScreen({super.key, this.dmca});

  @override
  ConsumerState<DmcaFormScreen> createState() => _DmcaFormScreenState();
}

class _DmcaFormScreenState extends ConsumerState<DmcaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gameNameController;
  late TextEditingController _devNameController;
  late TextEditingController _gameUrlController;
  late TextEditingController _severityController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final dmca = widget.dmca;
    _gameNameController = TextEditingController(text: dmca?.gameName ?? '');
    _devNameController = TextEditingController(text: dmca?.devName ?? '');
    _gameUrlController = TextEditingController(text: dmca?.gameUrl ?? '');
    _severityController = TextEditingController(text: dmca?.severity ?? '');
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _devNameController.dispose();
    _gameUrlController.dispose();
    _severityController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await ConfirmationDialog.show(
      context,
      title: widget.dmca == null ? 'Create DMCA Entry' : 'Update DMCA Entry',
      message: widget.dmca == null
          ? 'Are you sure you want to create this DMCA entry?'
          : 'Are you sure you want to update this DMCA entry?',
      confirmText: widget.dmca == null ? 'Create' : 'Update',
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(dmcaRepositoryProvider);
      final data = {
        'game_name': _gameNameController.text,
        'dev_name': _devNameController.text,
        'game_url': _gameUrlController.text,
        'severity': _severityController.text,
      };

      if (widget.dmca == null) {
        await repository.createDmca(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DMCA entry created successfully')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        await repository.updateDmca(widget.dmca!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('DMCA entry updated successfully')),
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
          widget.dmca == null ? 'Create DMCA Entry' : 'Edit DMCA Entry',
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

              // Game URL
              TextFormField(
                controller: _gameUrlController,
                decoration: const InputDecoration(
                  labelText: 'Game URL (F95Zone)',
                  hintText: 'https://f95zone.to/threads/...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a game URL';
                  }
                  if (!value.startsWith('https://f95zone.to/threads/')) {
                    return 'URL must be a F95Zone thread URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Severity
              TextFormField(
                controller: _severityController,
                decoration: const InputDecoration(
                  labelText: 'Severity',
                  hintText: 'e.g., 1 Time, 2+ Times, Unknown',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter severity';
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
