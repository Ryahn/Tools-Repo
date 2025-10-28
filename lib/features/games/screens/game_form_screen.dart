import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule7_app/features/auth/providers/auth_provider.dart';
import 'package:rule7_app/features/games/models/game.dart';
import 'package:rule7_app/features/games/providers/game_provider.dart';
import 'package:rule7_app/widgets/confirmation_dialog.dart';

class GameFormScreen extends ConsumerStatefulWidget {
  final Game? game; // If null, create new game; otherwise, edit existing

  const GameFormScreen({super.key, this.game});

  @override
  ConsumerState<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends ConsumerState<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gameNameController;
  late TextEditingController _authorController;
  late TextEditingController _gameNameJapController;
  late TextEditingController _gameNameRomajiController;
  late TextEditingController _reasonController;
  late TextEditingController _rulingController;
  late TextEditingController _customReasonController;
  late TextEditingController _customRulingController;
  late TextEditingController _steamLinkController;
  late TextEditingController _dlsiteLinkController;
  late TextEditingController _itchLinkController;
  late TextEditingController _patreonLinkController;
  late TextEditingController _vndbLinkController;
  late String _approvalStatus;
  late bool _isAuthorBanned;
  bool _isLoading = false;
  String? _selectedReason;
  String? _selectedRuling;

