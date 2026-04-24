import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../app/v2_theme.dart';
import '../../../core/network/json_helpers.dart';

class ActivityHtmlContent extends StatelessWidget {
  const ActivityHtmlContent({
    required this.html,
    required this.onOpenLink,
    this.fontSize = 16,
    this.lineHeight = 1.5,
    this.paragraphBottomMargin = 14,
    super.key,
  });

  final String html;
  final Future<void> Function(String url) onOpenLink;
  final double fontSize;
  final double lineHeight;
  final double paragraphBottomMargin;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: html,
      onLinkTap: (url, _, __) {
        if (url == null || url.isEmpty) {
          return;
        }
        onOpenLink(url);
      },
      style: <String, Style>{
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: FontSize(fontSize),
          lineHeight: LineHeight(lineHeight),
        ),
        'a': Style(color: V2Palette.primaryBlue),
        'p': Style(margin: Margins.only(bottom: paragraphBottomMargin)),
        'div': Style(margin: Margins.zero),
        'br': Style(margin: Margins.zero),
        'li': Style(margin: Margins.only(bottom: 8)),
        'ul': Style(margin: Margins.only(bottom: paragraphBottomMargin)),
        'ol': Style(margin: Margins.only(bottom: paragraphBottomMargin)),
        'h1': Style(margin: Margins.only(bottom: 12)),
        'h2': Style(margin: Margins.only(bottom: 12)),
        'h3': Style(margin: Margins.only(bottom: 10)),
      },
    );
  }
}

String activityContentHtml({
  required String rendered,
  String plainText = '',
}) {
  final renderedValue = rendered.trim();
  if (renderedValue.isNotEmpty) {
    return _formatActivityHtml(renderedValue);
  }

  final fallbackValue = plainText.trim();
  if (fallbackValue.isEmpty) {
    return '';
  }

  return _formatActivityHtml(fallbackValue);
}

String _formatActivityHtml(String source) {
  if (_hasHtmlTags(source)) {
    return _linkifyHtml(source);
  }

  return '<p>${_linkifyPlainText(source)}</p>';
}

bool _hasHtmlTags(String value) {
  return RegExp(r'</?[a-z][\s\S]*>', caseSensitive: false).hasMatch(value);
}

String _linkifyHtml(String html) {
  if (html.isEmpty) {
    return '';
  }

  if (RegExp(r'<a\b', caseSensitive: false).hasMatch(html)) {
    return html;
  }

  return html.splitMapJoin(
    RegExp(r'<[^>]+>'),
    onMatch: (match) => match.group(0) ?? '',
    onNonMatch: _linkifyPlainText,
  );
}

String _linkifyPlainText(String text) {
  if (text.isEmpty) {
    return text;
  }

  final normalisedText = decodeHtmlText(text);
  final linkified = normalisedText.splitMapJoin(
    _urlPattern,
    onMatch: (match) {
      final rawValue = match.group(0) ?? '';
      final link = _normalisedLink(rawValue);
      if (link == null) {
        return _escapeHtml(rawValue);
      }

      final target = _escapeHtml(link.target);
      final label = _escapeHtml(link.label);
      final trailing = _escapeHtml(link.trailing);
      return '<a href="$target">$label</a>$trailing';
    },
    onNonMatch: _escapeHtml,
  );

  return linkified.replaceAll(RegExp(r'\r\n?|\n'), '<br>');
}

String _escapeHtml(String value) {
  return htmlEscape.convert(value).replaceAll('&#47;', '/');
}

_NormalisedActivityLink? _normalisedLink(String rawValue) {
  var candidate = rawValue.trim();
  if (candidate.isEmpty) {
    return null;
  }

  var trailing = '';
  final trailingMatch = RegExp(r'[)\].,!?;:]+$').firstMatch(candidate);
  if (trailingMatch != null) {
    trailing = candidate.substring(trailingMatch.start);
    candidate = candidate.substring(0, trailingMatch.start);
  }

  if (candidate.startsWith('www.')) {
    candidate = 'https://$candidate';
  }

  final uri = Uri.tryParse(candidate);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return null;
  }

  return _NormalisedActivityLink(
    target: uri.toString(),
    label: uri.toString(),
    trailing: trailing,
  );
}

class _NormalisedActivityLink {
  const _NormalisedActivityLink({
    required this.target,
    required this.label,
    required this.trailing,
  });

  final String target;
  final String label;
  final String trailing;
}

final RegExp _urlPattern = RegExp(
  r'((?:https?:\/\/|www\.)[^\s<]+)',
  caseSensitive: false,
);
