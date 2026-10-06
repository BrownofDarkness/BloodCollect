import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/domain/entities/blood_request.dart';
import 'request_progress_style.dart';

enum _StepState { done, current, upcoming }

/// Frise de suivi : Transmise → Décision.
///
/// « Reçue » et « En cours de traitement » ne s'affichent que si le centre
/// de transfusion les a réellement enregistrées (receivedAt, statut routing).
/// En v1 il n'écrit que sa décision : les déduire afficherait des étapes
/// vertes sans retour réel.
class BloodRequestTimeline extends StatelessWidget {
  const BloodRequestTimeline({super.key, required this.request});

  final BloodRequest request;

  @override
  Widget build(BuildContext context) {
    final progress = request.progress;
    final processing = progress == RequestProgress.processing;
    final decidedAt = request.decidedAt;
    final receivedAt = request.receivedAt;
    final granted = request.quantityGranted;

    final steps = [
      _Step(
        state: _StepState.done,
        title: 'Transmise',
        detail: Formatters.timeOrDate(request.createdAt),
      ),
      if (receivedAt != null)
        _Step(
          state: _StepState.done,
          title: 'Reçue par le centre',
          detail: Formatters.timeOrDate(receivedAt),
        ),
      if (processing)
        _Step(
          state: _StepState.current,
          title: 'En cours de traitement',
          detail: 'Depuis ${Formatters.timeOrDate(request.updatedAt)}',
        ),
      if (decidedAt == null)
        const _Step(
          state: _StepState.upcoming,
          title: 'Décision du centre',
          detail: 'Approuvée, partielle, refusée ou orientée',
        )
      else
        _Step(
          state: _StepState.done,
          title: 'Décision : ${progress.label.toLowerCase()}',
          detail: [
            Formatters.timeOrDate(decidedAt),
            if (progress == RequestProgress.partial && granted != null)
              '$granted sur ${request.quantityNeeded} poches accordées',
          ].join(' · '),
        ),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepRow(
            step: steps[i],
            // Le trait est vert tant que l'étape suivante est entamée.
            lineReached: i + 1 < steps.length &&
                steps[i + 1].state != _StepState.upcoming,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _Step {
  const _Step({required this.state, required this.title, this.detail});

  final _StepState state;
  final String title;
  final String? detail;
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.lineReached,
    required this.isLast,
  });

  final _Step step;
  final bool lineReached;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final titleColor = switch (step.state) {
      _StepState.done => AppColors.encre,
      _StepState.current => AppColors.bleu,
      _StepState.upcoming => AppColors.slate,
    };
    final detail = step.detail;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              _Dot(state: step.state),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: lineReached ? AppColors.disponible : AppColors.ligne,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      style: const TextStyle(
                        color: AppColors.gris,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.state});

  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final decoration = switch (state) {
      _StepState.done => const BoxDecoration(
          color: AppColors.disponible,
          shape: BoxShape.circle,
        ),
      _StepState.current => BoxDecoration(
          color: AppColors.bleuLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.bleu, width: 3),
        ),
      _StepState.upcoming => BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ligne, width: 2),
        ),
    };

    return Container(
      width: 22,
      height: 22,
      decoration: decoration,
      child: state == _StepState.done
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : null,
    );
  }
}
