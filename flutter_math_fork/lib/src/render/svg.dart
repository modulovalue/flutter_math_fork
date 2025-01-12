import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ast/ast.dart';
import '../ast/ast_impl.dart';
import '../ast/symbols.dart';
import '../utils/unicode_literal.dart';
import 'layout.dart';

String svgStringFromPath(
  final String path,
  final Size viewPort,
  final Rect viewBox,
  final Color color, {
  final String preserveAspectRatio = 'xMidYMid meet',
}) =>
    '<svg xmlns="http://www.w3.org/2000/svg" '
    'width="${viewPort.width}" height="${viewPort.height}" '
    'preserveAspectRatio="$preserveAspectRatio" '
    'viewBox='
    '"${viewBox.left} ${viewBox.top} ${viewBox.width} ${viewBox.height}" '
    '>'
    '<path fill="rgb(${color.red},${color.green},${color.blue})" d="$path"></path>'
    '</svg>';

final _alignmentToString = {
  Alignment.topLeft: 'xMinYMin',
  Alignment.topCenter: 'xMidYMin',
  Alignment.topRight: 'xMaxYMin',
  Alignment.centerLeft: 'xMinYMid',
  Alignment.center: 'xMidYMid',
  Alignment.centerRight: 'xMaxYMid',
  Alignment.bottomLeft: 'xMinYMax',
  Alignment.bottomCenter: 'xMidYMax',
  Alignment.bottomRight: 'xMaxYMax',
};

Widget svgWidgetFromPath(
  final String path,
  final Size viewPort,
  final Rect viewBox,
  final Color color, {
  final Alignment align = Alignment.topLeft,
  final BoxFit fit = BoxFit.fill,
}) {
  final alignment = _alignmentToString[align];
  assert(
      fit != BoxFit.none && fit != BoxFit.fitHeight && fit != BoxFit.fitWidth && fit != BoxFit.scaleDown, "");
  final meetOrSlice = () {
    if (fit == BoxFit.contain) {
      return 'meet';
    } else {
      return 'slice';
    }
  }();
  final preserveAspectRatio = () {
    if (fit == BoxFit.fill) {
      return 'none';
    } else {
      return alignment! + ' ' + meetOrSlice;
    }
  }();
  final svgString = svgStringFromPath(
    path,
    viewPort,
    viewBox,
    color,
    preserveAspectRatio: preserveAspectRatio,
  );
  return SizedBox(
    height: viewPort.height,
    width: viewPort.width,
    child: SvgPicture.string(
      svgString,
      width: viewPort.width,
      height: viewPort.height,
      fit: fit,
      alignment: align,
    ),
  );
}
// In all paths below, the viewBox-to-em scale is 1000:1.

const hLinePad = 80.0; // padding above a sqrt viniculum. Prevents image cropping.

// The viniculum of a \sqrt can be made thicker by a KaTeX rendering option.
// Think of variable extraViniculum as two detours in the SVG path.
// The detour begins at the lower left of the area labeled extraViniculum below.
// The detour proceeds one extraViniculum distance up and slightly to the right,
// displacing the radiused corner between surd and viniculum. The radius is
// traversed as usual, then the detour resumes. It goes right, to the end of
// the very long viniculumn, then down one extraViniculum distance,
// after which it resumes regular path geometry for the radical.
/*                                                  viniculum
                                                   /
         /▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒←extraViniculum
        / █████████████████████←0.04em (40 unit) std viniculum thickness
       / /
      / /
     / /\
    / / surd
*/

String sqrtMain(final double extraViniculum, final double hLinePad) =>
    '''M95,${622 + extraViniculum + hLinePad}
c-2.7,0,-7.17,-2.7,-13.5,-8c-5.8,-5.3,-9.5,-10,-9.5,-14
c0,-2,0.3,-3.3,1,-4c1.3,-2.7,23.83,-20.7,67.5,-54
c44.2,-33.3,65.8,-50.3,66.5,-51c1.3,-1.3,3,-2,5,-2c4.7,0,8.7,3.3,12,10
s173,378,173,378c0.7,0,35.3,-71,104,-213c68.7,-142,137.5,-285,206.5,-429
c69,-144,104.5,-217.7,106.5,-221
l${extraViniculum / 2.075} -$extraViniculum
c5.3,-9.3,12,-14,20,-14
H400000v${40 + extraViniculum}H845.2724
s-225.272,467,-225.272,467s-235,486,-235,486c-2.7,4.7,-9,7,-19,7
c-6,0,-10,-1,-12,-3s-194,-422,-194,-422s-65,47,-65,47z
M${834 + extraViniculum} ${hLinePad}h400000v${40 + extraViniculum}h-400000z''';

String sqrtSize1(final double extraViniculum, final double hLinePad) =>
    '''M263,${601 + extraViniculum + hLinePad}c0.7,0,18,39.7,52,119
c34,79.3,68.167,158.7,102.5,238c34.3,79.3,51.8,119.3,52.5,120
c340,-704.7,510.7,-1060.3,512,-1067
l${extraViniculum / 2.084} -$extraViniculum
c4.7,-7.3,11,-11,19,-11
H40000v${40 + extraViniculum}H1012.3
s-271.3,567,-271.3,567c-38.7,80.7,-84,175,-136,283c-52,108,-89.167,185.3,-111.5,232
c-22.3,46.7,-33.8,70.3,-34.5,71c-4.7,4.7,-12.3,7,-23,7s-12,-1,-12,-1
s-109,-253,-109,-253c-72.7,-168,-109.3,-252,-110,-252c-10.7,8,-22,16.7,-34,26
c-22,17.3,-33.3,26,-34,26s-26,-26,-26,-26s76,-59,76,-59s76,-60,76,-60z
M${1001 + extraViniculum} ${hLinePad}h400000v${40 + extraViniculum}h-400000z''';

String sqrtSize2(final double extraViniculum, final double hLinePad) =>
    '''M983 ${10 + extraViniculum + hLinePad}
l${extraViniculum / 3.13} -$extraViniculum
c4,-6.7,10,-10,18,-10 H400000v${40 + extraViniculum}
H1013.1s-83.4,268,-264.1,840c-180.7,572,-277,876.3,-289,913c-4.7,4.7,-12.7,7,-24,7
s-12,0,-12,0c-1.3,-3.3,-3.7,-11.7,-7,-25c-35.3,-125.3,-106.7,-373.3,-214,-744
c-10,12,-21,25,-33,39s-32,39,-32,39c-6,-5.3,-15,-14,-27,-26s25,-30,25,-30
c26.7,-32.7,52,-63,76,-91s52,-60,52,-60s208,722,208,722
c56,-175.3,126.3,-397.3,211,-666c84.7,-268.7,153.8,-488.2,207.5,-658.5
c53.7,-170.3,84.5,-266.8,92.5,-289.5z
M${1001 + extraViniculum} ${hLinePad}h400000v${40 + extraViniculum}h-400000z''';

