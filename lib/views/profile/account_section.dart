import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/dialogs.dart';

class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final session = auth.valueOrNull;
    final scheme = Theme.of(context).colorScheme;

    if (session == null) {
      return AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.login, color: scheme.primary),
              title: const Text('Entrar',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Recupere suas peças e looks salvos'),
              trailing: const Icon(Icons.chevron_right),
              enabled: !auth.isLoading,
              onTap: () => _showAuthDialog(context, ref, register: false),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            ListTile(
              leading: Icon(Icons.person_add_outlined, color: scheme.primary),
              title: const Text('Criar conta',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Salve seus dados para não perdê-los'),
              trailing: const Icon(Icons.chevron_right),
              enabled: !auth.isLoading,
              onTap: () => _showAuthDialog(context, ref, register: true),
            ),
          ],
        ),
      );
    }

    final sync = ref.watch(syncControllerProvider);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.verified_user_outlined, color: scheme.primary),
            title: Text(session.username,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(_syncLabel(sync)),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          ListTile(
            leading: sync.phase == SyncPhase.syncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: scheme.primary),
                  )
                : Icon(Icons.sync, color: scheme.primary),
            title: const Text('Sincronizar agora',
                style: TextStyle(fontWeight: FontWeight.w600)),
            enabled: sync.phase != SyncPhase.syncing,
            onTap: () => ref.read(syncControllerProvider.notifier).syncNow(),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          ListTile(
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text('Sair',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: scheme.error)),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  String _syncLabel(SyncState sync) {
    switch (sync.phase) {
      case SyncPhase.syncing:
        return 'Sincronizando…';
      case SyncPhase.error:
        return 'Erro na última sincronização';
      case SyncPhase.idle:
        final at = sync.lastSyncAt;
        if (at == null) return 'Conta conectada';
        final h = at.hour.toString().padLeft(2, '0');
        final m = at.minute.toString().padLeft(2, '0');
        return 'Sincronizado às $h:$m';
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Sair da conta',
      message: 'Seus dados continuam salvos neste aparelho e no servidor, '
          'e voltam no próximo login.',
      confirmLabel: 'Sair',
    );
    if (confirmed) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  Future<void> _showAuthDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool register,
  }) async {
    final outcome = await showDialog<LoginOutcome>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AuthDialog(register: register),
    );
    if (outcome == null || !context.mounted) return;
    await _handleOutcome(context, ref, outcome);
  }

  Future<void> _handleOutcome(
    BuildContext context,
    WidgetRef ref,
    LoginOutcome outcome,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    switch (outcome) {
      case LoginOutcome.needsGuestChoice:
        final import = await confirmDialog(
          context,
          title: 'Levar seus dados?',
          message: 'Deseja levar as peças e looks do modo convidado para '
              'esta conta? Eles também serão salvos no servidor.',
          confirmLabel: 'Levar dados',
          cancelLabel: 'Começar vazia',
        );
        await ref
            .read(authControllerProvider.notifier)
            .completeLogin(importGuestData: import);
        if (import) {
          await ref.read(syncControllerProvider.notifier).syncNow();
        }
      case LoginOutcome.restored:
        messenger.showSnackBar(
          const SnackBar(content: Text('Dados da conta restaurados.')),
        );
      case LoginOutcome.offline:
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Sem conexão: usando os dados locais da conta.'),
          ),
        );
      case LoginOutcome.empty:
        break;
    }
  }
}

class _AuthDialog extends ConsumerStatefulWidget {
  final bool register;
  const _AuthDialog({required this.register});

  @override
  ConsumerState<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends ConsumerState<_AuthDialog> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    if (username.length < 3) {
      setState(() => _error = 'O usuário precisa de ao menos 3 caracteres.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'A senha precisa de ao menos 6 caracteres.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = ref.read(authControllerProvider.notifier);
      final outcome = widget.register
          ? await auth.register(username, password)
          : await auth.login(username, password);
      if (mounted) Navigator.pop(context, outcome);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = switch (e.statusCode) {
          401 => 'Usuário ou senha incorretos.',
          409 => 'Este nome de usuário já está em uso.',
          _ => 'Não foi possível concluir. Tente novamente.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Sem conexão com o servidor. Verifique a rede.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.register ? 'Criar conta' : 'Entrar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _userCtrl,
            enabled: !_busy,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Usuário'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            enabled: !_busy,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Senha',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: scheme.onPrimary),
                )
              : Text(widget.register ? 'Criar' : 'Entrar'),
        ),
      ],
    );
  }
}
