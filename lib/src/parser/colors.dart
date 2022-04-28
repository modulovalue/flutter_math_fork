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

import '../ast/ast_impl.dart';

// All supported CSS color names
// The following values are obtained from https://developer.mozilla.org/en-US/docs/Web/CSS/color_value
const colorByName = {
  'black': TexColorImpl(argb: 0xff000000),
  'silver': TexColorImpl(argb: 0xffc0c0c0),
  'gray': TexColorImpl(argb: 0xff808080),
  'white': TexColorImpl(argb: 0xffffffff),
  'maroon': TexColorImpl(argb: 0xff800000),
  'red': TexColorImpl(argb: 0xffff0000),
  'purple': TexColorImpl(argb: 0xff800080),
  'fuchsia': TexColorImpl(argb: 0xffff00ff),
  'green': TexColorImpl(argb: 0xff008000),
  'lime': TexColorImpl(argb: 0xff00ff00),
  'olive': TexColorImpl(argb: 0xff808000),
  'yellow': TexColorImpl(argb: 0xffffff00),
  'navy': TexColorImpl(argb: 0xff000080),
  'blue': TexColorImpl(argb: 0xff0000ff),
  'teal': TexColorImpl(argb: 0xff008080),
  'aqua': TexColorImpl(argb: 0xff00ffff),
  'orange': TexColorImpl(argb: 0xffffa500),
  'aliceblue': TexColorImpl(argb: 0xfff0f8ff),
  'antiquewhite': TexColorImpl(argb: 0xfffaebd7),
  'aquamarine': TexColorImpl(argb: 0xff7fffd4),
  'azure': TexColorImpl(argb: 0xfff0ffff),
  'beige': TexColorImpl(argb: 0xfff5f5dc),
  'bisque': TexColorImpl(argb: 0xffffe4c4),
  'blanchedalmond': TexColorImpl(argb: 0xffffebcd),
  'blueviolet': TexColorImpl(argb: 0xff8a2be2),
  'brown': TexColorImpl(argb: 0xffa52a2a),
  'burlywood': TexColorImpl(argb: 0xffdeb887),
  'cadetblue': TexColorImpl(argb: 0xff5f9ea0),
  'chartreuse': TexColorImpl(argb: 0xff7fff00),
  'chocolate': TexColorImpl(argb: 0xffd2691e),
  'coral': TexColorImpl(argb: 0xffff7f50),
  'cornflowerblue': TexColorImpl(argb: 0xff6495ed),
  'cornsilk': TexColorImpl(argb: 0xfffff8dc),
  'crimson': TexColorImpl(argb: 0xffdc143c),
  'cyan': TexColorImpl(argb: 0xff00ffff),
  'darkblue': TexColorImpl(argb: 0xff00008b),
  'darkcyan': TexColorImpl(argb: 0xff008b8b),
  'darkgoldenrod': TexColorImpl(argb: 0xffb8860b),
  'darkgray': TexColorImpl(argb: 0xffa9a9a9),
  'darkgreen': TexColorImpl(argb: 0xff006400),
  'darkgrey': TexColorImpl(argb: 0xffa9a9a9),
  'darkkhaki': TexColorImpl(argb: 0xffbdb76b),
  'darkmagenta': TexColorImpl(argb: 0xff8b008b),
  'darkolivegreen': TexColorImpl(argb: 0xff556b2f),
  'darkorange': TexColorImpl(argb: 0xffff8c00),
  'darkorchid': TexColorImpl(argb: 0xff9932cc),
  'darkred': TexColorImpl(argb: 0xff8b0000),
  'darksalmon': TexColorImpl(argb: 0xffe9967a),
  'darkseagreen': TexColorImpl(argb: 0xff8fbc8f),
  'darkslateblue': TexColorImpl(argb: 0xff483d8b),
  'darkslategray': TexColorImpl(argb: 0xff2f4f4f),
  'darkslategrey': TexColorImpl(argb: 0xff2f4f4f),
  'darkturquoise': TexColorImpl(argb: 0xff00ced1),
  'darkviolet': TexColorImpl(argb: 0xff9400d3),
  'deeppink': TexColorImpl(argb: 0xffff1493),
  'deepskyblue': TexColorImpl(argb: 0xff00bfff),
  'dimgray': TexColorImpl(argb: 0xff696969),
  'dimgrey': TexColorImpl(argb: 0xff696969),
  'dodgerblue': TexColorImpl(argb: 0xff1e90ff),
  'firebrick': TexColorImpl(argb: 0xffb22222),
  'floralwhite': TexColorImpl(argb: 0xfffffaf0),
  'forestgreen': TexColorImpl(argb: 0xff228b22),
  'gainsboro': TexColorImpl(argb: 0xffdcdcdc),
  'ghostwhite': TexColorImpl(argb: 0xfff8f8ff),
  'gold': TexColorImpl(argb: 0xffffd700),
  'goldenrod': TexColorImpl(argb: 0xffdaa520),
  'greenyellow': TexColorImpl(argb: 0xffadff2f),
  'grey': TexColorImpl(argb: 0xff808080),
  'honeydew': TexColorImpl(argb: 0xfff0fff0),
  'hotpink': TexColorImpl(argb: 0xffff69b4),
  'indianred': TexColorImpl(argb: 0xffcd5c5c),
  'indigo': TexColorImpl(argb: 0xff4b0082),
  'ivory': TexColorImpl(argb: 0xfffffff0),
  'khaki': TexColorImpl(argb: 0xfff0e68c),
  'lavender': TexColorImpl(argb: 0xffe6e6fa),
  'lavenderblush': TexColorImpl(argb: 0xfffff0f5),
  'lawngreen': TexColorImpl(argb: 0xff7cfc00),
  'lemonchiffon': TexColorImpl(argb: 0xfffffacd),
  'lightblue': TexColorImpl(argb: 0xffadd8e6),
  'lightcoral': TexColorImpl(argb: 0xfff08080),
  'lightcyan': TexColorImpl(argb: 0xffe0ffff),
  'lightgoldenrodyellow': TexColorImpl(argb: 0xfffafad2),
  'lightgray': TexColorImpl(argb: 0xffd3d3d3),
  'lightgreen': TexColorImpl(argb: 0xff90ee90),
  'lightgrey': TexColorImpl(argb: 0xffd3d3d3),
  'lightpink': TexColorImpl(argb: 0xffffb6c1),
  'lightsalmon': TexColorImpl(argb: 0xffffa07a),
  'lightseagreen': TexColorImpl(argb: 0xff20b2aa),
  'lightskyblue': TexColorImpl(argb: 0xff87cefa),
  'lightslategray': TexColorImpl(argb: 0xff778899),
  'lightslategrey': TexColorImpl(argb: 0xff778899),
  'lightsteelblue': TexColorImpl(argb: 0xffb0c4de),
  'lightyellow': TexColorImpl(argb: 0xffffffe0),
  'limegreen': TexColorImpl(argb: 0xff32cd32),
  'linen': TexColorImpl(argb: 0xfffaf0e6),
  'magenta (synonym of fuchsia)': TexColorImpl(argb: 0xffff00ff),
  'mediumaquamarine': TexColorImpl(argb: 0xff66cdaa),
  'mediumblue': TexColorImpl(argb: 0xff0000cd),
  'mediumorchid': TexColorImpl(argb: 0xffba55d3),
  'mediumpurple': TexColorImpl(argb: 0xff9370db),
  'mediumseagreen': TexColorImpl(argb: 0xff3cb371),
  'mediumslateblue': TexColorImpl(argb: 0xff7b68ee),
  'mediumspringgreen': TexColorImpl(argb: 0xff00fa9a),
  'mediumturquoise': TexColorImpl(argb: 0xff48d1cc),
  'mediumvioletred': TexColorImpl(argb: 0xffc71585),
  'midnightblue': TexColorImpl(argb: 0xff191970),
  'mintcream': TexColorImpl(argb: 0xfff5fffa),
  'mistyrose': TexColorImpl(argb: 0xffffe4e1),
  'moccasin': TexColorImpl(argb: 0xffffe4b5),
  'navajowhite': TexColorImpl(argb: 0xffffdead),
  'oldlace': TexColorImpl(argb: 0xfffdf5e6),
  'olivedrab': TexColorImpl(argb: 0xff6b8e23),
  'orangered': TexColorImpl(argb: 0xffff4500),
  'orchid': TexColorImpl(argb: 0xffda70d6),
  'palegoldenrod': TexColorImpl(argb: 0xffeee8aa),
  'palegreen': TexColorImpl(argb: 0xff98fb98),
  'paleturquoise': TexColorImpl(argb: 0xffafeeee),
  'palevioletred': TexColorImpl(argb: 0xffdb7093),
  'papayawhip': TexColorImpl(argb: 0xffffefd5),
  'peachpuff': TexColorImpl(argb: 0xffffdab9),
  'peru': TexColorImpl(argb: 0xffcd853f),
  'pink': TexColorImpl(argb: 0xffffc0cb),
  'plum': TexColorImpl(argb: 0xffdda0dd),
  'powderblue': TexColorImpl(argb: 0xffb0e0e6),
  'rosybrown': TexColorImpl(argb: 0xffbc8f8f),
  'royalblue': TexColorImpl(argb: 0xff4169e1),
  'saddlebrown': TexColorImpl(argb: 0xff8b4513),
  'salmon': TexColorImpl(argb: 0xfffa8072),
  'sandybrown': TexColorImpl(argb: 0xfff4a460),
  'seagreen': TexColorImpl(argb: 0xff2e8b57),
  'seashell': TexColorImpl(argb: 0xfffff5ee),
  'sienna': TexColorImpl(argb: 0xffa0522d),
  'skyblue': TexColorImpl(argb: 0xff87ceeb),
  'slateblue': TexColorImpl(argb: 0xff6a5acd),
  'slategray': TexColorImpl(argb: 0xff708090),
  'slategrey': TexColorImpl(argb: 0xff708090),
  'snow': TexColorImpl(argb: 0xfffffafa),
  'springgreen': TexColorImpl(argb: 0xff00ff7f),
  'steelblue': TexColorImpl(argb: 0xff4682b4),
  'tan': TexColorImpl(argb: 0xffd2b48c),
  'thistle': TexColorImpl(argb: 0xffd8bfd8),
  'tomato': TexColorImpl(argb: 0xffff6347),
  'turquoise': TexColorImpl(argb: 0xff40e0d0),
  'violet': TexColorImpl(argb: 0xffee82ee),
  'wheat': TexColorImpl(argb: 0xfff5deb3),
  'whitesmoke': TexColorImpl(argb: 0xfff5f5f5),
  'yellowgreen': TexColorImpl(argb: 0xff9acd32),
  'rebeccapurple': TexColorImpl(argb: 0xff663399),
  'transparent': TexColorImpl(argb: 0x00000000),
};