String sqrtSize3(final double extraViniculum, final double hLinePad) =>
    '''M424,${2398 + extraViniculum + hLinePad}
c-1.3,-0.7,-38.5,-172,-111.5,-514c-73,-342,-109.8,-513.3,-110.5,-514
c0,-2,-10.7,14.3,-32,49c-4.7,7.3,-9.8,15.7,-15.5,25c-5.7,9.3,-9.8,16,-12.5,20
s-5,7,-5,7c-4,-3.3,-8.3,-7.7,-13,-13s-13,-13,-13,-13s76,-122,76,-122s77,-121,77,-121
s209,968,209,968c0,-2,84.7,-361.7,254,-1079c169.3,-717.3,254.7,-1077.7,256,-1081
l${extraViniculum / 4.223} -${extraViniculum}c4,-6.7,10,-10,18,-10 H400000
v${40 + extraViniculum}H1014.6
s-87.3,378.7,-272.6,1166c-185.3,787.3,-279.3,1182.3,-282,1185
c-2,6,-10,9,-24,9
c-8,0,-12,-0.7,-12,-2z M${1001 + extraViniculum} $hLinePad
h400000v${40 + extraViniculum}h-400000z''';

String sqrtSize4(final double extraViniculum, final double hLinePad) =>
    '''M473,${2713 + extraViniculum + hLinePad}
c339.3,-1799.3,509.3,-2700,510,-2702 l${extraViniculum / 5.298} -$extraViniculum
c3.3,-7.3,9.3,-11,18,-11 H400000v${40 + extraViniculum}H1017.7
s-90.5,478,-276.2,1466c-185.7,988,-279.5,1483,-281.5,1485c-2,6,-10,9,-24,9
c-8,0,-12,-0.7,-12,-2c0,-1.3,-5.3,-32,-16,-92c-50.7,-293.3,-119.7,-693.3,-207,-1200
c0,-1.3,-5.3,8.7,-16,30c-10.7,21.3,-21.3,42.7,-32,64s-16,33,-16,33s-26,-26,-26,-26
s76,-153,76,-153s77,-151,77,-151c0.7,0.7,35.7,202,105,604c67.3,400.7,102,602.7,104,
606zM${1001 + extraViniculum} ${hLinePad}h400000v${40 + extraViniculum}H1017.7z''';

String sqrtTall(final double extraViniculum, final double hLinePad, final double viewBoxHeight) {
  // sqrtTall is from glyph U23B7 in the font KaTeX_Size4-Regular
  // One path edge has a variable length. It runs vertically from the viniculumn
  // to a point near (14 units) the bottom of the surd. The viniculum
  // is normally 40 units thick. So the length of the line in question is:
  final vertSegment = viewBoxHeight - 54 - hLinePad - extraViniculum;

  return '''M702 ${extraViniculum + hLinePad}H400000${40 + extraViniculum}
H742v${vertSegment}l-4 4-4 4c-.667.7 -2 1.5-4 2.5s-4.167 1.833-6.5 2.5-5.5 1-9.5 1
h-12l-28-84c-16.667-52-96.667 -294.333-240-727l-212 -643 -85 170
c-4-3.333-8.333-7.667-13 -13l-13-13l77-155 77-156c66 199.333 139 419.667
219 661 l218 661zM702 ${hLinePad}H400000v${40 + extraViniculum}H742z''';
}

String sqrtPath(
  final String size,
  double extraViniculum,
  final double viewBoxHeight,
) {
  // ignore: parameter_assignments
  extraViniculum = 1000 * extraViniculum; // Convert from document ems to viewBox.
  String path = '';
  switch (size) {
    case 'sqrtMain':
      path = sqrtMain(extraViniculum, hLinePad);
      break;
    case 'sqrtSize1':
      path = sqrtSize1(extraViniculum, hLinePad);
      break;
    case 'sqrtSize2':
      path = sqrtSize2(extraViniculum, hLinePad);
      break;
    case 'sqrtSize3':
      path = sqrtSize3(extraViniculum, hLinePad);
      break;
    case 'sqrtSize4':
      path = sqrtSize4(extraViniculum, hLinePad);
      break;
    case 'sqrtTall':
      path = sqrtTall(extraViniculum, hLinePad, viewBoxHeight);
  }
  return path;
}

