import 'package:flutter/material.dart';

import 'toropass_client.dart';
import 'toropass_result.dart';

class ToroPassButton extends StatefulWidget {
  final ToroPassClient client;
  final String? appName;
  final String label;
  final String loadingLabel;
  final ButtonStyle? style;
  final Widget? icon;
  final Widget? loadingIndicator;
  final ValueChanged<ToroPassAuthResult>? onResult;

  const ToroPassButton({
    super.key,
    required this.client,
    this.appName,
    this.label = 'Verify with ToroPass',
    this.loadingLabel = 'Opening ToroPass...',
    this.style,
    this.icon,
    this.loadingIndicator,
    this.onResult,
  });

  @override
  State<ToroPassButton> createState() => _ToroPassButtonState();
}

class _ToroPassButtonState extends State<ToroPassButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final onPressed = _isLoading ? null : _handlePressed;

    return FilledButton.icon(
      onPressed: onPressed,
      style: widget.style,
      icon:
          _isLoading
              ? widget.loadingIndicator ??
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
              : (widget.icon ?? const Icon(Icons.verified_user_outlined)),
      label: Text(_isLoading ? widget.loadingLabel : widget.label),
    );
  }

  Future<void> _handlePressed() async {
    setState(() => _isLoading = true);

    try {
      final result = await widget.client.verifyIdentity(appName: widget.appName);
      widget.onResult?.call(result);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
