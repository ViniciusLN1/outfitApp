import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/outfit_controller.dart';
import '../../controllers/usage_controller.dart';
import '../../database/app_database.dart';
import '../../utils/date_format.dart';
import '../../widgets/async_section.dart';
import '../../widgets/dialogs.dart';
import 'register_usage_dialog.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _month; // primeiro dia do mês exibido
  late DateTime _selectedDay;
  String? _filterOutfitId; // null = todos os looks

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  Future<void> _pickOutfitAndRegister() async {
    final outfitsAsync =
        ref.read(outfitsSortedProvider(OutfitSortMode.favoritesFirst));
    final outfits = outfitsAsync.value ?? const [];
    if (outfits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum outfit para registrar.')),
      );
      return;
    }
    // Se há um look filtrado, registra direto nele.
    if (_filterOutfitId != null) {
      await showRegisterUsageDialog(
        context: context,
        ref: ref,
        outfitId: _filterOutfitId!,
        initialDate: _selectedDay,
      );
      return;
    }
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Escolha o outfit',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          for (final o in outfits)
            ListTile(
              title: Text(o.name),
              onTap: () => Navigator.pop(context, o.id),
            ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    await showRegisterUsageDialog(
      context: context,
      ref: ref,
      outfitId: chosen,
      initialDate: _selectedDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(usageEntriesProvider(_filterOutfitId));
    final outfits =
        ref.watch(outfitsSortedProvider(OutfitSortMode.favoritesFirst)).value ??
            const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickOutfitAndRegister,
        child: const Icon(Icons.add),
      ),
      body: AsyncSection(
        value: entriesAsync,
        builder: (entries) {
          final counts = <String, int>{};
          for (final e in entries) {
            final d = DateTime.fromMillisecondsSinceEpoch(e.usage.usedAt);
            counts.update(_key(d), (v) => v + 1, ifAbsent: () => 1);
          }
          final dayEntries = entries
              .where((e) {
                final d = DateTime.fromMillisecondsSinceEpoch(e.usage.usedAt);
                return _key(d) == _key(_selectedDay);
              })
              .toList()
            ..sort((a, b) => a.usage.usedAt.compareTo(b.usage.usedAt));

          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              _OutfitFilter(
                outfits: outfits,
                value: _filterOutfitId,
                onChanged: (v) => setState(() => _filterOutfitId = v),
              ),
              _MonthHeader(
                title: monthTitle(_month.year, _month.month),
                onPrev: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
              ),
              _MonthGrid(
                month: _month,
                selectedDay: _selectedDay,
                counts: counts,
                keyOf: _key,
                onSelect: (d) => setState(() => _selectedDay = d),
              ),
              const SizedBox(height: 8),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Usos em ${formatDay(_selectedDay)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (dayEntries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum uso neste dia.'),
                )
              else
                ...dayEntries.map((e) => _UsageTile(entry: e, ref: ref)),
            ],
          );
        },
      ),
    );
  }
}

class _OutfitFilter extends StatelessWidget {
  final List<Outfit> outfits;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _OutfitFilter({
    required this.outfits,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Filtrar',
          isDense: true,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: value,
            isExpanded: true,
            isDense: true,
            onChanged: onChanged,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Todos os outfits'),
              ),
              ...outfits.map(
                (o) => DropdownMenuItem<String?>(
                  value: o.id,
                  child: Text(o.name, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthHeader({
    required this.title,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Mês anterior',
            onPressed: onPrev,
          ),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próximo mês',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDay;
  final Map<String, int> counts;
  final String Function(DateTime) keyOf;
  final ValueChanged<DateTime> onSelect;

  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.counts,
    required this.keyOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // weekday: 1=Seg..7=Dom → coluna com domingo primeiro.
    final leading = DateTime(month.year, month.month).weekday % 7;
    final cells = <Widget>[];

    for (final wd in kWeekdaysShort) {
      cells.add(Center(
        child: Text(
          wd,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ));
    }
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final count = counts[keyOf(date)] ?? 0;
      final selected = keyOf(date) == keyOf(selectedDay);
      cells.add(_DayCell(
        day: day,
        count: count,
        selected: selected,
        onTap: () => onSelect(date),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cells,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _DayCell({
    required this.day,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Dia $day${count > 0 ? ', $count usos' : ''}',
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? scheme.surfaceContainerHighest : null,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

class _UsageTile extends StatelessWidget {
  final UsageEntry entry;
  final WidgetRef ref;
  const _UsageTile({required this.entry, required this.ref});

  Future<void> _delete(BuildContext context) async {
    final u = entry.usage;
    await ref.read(usageControllerProvider.notifier).delete(u.id);
    if (!context.mounted) return;
    // Registro barato de restaurar: em vez de dialog de confirmação,
    // oferece desfazer (re-registra o mesmo uso).
    showUndoSnackBar(
      context,
      message: 'Uso de "${entry.outfit.name}" removido.',
      onUndo: () => ref.read(usageControllerProvider.notifier).register(
            outfitId: u.outfitId,
            when: DateTime.fromMillisecondsSinceEpoch(u.usedAt),
            hasTime: u.hasTime,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = entry.usage;
    return ListTile(
      leading: const Icon(Icons.checkroom_outlined),
      title: Text(entry.outfit.name),
      subtitle: Text(
        u.hasTime ? formatUsage(u.usedAt, true) : 'Sem horário',
      ),
      trailing: IconButton(
        tooltip: 'Remover uso',
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _delete(context),
      ),
    );
  }
}
