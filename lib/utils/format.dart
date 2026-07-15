/// 格式化工具。
library;

import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// 片长的人类可读形式，如「1小时42分钟」/ "1h 42m"。
String formatRuntime(BuildContext context, Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final l = L.of(context);
  if (h > 0 && m > 0) {
    return l.durationHoursMinutes('$h', '$m');
  }
  if (h > 0) return l.durationHoursOnly('$h');
  return l.durationMinutesOnly('$m');
}