const svgPaths = {
  // The doubleleftarrow geometry is from glyph U+21D0 in the font KaTeX Main
  'doubleleftarrow': '''M262 157
l10-10c34-36 62.7-77 86-123 3.3-8 5-13.3 5-16 0-5.3-6.7-8-20-8-7.3
 0-12.2.5-14.5 1.5-2.3 1-4.8 4.5-7.5 10.5-49.3 97.3-121.7 169.3-217 216-28
 14-57.3 25-88 33-6.7 2-11 3.8-13 5.5-2 1.7-3 4.2-3 7.5s1 5.8 3 7.5
c2 1.7 6.3 3.5 13 5.5 68 17.3 128.2 47.8 180.5 91.5 52.3 43.7 93.8 96.2 124.5
 157.5 9.3 8 15.3 12.3 18 13h6c12-.7 18-4 18-10 0-2-1.7-7-5-15-23.3-46-52-87
-86-123l-10-10h399738v-40H218c328 0 0 0 0 0l-10-8c-26.7-20-65.7-43-117-69 2.7
-2 6-3.7 10-5 36.7-16 72.3-37.3 107-64l10-8h399782v-40z
m8 0v40h399730v-40zm0 194v40h399730v-40z''',

  // doublerightarrow is from glyph U+21D2 in font KaTeX Main
  'doublerightarrow': '''M399738 392l
-10 10c-34 36-62.7 77-86 123-3.3 8-5 13.3-5 16 0 5.3 6.7 8 20 8 7.3 0 12.2-.5
 14.5-1.5 2.3-1 4.8-4.5 7.5-10.5 49.3-97.3 121.7-169.3 217-216 28-14 57.3-25 88
-33 6.7-2 11-3.8 13-5.5 2-1.7 3-4.2 3-7.5s-1-5.8-3-7.5c-2-1.7-6.3-3.5-13-5.5-68
-17.3-128.2-47.8-180.5-91.5-52.3-43.7-93.8-96.2-124.5-157.5-9.3-8-15.3-12.3-18
-13h-6c-12 .7-18 4-18 10 0 2 1.7 7 5 15 23.3 46 52 87 86 123l10 10H0v40h399782
c-328 0 0 0 0 0l10 8c26.7 20 65.7 43 117 69-2.7 2-6 3.7-10 5-36.7 16-72.3 37.3
-107 64l-10 8H0v40zM0 157v40h399730v-40zm0 194v40h399730v-40z''',

  // leftarrow is from glyph U+2190 in font KaTeX Main
  'leftarrow': '''M400000 241H110l3-3c68.7-52.7 113.7-120
 135-202 4-14.7 6-23 6-25 0-7.3-7-11-21-11-8 0-13.2.8-15.5 2.5-2.3 1.7-4.2 5.8
-5.5 12.5-1.3 4.7-2.7 10.3-4 17-12 48.7-34.8 92-68.5 130S65.3 228.3 18 247
c-10 4-16 7.7-18 11 0 8.7 6 14.3 18 17 47.3 18.7 87.8 47 121.5 85S196 441.3 208
 490c.7 2 1.3 5 2 9s1.2 6.7 1.5 8c.3 1.3 1 3.3 2 6s2.2 4.5 3.5 5.5c1.3 1 3.3
 1.8 6 2.5s6 1 10 1c14 0 21-3.7 21-11 0-2-2-10.3-6-25-20-79.3-65-146.7-135-202
 l-3-3h399890zM100 241v40h399900v-40z''',

  // overbrace is from glyphs U+23A9/23A8/23A7 in font KaTeX_Size4-Regular
  'leftbrace': '''M6 548l-6-6v-35l6-11c56-104 135.3-181.3 238-232 57.3-28.7 117
-45 179-50h399577v120H403c-43.3 7-81 15-113 26-100.7 33-179.7 91-237 174-2.7
 5-6 9-10 13-.7 1-7.3 1-20 1H6z''',

  'leftbraceunder': '''M0 6l6-6h17c12.688 0 19.313.3 20 1 4 4 7.313 8.3 10 13
 35.313 51.3 80.813 93.8 136.5 127.5 55.688 33.7 117.188 55.8 184.5 66.5.688
 0 2 .3 4 1 18.688 2.7 76 4.3 172 5h399450v120H429l-6-1c-124.688-8-235-61.7
-331-161C60.687 138.7 32.312 99.3 7 54L0 41V6z''',

  // overgroup is from the MnSymbol package (public domain)
  'leftgroup': '''M400000 80
H435C64 80 168.3 229.4 21 260c-5.9 1.2-18 0-18 0-2 0-3-1-3-3v-38C76 61 257 0
 435 0h399565z''',

  'leftgroupunder': '''M400000 262
H435C64 262 168.3 112.6 21 82c-5.9-1.2-18 0-18 0-2 0-3 1-3 3v38c76 158 257 219
 435 219h399565z''',

  // Harpoons are from glyph U+21BD in font KaTeX Main
  'leftharpoon': '''M0 267c.7 5.3 3 10 7 14h399993v-40H93c3.3
-3.3 10.2-9.5 20.5-18.5s17.8-15.8 22.5-20.5c50.7-52 88-110.3 112-175 4-11.3 5
-18.3 3-21-1.3-4-7.3-6-18-6-8 0-13 .7-15 2s-4.7 6.7-8 16c-42 98.7-107.3 174.7
-196 228-6.7 4.7-10.7 8-12 10-1.3 2-2 5.7-2 11zm100-26v40h399900v-40z''',

  'leftharpoonplus': '''M0 267c.7 5.3 3 10 7 14h399993v-40H93c3.3-3.3 10.2-9.5
 20.5-18.5s17.8-15.8 22.5-20.5c50.7-52 88-110.3 112-175 4-11.3 5-18.3 3-21-1.3
-4-7.3-6-18-6-8 0-13 .7-15 2s-4.7 6.7-8 16c-42 98.7-107.3 174.7-196 228-6.7 4.7
-10.7 8-12 10-1.3 2-2 5.7-2 11zm100-26v40h399900v-40zM0 435v40h400000v-40z
m0 0v40h400000v-40z''',

  'leftharpoondown': '''M7 241c-4 4-6.333 8.667-7 14 0 5.333.667 9 2 11s5.333
 5.333 12 10c90.667 54 156 130 196 228 3.333 10.667 6.333 16.333 9 17 2 .667 5
 1 9 1h5c10.667 0 16.667-2 18-6 2-2.667 1-9.667-3-21-32-87.333-82.667-157.667
-152-211l-3-3h399907v-40zM93 281 H400000 v-40L7 241z''',

  'leftharpoondownplus': '''M7 435c-4 4-6.3 8.7-7 14 0 5.3.7 9 2 11s5.3 5.3 12
 10c90.7 54 156 130 196 228 3.3 10.7 6.3 16.3 9 17 2 .7 5 1 9 1h5c10.7 0 16.7
-2 18-6 2-2.7 1-9.7-3-21-32-87.3-82.7-157.7-152-211l-3-3h399907v-40H7zm93 0
v40h399900v-40zM0 241v40h399900v-40zm0 0v40h399900v-40z''',

  // hook is from glyph U+21A9 in font KaTeX Main
  'lefthook': '''M400000 281 H103s-33-11.2-61-33.5S0 197.3 0 164s14.2-61.2 42.5
-83.5C70.8 58.2 104 47 142 47 c16.7 0 25 6.7 25 20 0 12-8.7 18.7-26 20-40 3.3
-68.7 15.7-86 37-10 12-15 25.3-15 40 0 22.7 9.8 40.7 29.5 54 19.7 13.3 43.5 21
 71.5 23h399859zM103 281v-40h399897v40z''',

  'leftlinesegment': '''M40 281 V428 H0 V94 H40 V241 H400000 v40z
M40 281 V428 H0 V94 H40 V241 H400000 v40z''',

  'leftmapsto': '''M40 281 V448H0V74H40V241H400000v40z
M40 281 V448H0V74H40V241H400000v40z''',

  // tofrom is from glyph U+21C4 in font KaTeX AMS Regular
  'leftToFrom': '''M0 147h400000v40H0zm0 214c68 40 115.7 95.7 143 167h22c15.3 0 23
-.3 23-1 0-1.3-5.3-13.7-16-37-18-35.3-41.3-69-70-101l-7-8h399905v-40H95l7-8
c28.7-32 52-65.7 70-101 10.7-23.3 16-35.7 16-37 0-.7-7.7-1-23-1h-22C115.7 265.3
 68 321 0 361zm0-174v-40h399900v40zm100 154v40h399900v-40z''',

  'longequal': '''M0 50 h400000 v40H0z m0 194h40000v40H0z
M0 50 h400000 v40H0z m0 194h40000v40H0z''',

  'midbrace': '''M200428 334
c-100.7-8.3-195.3-44-280-108-55.3-42-101.7-93-139-153l-9-14c-2.7 4-5.7 8.7-9 14
-53.3 86.7-123.7 153-211 199-66.7 36-137.3 56.3-212 62H0V214h199568c178.3-11.7
 311.7-78.3 403-201 6-8 9.7-12 11-12 .7-.7 6.7-1 18-1s17.3.3 18 1c1.3 0 5 4 11
 12 44.7 59.3 101.3 106.3 170 141s145.3 54.3 229 60h199572v120z''',

  'midbraceunder': '''M199572 214
c100.7 8.3 195.3 44 280 108 55.3 42 101.7 93 139 153l9 14c2.7-4 5.7-8.7 9-14
 53.3-86.7 123.7-153 211-199 66.7-36 137.3-56.3 212-62h199568v120H200432c-178.3
 11.7-311.7 78.3-403 201-6 8-9.7 12-11 12-.7.7-6.7 1-18 1s-17.3-.3-18-1c-1.3 0
-5-4-11-12-44.7-59.3-101.3-106.3-170-141s-145.3-54.3-229-60H0V214z''',

  'oiintSize1': '''M512.6 71.6c272.6 0 320.3 106.8 320.3 178.2 0 70.8-47.7 177.6
-320.3 177.6S193.1 320.6 193.1 249.8c0-71.4 46.9-178.2 319.5-178.2z
m368.1 178.2c0-86.4-60.9-215.4-368.1-215.4-306.4 0-367.3 129-367.3 215.4 0 85.8
60.9 214.8 367.3 214.8 307.2 0 368.1-129 368.1-214.8z''',

  'oiintSize2': '''M757.8 100.1c384.7 0 451.1 137.6 451.1 230 0 91.3-66.4 228.8
-451.1 228.8-386.3 0-452.7-137.5-452.7-228.8 0-92.4 66.4-230 452.7-230z
m502.4 230c0-111.2-82.4-277.2-502.4-277.2s-504 166-504 277.2
c0 110 84 276 504 276s502.4-166 502.4-276z''',

  'oiiintSize1': '''M681.4 71.6c408.9 0 480.5 106.8 480.5 178.2 0 70.8-71.6 177.6
-480.5 177.6S202.1 320.6 202.1 249.8c0-71.4 70.5-178.2 479.3-178.2z
m525.8 178.2c0-86.4-86.8-215.4-525.7-215.4-437.9 0-524.7 129-524.7 215.4 0
85.8 86.8 214.8 524.7 214.8 438.9 0 525.7-129 525.7-214.8z''',

  'oiiintSize2': '''M1021.2 53c603.6 0 707.8 165.8 707.8 277.2 0 110-104.2 275.8
-707.8 275.8-606 0-710.2-165.8-710.2-275.8C311 218.8 415.2 53 1021.2 53z
m770.4 277.1c0-131.2-126.4-327.6-770.5-327.6S248.4 198.9 248.4 330.1
c0 130 128.8 326.4 772.7 326.4s770.5-196.4 770.5-326.4z''',

  'rightarrow': '''M0 241v40h399891c-47.3 35.3-84 78-110 128
-16.7 32-27.7 63.7-33 95 0 1.3-.2 2.7-.5 4-.3 1.3-.5 2.3-.5 3 0 7.3 6.7 11 20
 11 8 0 13.2-.8 15.5-2.5 2.3-1.7 4.2-5.5 5.5-11.5 2-13.3 5.7-27 11-41 14.7-44.7
 39-84.5 73-119.5s73.7-60.2 119-75.5c6-2 9-5.7 9-11s-3-9-9-11c-45.3-15.3-85
-40.5-119-75.5s-58.3-74.8-73-119.5c-4.7-14-8.3-27.3-11-40-1.3-6.7-3.2-10.8-5.5
-12.5-2.3-1.7-7.5-2.5-15.5-2.5-14 0-21 3.7-21 11 0 2 2 10.3 6 25 20.7 83.3 67
 151.7 139 205zm0 0v40h399900v-40z''',

  'rightbrace': '''M400000 542l
-6 6h-17c-12.7 0-19.3-.3-20-1-4-4-7.3-8.3-10-13-35.3-51.3-80.8-93.8-136.5-127.5
s-117.2-55.8-184.5-66.5c-.7 0-2-.3-4-1-18.7-2.7-76-4.3-172-5H0V214h399571l6 1
c124.7 8 235 61.7 331 161 31.3 33.3 59.7 72.7 85 118l7 13v35z''',

  'rightbraceunder': '''M399994 0l6 6v35l-6 11c-56 104-135.3 181.3-238 232-57.3
 28.7-117 45-179 50H-300V214h399897c43.3-7 81-15 113-26 100.7-33 179.7-91 237
-174 2.7-5 6-9 10-13 .7-1 7.3-1 20-1h17z''',

  'rightgroup': '''M0 80h399565c371 0 266.7 149.4 414 180 5.9 1.2 18 0 18 0 2 0
 3-1 3-3v-38c-76-158-257-219-435-219H0z''',

  'rightgroupunder': '''M0 262h399565c371 0 266.7-149.4 414-180 5.9-1.2 18 0 18
 0 2 0 3 1 3 3v38c-76 158-257 219-435 219H0z''',

  'rightharpoon': '''M0 241v40h399993c4.7-4.7 7-9.3 7-14 0-9.3
-3.7-15.3-11-18-92.7-56.7-159-133.7-199-231-3.3-9.3-6-14.7-8-16-2-1.3-7-2-15-2
-10.7 0-16.7 2-18 6-2 2.7-1 9.7 3 21 15.3 42 36.7 81.8 64 119.5 27.3 37.7 58
 69.2 92 94.5zm0 0v40h399900v-40z''',

  'rightharpoonplus': '''M0 241v40h399993c4.7-4.7 7-9.3 7-14 0-9.3-3.7-15.3-11
-18-92.7-56.7-159-133.7-199-231-3.3-9.3-6-14.7-8-16-2-1.3-7-2-15-2-10.7 0-16.7
 2-18 6-2 2.7-1 9.7 3 21 15.3 42 36.7 81.8 64 119.5 27.3 37.7 58 69.2 92 94.5z
m0 0v40h399900v-40z m100 194v40h399900v-40zm0 0v40h399900v-40z''',

  'rightharpoondown': '''M399747 511c0 7.3 6.7 11 20 11 8 0 13-.8 15-2.5s4.7-6.8
 8-15.5c40-94 99.3-166.3 178-217 13.3-8 20.3-12.3 21-13 5.3-3.3 8.5-5.8 9.5
-7.5 1-1.7 1.5-5.2 1.5-10.5s-2.3-10.3-7-15H0v40h399908c-34 25.3-64.7 57-92 95
-27.3 38-48.7 77.7-64 119-3.3 8.7-5 14-5 16zM0 241v40h399900v-40z''',

  'rightharpoondownplus': '''M399747 705c0 7.3 6.7 11 20 11 8 0 13-.8
 15-2.5s4.7-6.8 8-15.5c40-94 99.3-166.3 178-217 13.3-8 20.3-12.3 21-13 5.3-3.3
 8.5-5.8 9.5-7.5 1-1.7 1.5-5.2 1.5-10.5s-2.3-10.3-7-15H0v40h399908c-34 25.3
-64.7 57-92 95-27.3 38-48.7 77.7-64 119-3.3 8.7-5 14-5 16zM0 435v40h399900v-40z
m0-194v40h400000v-40zm0 0v40h400000v-40z''',

  'righthook': '''M399859 241c-764 0 0 0 0 0 40-3.3 68.7-15.7 86-37 10-12 15-25.3
 15-40 0-22.7-9.8-40.7-29.5-54-19.7-13.3-43.5-21-71.5-23-17.3-1.3-26-8-26-20 0
-13.3 8.7-20 26-20 38 0 71 11.2 99 33.5 0 0 7 5.6 21 16.7 14 11.2 21 33.5 21
 66.8s-14 61.2-42 83.5c-28 22.3-61 33.5-99 33.5L0 241z M0 281v-40h399859v40z''',

  'rightlinesegment': '''M399960 241 V94 h40 V428 h-40 V281 H0 v-40z
M399960 241 V94 h40 V428 h-40 V281 H0 v-40z''',

  'rightToFrom': '''M400000 167c-70.7-42-118-97.7-142-167h-23c-15.3 0-23 .3-23
 1 0 1.3 5.3 13.7 16 37 18 35.3 41.3 69 70 101l7 8H0v40h399905l-7 8c-28.7 32
-52 65.7-70 101-10.7 23.3-16 35.7-16 37 0 .7 7.7 1 23 1h23c24-69.3 71.3-125 142
-167z M100 147v40h399900v-40zM0 341v40h399900v-40z''',

  // twoheadleftarrow is from glyph U+219E in font KaTeX AMS Regular
  'twoheadleftarrow': '''M0 167c68 40
 115.7 95.7 143 167h22c15.3 0 23-.3 23-1 0-1.3-5.3-13.7-16-37-18-35.3-41.3-69
-70-101l-7-8h125l9 7c50.7 39.3 85 86 103 140h46c0-4.7-6.3-18.7-19-42-18-35.3
-40-67.3-66-96l-9-9h399716v-40H284l9-9c26-28.7 48-60.7 66-96 12.7-23.333 19
-37.333 19-42h-46c-18 54-52.3 100.7-103 140l-9 7H95l7-8c28.7-32 52-65.7 70-101
 10.7-23.333 16-35.7 16-37 0-.7-7.7-1-23-1h-22C115.7 71.3 68 127 0 167z''',

  'twoheadrightarrow': '''M400000 167
c-68-40-115.7-95.7-143-167h-22c-15.3 0-23 .3-23 1 0 1.3 5.3 13.7 16 37 18 35.3
 41.3 69 70 101l7 8h-125l-9-7c-50.7-39.3-85-86-103-140h-46c0 4.7 6.3 18.7 19 42
 18 35.3 40 67.3 66 96l9 9H0v40h399716l-9 9c-26 28.7-48 60.7-66 96-12.7 23.333
-19 37.333-19 42h46c18-54 52.3-100.7 103-140l9-7h125l-7 8c-28.7 32-52 65.7-70
 101-10.7 23.333-16 35.7-16 37 0 .7 7.7 1 23 1h22c27.3-71.3 75-127 143-167z''',

  // tilde1 is a modified version of a glyph from the MnSymbol package
  'tilde1': '''M200 55.538c-77 0-168 73.953-177 73.953-3 0-7
-2.175-9-5.437L2 97c-1-2-2-4-2-6 0-4 2-7 5-9l20-12C116 12 171 0 207 0c86 0
 114 68 191 68 78 0 168-68 177-68 4 0 7 2 9 5l12 19c1 2.175 2 4.35 2 6.525 0
 4.35-2 7.613-5 9.788l-19 13.05c-92 63.077-116.937 75.308-183 76.128
-68.267.847-113-73.952-191-73.952z''',

  // ditto tilde2, tilde3, & tilde4
  'tilde2': '''M344 55.266c-142 0-300.638 81.316-311.5 86.418
-8.01 3.762-22.5 10.91-23.5 5.562L1 120c-1-2-1-3-1-4 0-5 3-9 8-10l18.4-9C160.9
 31.9 283 0 358 0c148 0 188 122 331 122s314-97 326-97c4 0 8 2 10 7l7 21.114
c1 2.14 1 3.21 1 4.28 0 5.347-3 9.626-7 10.696l-22.3 12.622C852.6 158.372 751
 181.476 676 181.476c-149 0-189-126.21-332-126.21z''',

  'tilde3': '''M786 59C457 59 32 175.242 13 175.242c-6 0-10-3.457
-11-10.37L.15 138c-1-7 3-12 10-13l19.2-6.4C378.4 40.7 634.3 0 804.3 0c337 0
 411.8 157 746.8 157 328 0 754-112 773-112 5 0 10 3 11 9l1 14.075c1 8.066-.697
 16.595-6.697 17.492l-21.052 7.31c-367.9 98.146-609.15 122.696-778.15 122.696
 -338 0-409-156.573-744-156.573z''',

  'tilde4': '''M786 58C457 58 32 177.487 13 177.487c-6 0-10-3.345
-11-10.035L.15 143c-1-7 3-12 10-13l22-6.7C381.2 35 637.15 0 807.15 0c337 0 409
 177 744 177 328 0 754-127 773-127 5 0 10 3 11 9l1 14.794c1 7.805-3 13.38-9
 14.495l-20.7 5.574c-366.85 99.79-607.3 139.372-776.3 139.372-338 0-409
 -175.236-744-175.236z''',

  // vec is from glyph U+20D7 in font KaTeX Main
  'vec': '''M377 20c0-5.333 1.833-10 5.5-14S391 0 397 0c4.667 0 8.667 1.667 12 5
3.333 2.667 6.667 9 10 19 6.667 24.667 20.333 43.667 41 57 7.333 4.667 11
10.667 11 18 0 6-1 10-3 12s-6.667 5-14 9c-28.667 14.667-53.667 35.667-75 63
-1.333 1.333-3.167 3.5-5.5 6.5s-4 4.833-5 5.5c-1 .667-2.5 1.333-4.5 2s-4.333 1
-7 1c-4.667 0-9.167-1.833-13.5-5.5S337 184 337 178c0-12.667 15.667-32.333 47-59
H213l-171-1c-8.667-6-13-12.333-13-19 0-4.667 4.333-11.333 13-20h359
c-16-25.333-24-45-24-59z''',

  // widehat1 is a modified version of a glyph from the MnSymbol package
  'widehat1': '''M529 0h5l519 115c5 1 9 5 9 10 0 1-1 2-1 3l-4 22
c-1 5-5 9-11 9h-2L532 67 19 159h-2c-5 0-9-4-11-9l-5-22c-1-6 2-12 8-13z''',

  // ditto widehat2, widehat3, & widehat4
  'widehat2': '''M1181 0h2l1171 176c6 0 10 5 10 11l-2 23c-1 6-5 10
-11 10h-1L1182 67 15 220h-1c-6 0-10-4-11-10l-2-23c-1-6 4-11 10-11z''',

  'widehat3': '''M1181 0h2l1171 236c6 0 10 5 10 11l-2 23c-1 6-5 10
-11 10h-1L1182 67 15 280h-1c-6 0-10-4-11-10l-2-23c-1-6 4-11 10-11z''',

  'widehat4': '''M1181 0h2l1171 296c6 0 10 5 10 11l-2 23c-1 6-5 10
-11 10h-1L1182 67 15 340h-1c-6 0-10-4-11-10l-2-23c-1-6 4-11 10-11z''',

  // widecheck paths are all inverted versions of widehat
  'widecheck1': '''M529,159h5l519,-115c5,-1,9,-5,9,-10c0,-1,-1,-2,-1,-3l-4,-22c-1,
-5,-5,-9,-11,-9h-2l-512,92l-513,-92h-2c-5,0,-9,4,-11,9l-5,22c-1,6,2,12,8,13z''',

  'widecheck2': '''M1181,220h2l1171,-176c6,0,10,-5,10,-11l-2,-23c-1,-6,-5,-10,
-11,-10h-1l-1168,153l-1167,-153h-1c-6,0,-10,4,-11,10l-2,23c-1,6,4,11,10,11z''',

  'widecheck3': '''M1181,280h2l1171,-236c6,0,10,-5,10,-11l-2,-23c-1,-6,-5,-10,
-11,-10h-1l-1168,213l-1167,-213h-1c-6,0,-10,4,-11,10l-2,23c-1,6,4,11,10,11z''',

  'widecheck4': '''M1181,340h2l1171,-296c6,0,10,-5,10,-11l-2,-23c-1,-6,-5,-10,
-11,-10h-1l-1168,273l-1167,-273h-1c-6,0,-10,4,-11,10l-2,23c-1,6,4,11,10,11z''',

  // The next ten paths support reaction arrows from the mhchem package.

  // Arrows for \ce{<-->} are offset from xAxis by 0.22ex, per mhchem in LaTeX
  // baraboveleftarrow is mostly from from glyph U+2190 in font KaTeX Main
  'baraboveleftarrow': '''M400000 620h-399890l3 -3c68.7 -52.7 113.7 -120 135 -202
c4 -14.7 6 -23 6 -25c0 -7.3 -7 -11 -21 -11c-8 0 -13.2 0.8 -15.5 2.5
c-2.3 1.7 -4.2 5.8 -5.5 12.5c-1.3 4.7 -2.7 10.3 -4 17c-12 48.7 -34.8 92 -68.5 130
s-74.2 66.3 -121.5 85c-10 4 -16 7.7 -18 11c0 8.7 6 14.3 18 17c47.3 18.7 87.8 47
121.5 85s56.5 81.3 68.5 130c0.7 2 1.3 5 2 9s1.2 6.7 1.5 8c0.3 1.3 1 3.3 2 6
s2.2 4.5 3.5 5.5c1.3 1 3.3 1.8 6 2.5s6 1 10 1c14 0 21 -3.7 21 -11
c0 -2 -2 -10.3 -6 -25c-20 -79.3 -65 -146.7 -135 -202l-3 -3h399890z
M100 620v40h399900v-40z M0 241v40h399900v-40zM0 241v40h399900v-40z''',

  // rightarrowabovebar is mostly from glyph U+2192, KaTeX Main
  'rightarrowabovebar': '''M0 241v40h399891c-47.3 35.3-84 78-110 128-16.7 32
-27.7 63.7-33 95 0 1.3-.2 2.7-.5 4-.3 1.3-.5 2.3-.5 3 0 7.3 6.7 11 20 11 8 0
13.2-.8 15.5-2.5 2.3-1.7 4.2-5.5 5.5-11.5 2-13.3 5.7-27 11-41 14.7-44.7 39
-84.5 73-119.5s73.7-60.2 119-75.5c6-2 9-5.7 9-11s-3-9-9-11c-45.3-15.3-85-40.5
-119-75.5s-58.3-74.8-73-119.5c-4.7-14-8.3-27.3-11-40-1.3-6.7-3.2-10.8-5.5
-12.5-2.3-1.7-7.5-2.5-15.5-2.5-14 0-21 3.7-21 11 0 2 2 10.3 6 25 20.7 83.3 67
151.7 139 205zm96 379h399894v40H0zm0 0h399904v40H0z''',

  // The short left harpoon has 0.5em (i.e. 500 units) kern on the left end.
  // Ref from mhchem.sty: \rlap{\raisebox{-.22ex}{$\kern0.5em
  'baraboveshortleftharpoon': '''M507,435c-4,4,-6.3,8.7,-7,14c0,5.3,0.7,9,2,11
c1.3,2,5.3,5.3,12,10c90.7,54,156,130,196,228c3.3,10.7,6.3,16.3,9,17
c2,0.7,5,1,9,1c0,0,5,0,5,0c10.7,0,16.7,-2,18,-6c2,-2.7,1,-9.7,-3,-21
c-32,-87.3,-82.7,-157.7,-152,-211c0,0,-3,-3,-3,-3l399351,0l0,-40
c-398570,0,-399437,0,-399437,0z M593 435 v40 H399500 v-40z
M0 281 v-40 H399908 v40z M0 281 v-40 H399908 v40z''',

  'rightharpoonaboveshortbar': '''M0,241 l0,40c399126,0,399993,0,399993,0
c4.7,-4.7,7,-9.3,7,-14c0,-9.3,-3.7,-15.3,-11,-18c-92.7,-56.7,-159,-133.7,-199,
-231c-3.3,-9.3,-6,-14.7,-8,-16c-2,-1.3,-7,-2,-15,-2c-10.7,0,-16.7,2,-18,6
c-2,2.7,-1,9.7,3,21c15.3,42,36.7,81.8,64,119.5c27.3,37.7,58,69.2,92,94.5z
M0 241 v40 H399908 v-40z M0 475 v-40 H399500 v40z M0 475 v-40 H399500 v40z''',

  'shortbaraboveleftharpoon': '''M7,435c-4,4,-6.3,8.7,-7,14c0,5.3,0.7,9,2,11
c1.3,2,5.3,5.3,12,10c90.7,54,156,130,196,228c3.3,10.7,6.3,16.3,9,17c2,0.7,5,1,9,
1c0,0,5,0,5,0c10.7,0,16.7,-2,18,-6c2,-2.7,1,-9.7,-3,-21c-32,-87.3,-82.7,-157.7,
-152,-211c0,0,-3,-3,-3,-3l399907,0l0,-40c-399126,0,-399993,0,-399993,0z
M93 435 v40 H400000 v-40z M500 241 v40 H400000 v-40z M500 241 v40 H400000 v-40z''',

  'shortrightharpoonabovebar': '''M53,241l0,40c398570,0,399437,0,399437,0
c4.7,-4.7,7,-9.3,7,-14c0,-9.3,-3.7,-15.3,-11,-18c-92.7,-56.7,-159,-133.7,-199,
-231c-3.3,-9.3,-6,-14.7,-8,-16c-2,-1.3,-7,-2,-15,-2c-10.7,0,-16.7,2,-18,6
c-2,2.7,-1,9.7,3,21c15.3,42,36.7,81.8,64,119.5c27.3,37.7,58,69.2,92,94.5z
M500 241 v40 H399408 v-40z M500 435 v40 H400000 v-40z''',
};

