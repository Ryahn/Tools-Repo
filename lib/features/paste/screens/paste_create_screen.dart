import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/core/utils/responsive.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/features/paste/models/paste.dart';
import 'package:rule7_app/features/paste/providers/paste_provider.dart';
import 'package:rule7_app/features/paste/screens/paste_view_screen.dart';
import 'package:rule7_app/shared/layouts/main_layout.dart';
import 'package:url_launcher/url_launcher.dart';

/// Paste Create Screen
class PasteCreateScreen extends ConsumerStatefulWidget {
  const PasteCreateScreen({super.key});

  @override
  ConsumerState<PasteCreateScreen> createState() => _PasteCreateScreenState();
}

class _PasteCreateScreenState extends ConsumerState<PasteCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contentController;
  late TextEditingController _slugController;
  String _selectedLanguage = 'plaintext';
  bool _isPrivate = false;
  String _expirationOption = 'never';
  bool _isLoading = false;

  final List<String> _languages = [
    'plaintext',
    'bash',
    'c',
    'cpp',
    'css',
    'html',
    'java',
    'javascript',
    'json',
    'php',
    'python',
    'ruby',
    'rust',
    'sql',
    'xml',
  ];

  final Map<String, String> _expirationOptions = {
    'never': 'Never',
    '1hour': '1 Hour',
    '1day': '1 Day',
    '1week': '1 Week',
    '1month': '1 Month',
  };

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _slugController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  DateTime? _getExpiresAt() {
    switch (_expirationOption) {
      case '1hour':
        return DateTime.now().add(const Duration(hours: 1));
      case '1day':
        return DateTime.now().add(const Duration(days: 1));
      case '1week':
        return DateTime.now().add(const Duration(days: 7));
      case '1month':
        return DateTime.now().add(const Duration(days: 30));
      default:
        return null;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(pasteRepositoryProvider);
      final data = {
        'content': _contentController.text,
        'language': _selectedLanguage,
        'private': _isPrivate,
        'expires_at': _getExpiresAt()?.toIso8601String(),
        if (_slugController.text.isNotEmpty) 'slug': _slugController.text,
      };

      final paste = await repository.createPaste(data);

      if (mounted) {
        // Show success and navigate to view
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paste created successfully')),
        );

        // Navigate to view screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PasteViewScreen(pasteSlug: paste.slug),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating paste: $e')));
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
    final responsive = Responsive(context);

    return MainLayout(
      title: 'Create Paste',
      currentIndex: 4,
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
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _handleSubmit,
            tooltip: 'Create Paste',
          ),
      ],
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Paste your text here...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: responsive.isDesktop ? 20 : 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter paste content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Language
              DropdownButtonFormField<String>(
                initialValue: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(),
                ),
                items: _languages.map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value ?? 'plaintext';
                  });
                },
              ),
              const SizedBox(height: 16),

              // Private toggle
              SwitchListTile(
                title: const Text('Private'),
                subtitle: const Text('Only you can view this paste'),
                value: _isPrivate,
                onChanged: (value) {
                  setState(() {
                    _isPrivate = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Expiration
              DropdownButtonFormField<String>(
                initialValue: _expirationOption,
                decoration: const InputDecoration(
                  labelText: 'Expiration',
                  border: OutlineInputBorder(),
                ),
                items: _expirationOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _expirationOption = value ?? 'never';
                  });
                },
              ),
              const SizedBox(height: 16),

              // Custom slug (optional)
              TextFormField(
                controller: _slugController,
                decoration: const InputDecoration(
                  labelText: 'Custom Slug (Optional)',
                  hintText: 'Leave empty to auto-generate',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Info card
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'After creating, you\'ll get a shareable link to view the paste.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
