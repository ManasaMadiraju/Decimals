import 'package:flutter/material.dart';

class CashierBottomControls extends StatelessWidget {
  const CashierBottomControls({
    super.key,
    required this.replayLabel,
    required this.hintLabel,
    required this.openRegisterLabel,
    required this.checkChangeLabel,
    required this.nextCustomerLabel,
    required this.restartLabel,
    required this.onReplay,
    required this.onHint,
    required this.onOpenRegister,
    required this.onCheckChange,
    required this.onNextCustomer,
    required this.onRestart,
    required this.canOpenRegister,
    required this.canCheckChange,
    required this.canNextCustomer,
  });

  final String replayLabel;
  final String hintLabel;
  final String openRegisterLabel;
  final String checkChangeLabel;
  final String nextCustomerLabel;
  final String restartLabel;
  final VoidCallback onReplay;
  final VoidCallback onHint;
  final VoidCallback onOpenRegister;
  final VoidCallback onCheckChange;
  final VoidCallback onNextCustomer;
  final VoidCallback onRestart;
  final bool canOpenRegister;
  final bool canCheckChange;
  final bool canNextCustomer;

  Widget _primaryAction({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReplay,
              icon: const Icon(Icons.record_voice_over),
              label: Text(replayLabel),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onHint,
              icon: const Icon(Icons.lightbulb),
              label: Text(hintLabel),
            ),
          ),
          const SizedBox(width: 8),
          _primaryAction(
            onPressed: canOpenRegister ? onOpenRegister : null,
            icon: Icons.lock_open,
            label: openRegisterLabel,
            color: Colors.indigo,
          ),
          const SizedBox(width: 8),
          _primaryAction(
            onPressed: canCheckChange ? onCheckChange : null,
            icon: Icons.check_circle,
            label: checkChangeLabel,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _primaryAction(
            onPressed: canNextCustomer ? onNextCustomer : null,
            icon: Icons.navigate_next,
            label: nextCustomerLabel,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _primaryAction(
            onPressed: onRestart,
            icon: Icons.restart_alt,
            label: restartLabel,
            color: Colors.deepOrange,
          ),
        ],
      ),
    );
  }
}
