String fixedHex(
  final int number,
  final int length,
) {
  final str = number.toRadixString(16).toUpperCase();
  return str.padLeft(length, '0');
}

/* Creates a unicode literal based on the string */
String unicodeLiteral(
  final String str, {
  final bool escape = false,
}) =>
    str.split('').map((final e) {
      if (e.codeUnitAt(0) > 126 || e.codeUnitAt(0) < 32) {
        return '\\u${fixedHex(e.codeUnitAt(0), 4)}';
      } else if (escape && (e == '\'' || e == '\$')) {
        return '\\$e';
      } else {
        return e;
      }
    }).join();
