// Formatação de datas em pt-BR sem dependência externa (`intl`).

const List<String> kMonthsShort = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

const List<String> kWeekdaysShort = [
  'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb',
];

String _pad2(int n) => n.toString().padLeft(2, '0');

/// `dd/MM/yyyy`.
String formatDay(DateTime d) => '${_pad2(d.day)}/${_pad2(d.month)}/${d.year}';

/// Uso: `dd/MM/yyyy` ou `dd/MM/yyyy HH:mm` quando há horário.
String formatUsage(int ms, bool hasTime) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final day = formatDay(d);
  return hasTime ? '$day ${_pad2(d.hour)}:${_pad2(d.minute)}' : day;
}

/// Converte `yyyy-MM` (retorno do strftime) em `mmm/yyyy`.
String formatYearMonth(String yyyyMm) {
  final parts = yyyyMm.split('-');
  if (parts.length != 2) return yyyyMm;
  final m = int.tryParse(parts[1]);
  if (m == null || m < 1 || m > 12) return yyyyMm;
  return '${kMonthsShort[m - 1]}/${parts[0]}';
}

/// Nome do mês (capitalizado) para o cabeçalho do calendário.
String monthTitle(int year, int month) {
  final name = kMonthsShort[month - 1];
  return '${name[0].toUpperCase()}${name.substring(1)} $year';
}
