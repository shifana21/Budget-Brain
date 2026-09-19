import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'glass_card.dart';

/// Circular financial health score indicator with animated ring and breakdown.
class HealthScoreWidget extends StatefulWidget {
  const HealthScoreWidget({
    super.key,
    required this.score,
    this.compact = false,
    this.showBreakdown = false,
  });

  final double score;
  final bool compact;
  final bool showBreakdown;

  @override
  State<HealthScoreWidget> createState() => _HealthScoreWidgetState();
}

class _HealthScoreWidgetState extends State<HealthScoreWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    final score = widget.score;
    if (score >= 90) return AppColors.accent;
    if (score >= 75) return AppColors.primary;
    if (score >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  String get _scoreLabel {
    final score = widget.score;
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 50) return 'Moderate';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
    final normalized = (widget.score / 100).clamp(0.0, 1.0);

    return GlassCard(
      padding: EdgeInsets.all(widget.compact ? 16 : 20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _scoreColor.withValues(alpha: 0.15),
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: widget.compact ? 64 : 80,
                height: widget.compact ? 64 : 80,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(widget.compact ? 64 : 80, widget.compact ? 64 : 80),
                      painter: _ScoreRingPainter(
                        progress: normalized * _animation.value,
                        color: _scoreColor,
                        strokeWidth: widget.compact ? 6 : 8,
                      ),
                      child: Center(
                        child: Text(
                          (widget.score * _animation.value).toStringAsFixed(0),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: _scoreColor,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: widget.compact ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Health',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _scoreLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _scoreColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (!widget.compact) ...[
                      const SizedBox(height: 4),
                      Text(
                        'AI-powered score based on spending, budgets & goals',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (widget.showBreakdown && !widget.compact) ...[
            const SizedBox(height: 16),
            _ScoreBreakdown(score: widget.score),
          ],
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}

class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Score Breakdown',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _BreakdownItem(
          label: 'Savings Ratio',
          value: '30%',
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        _BreakdownItem(
          label: 'Budget Adherence',
          value: '25%',
          color: AppColors.secondary,
        ),
        const SizedBox(height: 8),
        _BreakdownItem(
          label: 'Spending Stability',
          value: '15%',
          color: AppColors.accent,
        ),
        const SizedBox(height: 8),
        _BreakdownItem(
          label: 'Anomaly Frequency',
          value: '15%',
          color: AppColors.warning,
        ),
        const SizedBox(height: 8),
        _BreakdownItem(
          label: 'Goal Progress',
          value: '15%',
          color: AppColors.danger,
        ),
      ],
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  const _BreakdownItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
