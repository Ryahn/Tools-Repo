import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry padding;
  const ErrorBanner({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cs.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: cs.onError, fontSize: 14, height: 1.25),
        child: Text(message),
      ),
    );
  }
}
