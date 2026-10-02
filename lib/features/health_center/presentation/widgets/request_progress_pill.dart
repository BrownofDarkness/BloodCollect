import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/blood_request.dart';
import 'request_progress_style.dart';

/// Pastille d'avancement d'une demande. [short] : libellé court (accueil).
class RequestProgressPill extends StatelessWidget {
  const RequestProgressPill({
    super.key,
    required this.progress,
    this.short = false,
  });

  final RequestProgress progress;
  final bool short;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: progress.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(progress.icon, color: progress.color, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              short ? progress.shortLabel : progress.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: progress.color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