class _KatexImagesData {
  final List<String> paths;
  final double minWidth;
  final double viewBoxHeight;
  final Alignment? align;

  const _KatexImagesData(
    this.paths,
    this.minWidth,
    this.viewBoxHeight, [
    final this.align,
  ]);
}

// \[(\[[^\]]*\]),([0-9.\s]*),([0-9.\s]*)(,? ?'[a-z]*'|)\]
// _KatexImagesData($1, $2, $3$4)
// xMinyMin -> Alignment.topLeft, xMaxyMin -> Alignment.topRight
const katexImagesData = {
  'overrightarrow': _KatexImagesData(['rightarrow'], 0.888, 522, Alignment.topRight),
  'overleftarrow': _KatexImagesData(['leftarrow'], 0.888, 522, Alignment.topLeft),
  'underrightarrow': _KatexImagesData(['rightarrow'], 0.888, 522, Alignment.topRight),
  'underleftarrow': _KatexImagesData(['leftarrow'], 0.888, 522, Alignment.topLeft),
  'xrightarrow': _KatexImagesData(['rightarrow'], 1.469, 522, Alignment.topRight),
  'xleftarrow': _KatexImagesData(['leftarrow'], 1.469, 522, Alignment.topLeft),
  'Overrightarrow': _KatexImagesData(['doublerightarrow'], 0.888, 560, Alignment.topRight),
  'xRightarrow': _KatexImagesData(['doublerightarrow'], 1.526, 560, Alignment.topRight),
  'xLeftarrow': _KatexImagesData(['doubleleftarrow'], 1.526, 560, Alignment.topLeft),
  'overleftharpoon': _KatexImagesData(['leftharpoon'], 0.888, 522, Alignment.topLeft),
  'xleftharpoonup': _KatexImagesData(['leftharpoon'], 0.888, 522, Alignment.topLeft),
  'xleftharpoondown': _KatexImagesData(['leftharpoondown'], 0.888, 522, Alignment.topLeft),
  'overrightharpoon': _KatexImagesData(['rightharpoon'], 0.888, 522, Alignment.topRight),
  'xrightharpoonup': _KatexImagesData(['rightharpoon'], 0.888, 522, Alignment.topRight),
  'xrightharpoondown': _KatexImagesData(['rightharpoondown'], 0.888, 522, Alignment.topRight),
  'xlongequal': _KatexImagesData(['longequal'], 0.888, 334, Alignment.topLeft),
  'xtwoheadleftarrow': _KatexImagesData(['twoheadleftarrow'], 0.888, 334, Alignment.topLeft),
  'xtwoheadrightarrow': _KatexImagesData(['twoheadrightarrow'], 0.888, 334, Alignment.topRight),

  'overleftrightarrow': _KatexImagesData(['leftarrow', 'rightarrow'], 0.888, 522),
  'overbrace': _KatexImagesData(['leftbrace', 'midbrace', 'rightbrace'], 1.6, 548),
  'underbrace': _KatexImagesData(['leftbraceunder', 'midbraceunder', 'rightbraceunder'], 1.6, 548),
  'underleftrightarrow': _KatexImagesData(['leftarrow', 'rightarrow'], 0.888, 522),
  'xleftrightarrow': _KatexImagesData(['leftarrow', 'rightarrow'], 1.75, 522),
  'xLeftrightarrow': _KatexImagesData(['doubleleftarrow', 'doublerightarrow'], 1.75, 560),
  'xrightleftharpoons': _KatexImagesData(['leftharpoondownplus', 'rightharpoonplus'], 1.75, 716),
  'xleftrightharpoons': _KatexImagesData(['leftharpoonplus', 'rightharpoondownplus'], 1.75, 716),
  'xhookleftarrow': _KatexImagesData(['leftarrow', 'righthook'], 1.08, 522),
  'xhookrightarrow': _KatexImagesData(['lefthook', 'rightarrow'], 1.08, 522),
  'overlinesegment': _KatexImagesData(['leftlinesegment', 'rightlinesegment'], 0.888, 522),
  'underlinesegment': _KatexImagesData(['leftlinesegment', 'rightlinesegment'], 0.888, 522),
  'overgroup': _KatexImagesData(['leftgroup', 'rightgroup'], 0.888, 342),
  'undergroup': _KatexImagesData(['leftgroupunder', 'rightgroupunder'], 0.888, 342),
  'xmapsto': _KatexImagesData(['leftmapsto', 'rightarrow'], 1.5, 522),
  'xtofrom': _KatexImagesData(['leftToFrom', 'rightToFrom'], 1.75, 528),

  // The next three arrows are from the mhchem package.
  // In mhchem.sty, min-length is 2.0em. But these arrows might appear in the
  // document as \xrightarrow or \xrightleftharpoons. Those have
  // min-length = 1.75em, so we set min-length on these next three to match.
  'xrightleftarrows': _KatexImagesData(['baraboveleftarrow', 'rightarrowabovebar'], 1.75, 901),
  'xrightequilibrium': _KatexImagesData(['baraboveshortleftharpoon', 'rightharpoonaboveshortbar'], 1.75, 716),
  'xleftequilibrium': _KatexImagesData(['shortbaraboveleftharpoon', 'shortrightharpoonabovebar'], 1.75, 716),
};

