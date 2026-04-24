import 'package:flutter/foundation.dart';

@immutable
class AttributionEntry {
  const AttributionEntry({
    required this.assetName,
    required this.author,
    required this.licenseName,
    this.sourceUrl,
  });

  final String assetName;
  final String author;
  final String licenseName;
  final String? sourceUrl;
}

const List<AttributionEntry> bundledAttributions = [];