  @override
  void initState() {
    super.initState();
    final game = widget.game;
    _gameNameController = TextEditingController(text: game?.gameName ?? '');
    _authorController = TextEditingController(text: game?.author ?? '');
    _gameNameJapController = TextEditingController(
      text: game?.gameNameJap ?? '',
    );
    _gameNameRomajiController = TextEditingController(
      text: game?.gameNameRomaji ?? '',
    );
    _reasonController = TextEditingController(text: game?.reason ?? '');
    _rulingController = TextEditingController(text: game?.ruling ?? '');
    _customReasonController = TextEditingController();
    _customRulingController = TextEditingController();
    _steamLinkController = TextEditingController(text: game?.steamLink ?? '');

    // Set initial selection for dropdowns
    // Check if reason exists in predefined list
    final reasonList = [
      'Rule7 2D Unrealistic',
      'Rule7 2D Realistic',
      'Rule7 2D Toddlercon',
      'Rule10 2D Bestiality',
      'Rule10 2D Gore',
      'Rule7 3D Unrealistic',
      'Rule7 3D Realistic',
      'Rule7 3D Toddlercon',
      'Rule10 3D Bestiality',
      'Rule10 3D Gore',
      'Rule3.8 Ads',
      'Game1.3 Online',
      'Allowed',
    ];
    if (game?.reason != null &&
        game!.reason.isNotEmpty &&
        !reasonList.contains(game.reason)) {
      _selectedReason = 'custom';
      _customReasonController.text = game.reason;
    } else {
      _selectedReason = game?.reason;
    }

    // Check if ruling exists in predefined list
    final rulingList = ['Perma-Banned', 'Allowed', 'pending'];
    if (game?.ruling != null &&
        game!.ruling.isNotEmpty &&
        !rulingList.contains(game.ruling)) {
      _selectedRuling = 'custom';
      _customRulingController.text = game.ruling;
    } else {
      _selectedRuling = game?.ruling;
    }
    _dlsiteLinkController = TextEditingController(text: game?.dlsiteLink ?? '');
    _itchLinkController = TextEditingController(text: game?.itchLink ?? '');
    _patreonLinkController = TextEditingController(
      text: game?.patreonLink ?? '',
    );
    _vndbLinkController = TextEditingController(text: game?.vndbLink ?? '');
    _approvalStatus = game?.approved ?? 'pending';
    _isAuthorBanned = game?.isAuthorBanned ?? false;
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _authorController.dispose();
    _gameNameJapController.dispose();
    _gameNameRomajiController.dispose();
    _reasonController.dispose();
    _rulingController.dispose();
    _customReasonController.dispose();
    _customRulingController.dispose();
    _steamLinkController.dispose();
    _dlsiteLinkController.dispose();
    _itchLinkController.dispose();
    _patreonLinkController.dispose();
    _vndbLinkController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await ConfirmationDialog.show(
      context,
      title: widget.game == null ? 'Create Game' : 'Update Game',
      message: widget.game == null
          ? 'Are you sure you want to create this game?'
          : 'Are you sure you want to update this game?',
      confirmText: widget.game == null ? 'Create' : 'Update',
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(gameRepositoryProvider);
      final data = {
        'game_name': _gameNameController.text,
        'author': _authorController.text,
        'game_name_jap': _gameNameJapController.text.isEmpty
            ? null
            : _gameNameJapController.text,
        'game_name_romaji': _gameNameRomajiController.text.isEmpty
            ? null
            : _gameNameRomajiController.text,
        'reason': _selectedReason == 'custom'
            ? _customReasonController.text
            : (_selectedReason ?? ''),
        'ruling': _selectedRuling == 'custom'
            ? _customRulingController.text
            : (_selectedRuling ?? ''),
        'approved': _approvalStatus,
        'isAuthorBanned': _isAuthorBanned,
        'steam_link': _steamLinkController.text.isEmpty
            ? null
            : _steamLinkController.text,
        'dlsite_link': _dlsiteLinkController.text.isEmpty
            ? null
            : _dlsiteLinkController.text,
        'itch_link': _itchLinkController.text.isEmpty
            ? null
            : _itchLinkController.text,
        'patreon_link': _patreonLinkController.text.isEmpty
            ? null
            : _patreonLinkController.text,
        'vndb_link': _vndbLinkController.text.isEmpty
            ? null
            : _vndbLinkController.text,
      };

      if (widget.game == null) {
        await repository.createGame(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game created successfully')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        data['id'] = widget.game!.id;
        await repository.updateGame(widget.game!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game updated successfully')),
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

  Future<void> _handleDelete() async {
    if (widget.game == null) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Game',
      message:
          'Are you sure you want to delete "${widget.game!.gameName}"? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(gameRepositoryProvider);
      await repository.deleteGame(widget.game!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game deleted successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting game: $e')));
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
    final authState = ref.watch(authStateProvider);
    final canDelete =
        authState.valueOrNull?.hasPermission('games.delete') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game == null ? 'Create Game' : 'Edit Game'),
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
          else ...[
            // Show delete button only when editing and user has permission
            if (widget.game != null && canDelete)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _handleDelete,
                tooltip: 'Delete Game',
              ),
            IconButton(icon: const Icon(Icons.save), onPressed: _handleSubmit),
          ],
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game name
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

              // Author
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  hintText: 'Enter author name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Japanese name
              TextFormField(
                controller: _gameNameJapController,
                decoration: const InputDecoration(
                  labelText: 'Japanese Name (Optional)',
                  hintText: 'Enter Japanese name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Romaji name
              TextFormField(
                controller: _gameNameRomajiController,
                decoration: const InputDecoration(
                  labelText: 'Romaji Name (Optional)',
                  hintText: 'Enter Romaji name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Reason dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select a reason...'),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Select a reason...'),
                  ),
                  ...[
                    'Rule7 2D Unrealistic',
                    'Rule7 2D Realistic',
                    'Rule7 2D Toddlercon',
                    'Rule10 2D Bestiality',
                    'Rule10 2D Gore',
                  ].map(
                    (reason) =>
                        DropdownMenuItem(value: reason, child: Text(reason)),
                  ),
                  ...[
                    'Rule7 3D Unrealistic',
                    'Rule7 3D Realistic',
                    'Rule7 3D Toddlercon',
                    'Rule10 3D Bestiality',
                    'Rule10 3D Gore',
                  ].map(
                    (reason) =>
                        DropdownMenuItem(value: reason, child: Text(reason)),
                  ),
                  ...['Rule3.8 Ads', 'Game1.3 Online', 'Allowed'].map(
                    (reason) =>
                        DropdownMenuItem(value: reason, child: Text(reason)),
                  ),
                  const DropdownMenuItem(
                    value: 'custom',
                    child: Text('Custom Reason'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedReason == 'custom')
                Column(
                  children: [
                    TextFormField(
                      controller: _customReasonController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Reason',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a custom reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Ruling dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedRuling,
                decoration: const InputDecoration(
                  labelText: 'Ruling',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select a ruling...'),
                items: const [
                  DropdownMenuItem(
                    value: '',
                    child: Text('Select a ruling...'),
                  ),
                  DropdownMenuItem(
                    value: 'Perma-Banned',
                    child: Text('Perma-Banned'),
                  ),
                  DropdownMenuItem(value: 'Allowed', child: Text('Allowed')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRuling = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a ruling';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedRuling == 'custom')
                Column(
                  children: [
                    TextFormField(
                      controller: _customRulingController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Ruling',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a custom ruling';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              const SizedBox(height: 16),

              // Approval status
              DropdownButtonFormField<String>(
                initialValue: _approvalStatus,
                decoration: const InputDecoration(
                  labelText: 'Approval Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'banned', child: Text('Banned')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _approvalStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Is author banned
              SwitchListTile(
                title: const Text('Author is Banned'),
                value: _isAuthorBanned,
                onChanged: (value) {
                  setState(() {
                    _isAuthorBanned = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Links section
              Text(
                'Links (Optional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _steamLinkController,
                decoration: const InputDecoration(
                  labelText: 'Steam Link',
                  hintText: 'https://store.steampowered.com/...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _dlsiteLinkController,
                decoration: const InputDecoration(
                  labelText: 'DLsite Link',
                  hintText: 'https://www.dlsite.com/...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _itchLinkController,
                decoration: const InputDecoration(
                  labelText: 'Itch.io Link',
                  hintText: 'https://itch.io/...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _patreonLinkController,
                decoration: const InputDecoration(
                  labelText: 'Patreon Link',
                  hintText: 'https://patreon.com/...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _vndbLinkController,
                decoration: const InputDecoration(
                  labelText: 'VNDB Link',
                  hintText: 'https://vndb.org/...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: Text(
                    widget.game == null ? 'Create Game' : 'Update Game',
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
