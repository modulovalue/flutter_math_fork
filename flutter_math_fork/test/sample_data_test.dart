import 'dart:convert';

import 'package:flutter_math_fork/supported_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helper.dart';
import 'load_fonts.dart';

void main() {
  setUpAll(loadKaTeXFonts);
  group("supported data", () {
    for (final x in supportedData.entries) {
      for (final y in x.value) {
        final desc = x.key + " " + y;
        testTexToMatchGoldenFile(
          desc,
          y,
          path: "supported_data/" + x.key + "/" + base64.encode(utf8.encoder.convert(y)),
        );
      }
    }
  });
}
