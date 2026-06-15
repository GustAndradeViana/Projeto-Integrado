class Formatters {
  static String money(num value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String shortDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Sem prazo';
    }

    final normalized = raw.contains(' ') ? raw.replaceFirst(' ', 'T') : raw;
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) {
      return raw;
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day/$month/${parsed.year}';
  }

  static String clock(DateTime? date) {
    if (date == null) {
      return 'Ainda nao sincronizado';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return 'Atualizado as $hour:$minute';
  }
}
