import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime expiryTime;
  final bool compact;

  const CountdownTimerWidget({
    super.key,
    required this.expiryTime,
    this.compact = false,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.expiryTime.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft = widget.expiryTime.difference(DateTime.now());
        if (_timeLeft.isNegative) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpiringSoon = _timeLeft.inMinutes < 15;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 8 : 12,
        vertical: widget.compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: isExpiringSoon 
            ? Colors.red.withValues(alpha: 0.2) 
            : AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpiringSoon 
              ? Colors.red.withValues(alpha: 0.5) 
              : AppColors.primary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: widget.compact ? 14 : 18,
            color: isExpiringSoon ? Colors.red : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            _formatDuration(_timeLeft),
            style: TextStyle(
              color: isExpiringSoon ? Colors.red : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: widget.compact ? 12 : 14,
              fontFamily: 'Courier', // Monospace for timer
            ),
          ),
        ],
      ),
    ).animate(target: isExpiringSoon ? 1 : 0)
     .shimmer(duration: 2.seconds, color: Colors.white24);
  }
}
