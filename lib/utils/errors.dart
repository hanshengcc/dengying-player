import 'dart:async';

import 'package:flutter/widgets.dart';

import '../api/emby_api.dart';
import '../l10n/app_localizations.dart';

/// 把异常转成人话给用户看。`EmbyApiException` 带的是错误码，在这儿按
/// 当前界面语言翻译；网络传输层的异常（超时、DNS 解析失败、连接被拒）
/// toString() 是一坨 Dart/IO 内部堆栈文本，不能直接甩给用户。
String friendlyError(BuildContext context, Object e) {
  final l = L.of(context);

  if (e is EmbyApiException) {
    final msg = switch (e.kind) {
      ApiErrorKind.requestFailed => l.requestFailed(e.detail ?? ''),
      ApiErrorKind.wrongCredentials => l.wrongCredentials,
      ApiErrorKind.loginFailed => l.loginFailed,
      ApiErrorKind.loginMissingCredentials => l.loginMissingCredentials,
      ApiErrorKind.fetchLatestFailed => l.fetchLatestFailed,
      ApiErrorKind.fetchPlaybackInfoFailed => l.fetchPlaybackInfoFailed,
      ApiErrorKind.unfavoriteFailed => l.unfavoriteFailed,
      ApiErrorKind.markUnwatchedFailed => l.markUnwatchedFailed,
    };
    return e.statusCode == null ? msg : '$msg (HTTP ${e.statusCode})';
  }

  final s = e.toString();
  if (e is TimeoutException || s.contains('TimeoutException')) {
    return l.timeoutError;
  }
  if (s.contains('SocketException') ||
      s.contains('Connection refused') ||
      s.contains('Failed host lookup') ||
      s.contains('Network is unreachable')) {
    return l.connectionError;
  }
  if (s.contains('HandshakeException') || s.contains('CERTIFICATE')) {
    return l.certificateError;
  }
  return l.genericError;
}
