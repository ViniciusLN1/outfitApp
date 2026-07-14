import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wrapper padrão para `AsyncValue`: loading e erro consistentes, sem expor
/// exceções cruas na UI. Use no lugar dos helpers `.when` espalhados.
class AsyncSection<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;

  const AsyncSection({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => Padding(
        padding: padding,
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, _) => Padding(
        padding: padding,
        child: ErrorNotice(onRetry: onRetry),
      ),
    );
  }
}

/// Mensagem de erro discreta e acionável (nunca o stack trace).
class ErrorNotice extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorNotice({
    super.key,
    this.message = 'Não foi possível carregar.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 16, color: scheme.error),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Tentar de novo')),
      ],
    );
  }
}
