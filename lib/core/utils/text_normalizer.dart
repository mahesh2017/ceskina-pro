/// Text normalization utilities for pronunciation comparison.
class TextNormalizer {
  TextNormalizer._();

  /// Normalize text: lowercase, strip punctuation, collapse spaces.
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sáčďéěíňóřšťúůýž-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Strip Czech diacritics for loose comparison.
  static String stripDiacritics(String text) {
    const diacriticsMap = {
      'á': 'a', 'č': 'c', 'ď': 'd', 'é': 'e', 'ě': 'e',
      'í': 'i', 'ň': 'n', 'ó': 'o', 'ř': 'r', 'š': 's',
      'ť': 't', 'ú': 'u', 'ů': 'u', 'ý': 'y', 'ž': 'z',
    };
    var result = text.toLowerCase();
    diacriticsMap.forEach((cz, plain) {
      result = result.replaceAll(cz, plain);
    });
    return result;
  }
}