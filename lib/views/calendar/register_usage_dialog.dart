import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/usage_controller.dart';
import '../../utils/date_format.dart';

/// Diálogo compartilhado para registrar o uso de um look. Permite escolher a
/// data (padrão [initialDate] ou hoje) e, opcionalmente, o horário.
Future<void> showRegisterUsageDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String outfitId,
  DateTime? initialDate,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _RegisterUsageDialog(
      outfitId: outfitId,
      initialDate: initialDate ?? DateTime.now(),
    ),
  );
}

class _RegisterUsageDialog extends ConsumerStatefulWidget {
  final String outfitId;
  final DateTime initialDate;
  const _RegisterUsageDialog({
    required this.outfitId,
    required this.initialDate,
  });

  @override
  ConsumerState<_RegisterUsageDialog> createState() =>
      _RegisterUsageDialogState();
}

class _RegisterUsageDialogState extends ConsumerState<_RegisterUsageDialog> {
  late DateTime _date;
  bool _hasTime = false;
  TimeOfDay _time = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _date = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _confirm() async {
    final when = _hasTime
        ? DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute)
        : DateTime(_date.year, _date.month, _date.day);
    await ref.read(usageControllerProvider.notifier).register(
          outfitId: widget.outfitId,
          when: when,
          hasTime: _hasTime,
        );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uso registrado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar uso'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Data'),
            subtitle: Text(formatDay(_date)),
            onTap: _pickDate,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Incluir horário'),
            value: _hasTime,
            onChanged: (v) => setState(() => _hasTime = v),
          ),
          if (_hasTime)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Horário'),
              subtitle: Text(_time.format(context)),
              onTap: _pickTime,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _confirm, child: const Text('Registrar')),
      ],
    );
  }
}
