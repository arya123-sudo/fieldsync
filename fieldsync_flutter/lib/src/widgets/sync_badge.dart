import 'package:flutter/material.dart';

class SyncBadge extends StatelessWidget {
  final bool online;
  final int pendingWrites;
  final bool syncing;
  final DateTime? lastSynced;

  const SyncBadge({
    super.key,
    required this.online,
    required this.pendingWrites,
    required this.syncing,
    required this.lastSynced,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;
    late final IconData icon;
    if (!online) {
      color = Colors.red;
      icon = Icons.wifi_off;
      label = pendingWrites > 0
          ? 'Offline · $pendingWrites change${pendingWrites == 1 ? '' : 's'} pending'
          : 'Offline';
    } else if (syncing) {
      color = Colors.amber.shade800;
      icon = Icons.sync;
      label = 'Syncing…';
    } else if (pendingWrites > 0) {
      color = Colors.amber.shade800;
      icon = Icons.cloud_upload_outlined;
      label = '$pendingWrites pending';
    } else {
      color = Colors.green.shade700;
      icon = Icons.check_circle_outline;
      label = 'Synced';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
