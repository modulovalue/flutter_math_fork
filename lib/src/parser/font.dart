// The MIT License (MIT)
//
// Copyright (c) 2013-2019 Khan Academy and other contributors
// Copyright (c) 2020 znjameswu <znjameswu@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// Converted from KaTeX/src/katex.less
import '../ast/ast.dart';

import '../ast/ast_impl.dart';

// Map<String, FontOptions> _fontOptionsTable;
// Map<String, FontOptions> get fontOptionsTable {
//   if (_fontOptionsTable != null) return _fontOptionsTable;
//   _fontOptionsTable = {};
//   _fontOptionsEntries.forEach((key, value) {
//     for (final name in key) {
//       _fontOptionsTable[name] = value;
//     }
//   });
//   return _fontOptionsTable;
// }

// const _fontOptionsEntries = {
//   // Text font weights.
//   ['textbf']: FontOptionsImpl(
//     fontWeight: FontWeight.bold,
//   ),

//   // Text font shapes.
//   ['textit']: FontOptionsImpl(
//     fontShape: FontStyle.italic,
//   ),

//   // Text font families.
//   ['textrm']: FontOptionsImpl(fontFamily: 'Main'),

//   ['textsf']: FontOptionsImpl(fontFamily: 'SansSerif'),

//   ['texttt']: FontOptionsImpl(fontFamily: 'Typewriter'),

//   // Math fonts.
//   ['mathdefault']: FontOptionsImpl(
//     fontFamily: 'Math',
//     fontShape: FontStyle.italic,
//   ),

//   ['mathit']: FontOptionsImpl(
//     fontFamily: 'Main',
//     fontShape: FontStyle.italic,
//   ),

//   ['mathrm']: FontOptionsImpl(
//     fontFamily: 'Main',
//     fontShape: FontStyle.normal,
//   ),

//   ['mathbf']: FontOptionsImpl(
//     fontFamily: 'Main',
//     fontWeight: FontWeight.bold,
//   ),

//   ['boldsymbol']: FontOptionsImpl(
//     fontFamily: 'Math',
//     fontWeight: FontWeight.bold,
//     fontShape: FontStyle.italic,
//     fallback: [
//       FontOptionsImpl(
//         fontFamily: 'Math',
//         fontWeight: FontWeight.bold,
//       )
//     ],
//   ),

//   ['amsrm']: FontOptionsImpl(fontFamily: 'AMS'),

//   ['mathbb', 'textbb']: FontOptionsImpl(fontFamily: 'AMS'),

//   ['mathcal']: FontOptionsImpl(fontFamily: 'Caligraphic'),

//   ['mathfrak', 'textfrak']: FontOptionsImpl(fontFamily: 'Fraktur'),

//   ['mathtt']: FontOptionsImpl(fontFamily: 'Typewriter'),

//   ['mathscr', 'textscr']: FontOptionsImpl(fontFamily: 'Script'),

//   ['mathsf', 'textsf']: FontOptionsImpl(fontFamily: 'SansSerif'),

//   ['mathboldsf', 'textboldsf']: FontOptionsImpl(
//     fontFamily: 'SansSerif',
//     fontWeight: FontWeight.bold,
//   ),

//   ['mathitsf', 'textitsf']: FontOptionsImpl(
//     fontFamily: 'SansSerif',
//     fontShape: FontStyle.italic,
//   ),

//   ['mainrm']: FontOptionsImpl(
//     fontFamily: 'Main',
//     fontShape: FontStyle.normal,
//   ),
// };

// const fontFamilyFallback = ['Main', 'Times New Roman', 'serif'];

const texMathFontOptions = {
  // Math fonts.
  // 'mathdefault': FontOptionsImpl(
  //   fontFamily: 'Math',
  //   fontShape: FontStyle.italic,
  // ),

  '\\mathit': TexFontOptionsImpl(
    fontFamily: 'Main',
    fontShape: TexFontStyle.italic,
  ),

  '\\mathrm': TexFontOptionsImpl(
    fontFamily: 'Main',
    fontShape: TexFontStyle.normal,
  ),

  '\\mathbf': TexFontOptionsImpl(
    fontFamily: 'Main',
    fontWeight: TexFontWeight.w700,
  ),

  '\\boldsymbol': TexFontOptionsImpl(
    fontFamily: 'Math',
    fontWeight: TexFontWeight.w700,
    fontShape: TexFontStyle.italic,
    fallback: [
      TexFontOptionsImpl(
        fontFamily: 'Math',
        fontWeight: TexFontWeight.w700,
      )
    ],
  ),

  '\\mathbb': TexFontOptionsImpl(fontFamily: 'AMS'),

  '\\mathcal': TexFontOptionsImpl(fontFamily: 'Caligraphic'),

  '\\mathfrak': TexFontOptionsImpl(fontFamily: 'Fraktur'),

  '\\mathtt': TexFontOptionsImpl(fontFamily: 'Typewriter'),

  '\\mathscr': TexFontOptionsImpl(fontFamily: 'Script'),

  '\\mathsf': TexFontOptionsImpl(fontFamily: 'SansSerif'),
};

const texTextFontOptions = {
  '\\textrm': TexPartialFontOptionsImpl(
    fontFamily: 'Main',
  ),
  '\\textsf': TexPartialFontOptionsImpl(
    fontFamily: 'SansSerif',
  ),
  '\\texttt': TexPartialFontOptionsImpl(
    fontFamily: 'Typewriter',
  ),
  '\\textnormal': TexPartialFontOptionsImpl(
    fontFamily: 'Main',
  ),
  '\\textbf': TexPartialFontOptionsImpl(
    fontWeight: TexFontWeight.w700,
  ),
  '\\textmd': TexPartialFontOptionsImpl(
    fontWeight: TexFontWeight.w400,
  ),
  '\\textit': TexPartialFontOptionsImpl(
    fontShape: TexFontStyle.italic,
  ),
  '\\textup': TexPartialFontOptionsImpl(
    fontShape: TexFontStyle.normal,
  ),
};