Widget strechySvgSpan(
  final String name,
  final double width,
  final TexMathOptions options,
) {
  double viewBoxWidth = 400000.0;
  if (const {'widehat', 'widecheck', 'widetilde', 'utilde'}.contains(name)) {
    double viewBoxHeight;
    String pathName;
    double height;
    final effCharNum = (width / cssem(1.0).toLpUnder(options)).ceil();
    if (effCharNum > 5) {
      if (name == 'widehat' || name == 'widecheck') {
        viewBoxHeight = 420;
        viewBoxWidth = 2364;
        height = 0.42;
        pathName = '${name}4';
      } else {
        viewBoxHeight = 312;
        viewBoxWidth = 2340;
        height = 0.34;
        pathName = 'tilde4';
      }
    } else {
      final imgIndex = const [1, 1, 2, 2, 3, 3][effCharNum];
      if (name == 'widehat' || name == 'widecheck') {
        viewBoxWidth = const <double>[0, 1062, 2364, 2364, 2364][imgIndex];
        viewBoxHeight = const <double>[0, 239, 300, 360, 420][imgIndex];
        height = const <double>[0, 0.24, 0.3, 0.3, 0.36, 0.42][imgIndex];
        pathName = '$name$imgIndex';
      } else {
        viewBoxWidth = const <double>[0, 600, 1033, 2339, 2340][imgIndex];
        viewBoxHeight = const <double>[0, 260, 286, 306, 312][imgIndex];
        height = const <double>[0, 0.26, 0.286, 0.3, 0.306, 0.34][imgIndex];
        pathName = 'tilde$imgIndex';
      }
    }
    height = cssem(height).toLpUnder(options);
    return svgWidgetFromPath(
      svgPaths[pathName]!,
      Size(width, height),
      Rect.fromLTWH(0, 0, viewBoxWidth, viewBoxHeight),
      Color(options.color.argb),
    );
  } else {
    final data = katexImagesData[name];
    if (data == null) {
      throw ArgumentError.value(name, 'name', 'Invalid stretchy svg name');
    }
    final height = cssem(data.viewBoxHeight / 1000).toLpUnder(options);
    final numSvgChildren = data.paths.length;
    final actualWidth = max(width, cssem(data.minWidth).toLpUnder(options));
    List<Alignment> aligns;
    List<double> widths;
    switch (numSvgChildren) {
      case 1:
        aligns = [data.align!]; // Single svg must specify their alignment
        widths = [actualWidth];
        break;
      case 2:
        aligns = const [Alignment.topLeft, Alignment.topRight];
        widths = [actualWidth / 2, actualWidth / 2];
        break;
      case 3:
        aligns = const [Alignment.topLeft, Alignment.topCenter, Alignment.topRight];
        widths = [actualWidth / 4, actualWidth / 2, actualWidth / 4];
        break;
      default:
        throw StateError('Bug inside stretchy svg code');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        numSvgChildren,
        (final index) => svgWidgetFromPath(
          svgPaths[data.paths[index]]!,
          Size(widths[index], height),
          Rect.fromLTWH(0, 0, viewBoxWidth, data.viewBoxHeight),
          Color(options.color.argb),
          align: aligns[index],
          fit: BoxFit.cover, // BoxFit.fitHeight, // For DomCanvas compatibility
        ),
        growable: false,
      ),
    );
  }
}

