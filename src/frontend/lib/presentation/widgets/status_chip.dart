import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, required this.label, super.key});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

Color _colorForStatus(String status) {
  switch (status) {
    case 'aberta':
      return const Color(0xFF2A9D8F);
    case 'em_andamento':
      return const Color(0xFFF4A261);
    case 'concluida':
      return const Color(0xFF3A7D44);
    case 'cancelada':
      return const Color(0xFFE76F51);
    case 'aceita':
      return const Color(0xFF3A7D44);
    case 'recusada':
      return const Color(0xFF8D99AE);
    default:
      return const Color(0xFF14213D);
  }
}
