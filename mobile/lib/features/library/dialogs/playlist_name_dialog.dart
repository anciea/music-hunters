import 'package:flutter/material.dart';

/// A reusable dialog for creating or renaming a playlist.
///
/// Accepts a [title], optional [initialName] for rename flows, and
/// [confirmLabel] ("Create Playlist" or "Rename"). Returns the entered
/// name string, or null if dismissed.
class PlaylistNameDialog extends StatefulWidget {
  const PlaylistNameDialog({
    super.key,
    required this.title,
    this.initialName,
    required this.confirmLabel,
  });

  final String title;
  final String? initialName;
  final String confirmLabel;

  /// Shows the dialog and returns the entered name, or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? initialName,
    required String confirmLabel,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => PlaylistNameDialog(
        title: title,
        initialName: initialName,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  State<PlaylistNameDialog> createState() => _PlaylistNameDialogState();
}

class _PlaylistNameDialogState extends State<PlaylistNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 50,
        decoration: InputDecoration(
          hintText: 'Playlist name',
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          filled: true,
          fillColor: const Color(0xFF121212),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: _isValid ? (_) => _confirm() : null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text(
            'Never mind',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        TextButton(
          onPressed: _isValid ? _confirm : null,
          child: Text(
            widget.confirmLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isValid
                  ? const Color(0xFF1DB954)
                  : const Color(0xFF9E9E9E),
            ),
          ),
        ),
      ],
    );
  }

  void _confirm() {
    Navigator.of(context).pop(_controller.text.trim());
  }
}