const stretchyCodePoint = {
  'widehat': '^',
  'widecheck': 'ˇ',
  'widetilde': '~',
  'utilde': '~',
  'overleftarrow': '\u2190',
  'underleftarrow': '\u2190',
  'xleftarrow': '\u2190',
  'overrightarrow': '\u2192',
  'underrightarrow': '\u2192',
  'xrightarrow': '\u2192',
  'underbrace': '\u23df',
  'overbrace': '\u23de',
  'overgroup': '\u23e0',
  'undergroup': '\u23e1',
  'overleftrightarrow': '\u2194',
  'underleftrightarrow': '\u2194',
  'xleftrightarrow': '\u2194',
  'Overrightarrow': '\u21d2',
  'xRightarrow': '\u21d2',
  'overleftharpoon': '\u21bc',
  'xleftharpoonup': '\u21bc',
  'overrightharpoon': '\u21c0',
  'xrightharpoonup': '\u21c0',
  'xLeftarrow': '\u21d0',
  'xLeftrightarrow': '\u21d4',
  'xhookleftarrow': '\u21a9',
  'xhookrightarrow': '\u21aa',
  'xmapsto': '\u21a6',
  'xrightharpoondown': '\u21c1',
  'xleftharpoondown': '\u21bd',
  'xrightleftharpoons': '\u21cc',
  'xleftrightharpoons': '\u21cb',
  'xtwoheadleftarrow': '\u219e',
  'xtwoheadrightarrow': '\u21a0',
  'xlongequal': '=',
  'xtofrom': '\u21c4',
  'xrightleftarrows': '\u21c4',
  'xrightequilibrium': '\u21cc', // Not a perfect match.
  'xleftequilibrium': '\u21cb', // None better available.
};

