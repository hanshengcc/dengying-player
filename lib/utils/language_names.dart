import 'package:flutter/widgets.dart';

/// 常见 ISO 639-1/639-2 语言代码 → 中英文名。
/// Emby/Jellyfin 返回的音轨/字幕语言字段是这类三字码（如 "chi"、"tha"），
/// 原样显示对用户不友好，这里做一层映射；映射不到的码原样返回。
const Map<String, (String zh, String en)> _kLanguageNames = {
  'chi': ('中文', 'Chinese'),
  'zho': ('中文', 'Chinese'),
  'zh': ('中文', 'Chinese'),
  'eng': ('英语', 'English'),
  'en': ('英语', 'English'),
  'jpn': ('日语', 'Japanese'),
  'ja': ('日语', 'Japanese'),
  'kor': ('韩语', 'Korean'),
  'ko': ('韩语', 'Korean'),
  'fre': ('法语', 'French'),
  'fra': ('法语', 'French'),
  'fr': ('法语', 'French'),
  'ger': ('德语', 'German'),
  'deu': ('德语', 'German'),
  'de': ('德语', 'German'),
  'spa': ('西班牙语', 'Spanish'),
  'es': ('西班牙语', 'Spanish'),
  'por': ('葡萄牙语', 'Portuguese'),
  'pt': ('葡萄牙语', 'Portuguese'),
  'rus': ('俄语', 'Russian'),
  'ru': ('俄语', 'Russian'),
  'ita': ('意大利语', 'Italian'),
  'it': ('意大利语', 'Italian'),
  'tha': ('泰语', 'Thai'),
  'th': ('泰语', 'Thai'),
  'ara': ('阿拉伯语', 'Arabic'),
  'ar': ('阿拉伯语', 'Arabic'),
  'vie': ('越南语', 'Vietnamese'),
  'vi': ('越南语', 'Vietnamese'),
  'ind': ('印尼语', 'Indonesian'),
  'id': ('印尼语', 'Indonesian'),
  'may': ('马来语', 'Malay'),
  'msa': ('马来语', 'Malay'),
  'ms': ('马来语', 'Malay'),
  'dut': ('荷兰语', 'Dutch'),
  'nld': ('荷兰语', 'Dutch'),
  'nl': ('荷兰语', 'Dutch'),
  'hin': ('印地语', 'Hindi'),
  'hi': ('印地语', 'Hindi'),
  'und': ('未知', 'Unknown'),
};

/// Emby 常把字幕子类型（Forced 强制、SDH 听障辅助）塞进 title 字段，
/// 原文是英文缩写，这里换成对应语言下的中文/英文说法。
const Map<String, (String zh, String en)> _kSubtitleFlags = {
  'forced': ('强制', 'Forced'),
  'sdh': ('听障辅助', 'SDH'),
  'cc': ('隐藏字幕', 'CC'),
};

String languageDisplayName(BuildContext context, String code) {
  final zh = Localizations.localeOf(context).languageCode == 'zh';
  final hit = _kLanguageNames[code.toLowerCase()];
  if (hit == null) return code;
  return zh ? hit.$1 : hit.$2;
}

/// 把 Emby 字幕 title 里的 Forced/SDH 等英文标记转成本地化说法；
/// 不认识的词原样返回（比如剧名前缀、发布组标记）。
String friendlySubtitleFlag(BuildContext context, String raw) {
  final zh = Localizations.localeOf(context).languageCode == 'zh';
  final hit = _kSubtitleFlags[raw.trim().toLowerCase()];
  if (hit == null) return raw;
  return zh ? hit.$1 : hit.$2;
}