const svgData = {
  //   path, width, height
  'vec': [0.471, 0.714], // values from the font glyph
  'oiintSize1': [0.957, 0.499], // oval to overlay the integrand
  'oiintSize2': [1.472, 0.659],
  'oiiintSize1': [1.304, 0.499],
  'oiiintSize2': [1.98, 0.659],
};

Widget staticSvg(
  final String name,
  final TexMathOptions options, {
  final bool needBaseline = false,
}) {
  final dimen = svgData[name];
  if (dimen == null) {
    throw ArgumentError.value(name, 'name', 'Invalid static svg name');
  } else {
    final width = dimen[0];
    final height = dimen[1];
    final viewPortWidth = cssem(width).toLpUnder(options);
    final viewPortHeight = cssem(height).toLpUnder(options);
    final svgWidget = svgWidgetFromPath(
      svgPaths[name]!,
      Size(viewPortWidth, viewPortHeight),
      Rect.fromLTWH(0, 0, 1000 * width, 1000 * height),
      Color(options.color.argb),
    );
    if (needBaseline) {
      return ResetBaseline(
        height: viewPortHeight,
        child: svgWidget,
      );
    }
    return svgWidget;
  }
}

void drawSvgRoot(
  final DrawableRoot svgRoot,
  final PaintingContext context,
  final Offset offset,
) {
  final canvas = context.canvas;
  canvas.save();
  canvas.translate(offset.dx, offset.dy);
  canvas.scale(
    svgRoot.viewport.width / svgRoot.viewport.viewBox.width,
    svgRoot.viewport.height / svgRoot.viewport.viewBox.height,
  );
  canvas.clipRect(Rect.fromLTWH(0.0, 0.0, svgRoot.viewport.viewBox.width, svgRoot.viewport.viewBox.height));
  svgRoot.draw(canvas, Rect.largest);
  canvas.restore();
}

class DelimiterConf {
  final TexFontOptions font;
  final TexMathStyle style;

  const DelimiterConf(
    this.font,
    this.style,
  );
}

const mainRegular = TexFontOptionsImpl(fontFamily: 'Main');
const size1Regular = TexFontOptionsImpl(fontFamily: 'Size1');
const size2Regular = TexFontOptionsImpl(fontFamily: 'Size2');
const size3Regular = TexFontOptionsImpl(fontFamily: 'Size3');
const size4Regular = TexFontOptionsImpl(fontFamily: 'Size4');

const stackNeverDelimiterSequence = [
  DelimiterConf(mainRegular, TexMathStyle.scriptscript),
  DelimiterConf(mainRegular, TexMathStyle.script),
  DelimiterConf(mainRegular, TexMathStyle.text),
  DelimiterConf(size1Regular, TexMathStyle.text),
  DelimiterConf(size2Regular, TexMathStyle.text),
  DelimiterConf(size3Regular, TexMathStyle.text),
  DelimiterConf(size4Regular, TexMathStyle.text),
];

const stackAlwaysDelimiterSequence = [
  DelimiterConf(mainRegular, TexMathStyle.scriptscript),
  DelimiterConf(mainRegular, TexMathStyle.script),
  DelimiterConf(mainRegular, TexMathStyle.text),
];

const stackLargeDelimiterSequence = [
  DelimiterConf(mainRegular, TexMathStyle.scriptscript),
  DelimiterConf(mainRegular, TexMathStyle.script),
  DelimiterConf(mainRegular, TexMathStyle.text),
  DelimiterConf(size1Regular, TexMathStyle.text),
  DelimiterConf(size2Regular, TexMathStyle.text),
  DelimiterConf(size3Regular, TexMathStyle.text),
  DelimiterConf(size4Regular, TexMathStyle.text),
];

double getHeightForDelim({
  required final String delim,
  required final String fontName,
  required final TexMathStyle style,
  required final TexMathOptions options,
}) {
  final char = symbolRenderConfigs[delim]?.math?.replaceChar ?? delim;
  final metrics = texGetCharacterMetrics(
    character: char,
    fontName: fontName,
    mode: TexMode.math,
  );
  if (metrics == null) {
    throw StateError('Illegal delimiter char $delim'
        '(${unicodeLiteral(delim)}) appeared in AST');
  } else {
    final fullHeight = metrics.height + metrics.depth;
    final newOptions = options.havingStyle(style);
    return cssem(fullHeight).toLpUnder(newOptions);
  }
}
