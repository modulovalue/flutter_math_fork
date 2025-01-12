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

// Parts of this file are transformed from KaTeX/src/symbols.js

import 'ast.dart';
import 'ast_impl.dart';

class SymbolId {
  final String symbol;
  final bool variantForm;

  const SymbolId(
    final this.symbol, {
    final this.variantForm = false,
  });

  @override
  bool operator ==(final Object o) {
    if (identical(this, o)) return true;
    return o is SymbolId && o.symbol == symbol && o.variantForm == variantForm;
  }

  @override
  int get hashCode => symbol.hashCode ^ variantForm.hashCode;
}

class SymbolRenderConfig {
  final RenderConfig? math;
  final RenderConfig? text;
  final SymbolRenderConfig? variantForm;

  const SymbolRenderConfig({
    final this.math,
    final this.text,
    final this.variantForm,
  });
}

class RenderConfig {
  final String? replaceChar;
  final TexFontOptions defaultFont;
  final TexAtomType? defaultType;

  const RenderConfig(
    final this.defaultType,
    final this.defaultFont, [
    final this.replaceChar,
  ]);
}

const mainrm = TexFontOptionsImpl();

const amsrm = TexFontOptionsImpl(fontFamily: 'AMS');

const mathdefault = TexFontOptionsImpl(
  fontFamily: 'Math',
  fontShape: TexFontStyle.italic,
);

const mainit = TexFontOptionsImpl(
  fontShape: TexFontStyle.italic,
);

// I would like to use combined char + variantForm as map indexes.
// However Dart does not allow custom classes to be used as const map indexes.
// Hence here's the ugly solution.
const symbolRenderConfigs = {
  '0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 0
    text: RenderConfig(TexAtomType.ord, mainrm), // 0
  ), // 0
  '1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 1
    text: RenderConfig(TexAtomType.ord, mainrm), // 1
  ), // 1
  '2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 2
    text: RenderConfig(TexAtomType.ord, mainrm), // 2
  ), // 2
  '3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 3
    text: RenderConfig(TexAtomType.ord, mainrm), // 3
  ), // 3
  '4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 4
    text: RenderConfig(TexAtomType.ord, mainrm), // 4
  ), // 4
  '5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 5
    text: RenderConfig(TexAtomType.ord, mainrm), // 5
  ), // 5
  '6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 6
    text: RenderConfig(TexAtomType.ord, mainrm), // 6
  ), // 6
  '7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 7
    text: RenderConfig(TexAtomType.ord, mainrm), // 7
  ), // 7
  '8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 8
    text: RenderConfig(TexAtomType.ord, mainrm), // 8
  ), // 8
  '9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // 9
    text: RenderConfig(TexAtomType.ord, mainrm), // 9
  ), // 9
  '\u2261': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2261 \equiv
  ), // ≡
  '\u227A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u227A \prec
  ), // ≺
  '\u227B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u227B \succ
  ), // ≻
  '\u223C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u223C \sim
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm), // \thicksim
    ),
  ), // ∼
  '\u2AAF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2AAF \preceq
  ), // ⪯
  '\u2AB0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2AB0 \succeq
  ), // ⪰
  '\u2243': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2243 \simeq
  ), // ≃
  '\u2223': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2223 \mid \lvert \rvert \vert
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm), // \shortmid
    ),
  ), // ∣
  '\u226A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u226A \ll
  ), // ≪
  '\u226B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u226B \gg
  ), // ≫
  '\u224D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u224D \asymp
  ), // ≍
  '\u22C8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u22C8 \bowtie \Join
  ), // ⋈
  '\u2323': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2323 \smile
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm), // \smallsmile
    ),
  ), // ⌣
  '\u2291': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2291 \sqsubseteq
  ), // ⊑
  '\u2292': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2292 \sqsupseteq
  ), // ⊒
  '\u2250': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2250 \doteq
  ), // ≐
  '\u2322': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2322 \frown
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm), // \smallfrown
    ),
  ), // ⌢
  '\u220B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u220B \ni \owns
  ), // ∋
  '\u221D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u221D \propto
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm), // \varpropto
    ),
  ), // ∝
  '\u22A2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u22A2 \vdash
  ), // ⊢
  '\u22A3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u22A3 \dashv
  ), // ⊣
  '\u2135': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2135 \aleph
  ), // ℵ
  '\u2200': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2200 \forall
  ), // ∀
  '\u210F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u210F \hbar
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.ord, amsrm), // \hslash
    ),
  ), // ℏ
  '\u2203': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2203 \exists
  ), // ∃
  '\u2207': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2207 \nabla
  ), // ∇
  '\u266D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u266D \flat
  ), // ♭
  '\u2113': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2113 \ell
  ), // ℓ
  '\u266E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u266E \natural
  ), // ♮
  '\u2663': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2663 \clubsuit
  ), // ♣
  '\u2118': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2118 \wp
  ), // ℘
  '\u266F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u266F \sharp
  ), // ♯
  '\u2662': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2662 \diamondsuit
  ), // ♢
  '\u211C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u211C \Re
  ), // ℜ
  '\u2661': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2661 \heartsuit
  ), // ♡
  '\u2111': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2111 \Im
  ), // ℑ
  '\u2660': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2660 \spadesuit
  ), // ♠
  '\u23B1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // \u23B1 \rmoustache
  ), // ⎱
  '\u23B0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, mainrm), // \u23B0 \lmoustache
  ), // ⎰
  '\u27EF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // \u27EF \rgroup
  ), // ⟯
  '\u27EE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, mainrm), // \u27EE \lgroup
  ), // ⟮
  '\u2213': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2213 \mp
  ), // ∓
  '\u2296': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2296 \ominus
  ), // ⊖
  '\u228E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u228E \uplus
  ), // ⊎
  '\u2293': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2293 \sqcap
  ), // ⊓
  '\u2294': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2294 \sqcup
  ), // ⊔
  '\u2240': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2240 \wr
  ), // ≀
  '\u27F5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u27F5 \longleftarrow
  ), // ⟵
  '\u21D0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21D0 \Leftarrow
  ), // ⇐
  '\u27F8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u27F8 \Longleftarrow
  ), // ⟸
  '\u27F6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u27F6 \longrightarrow
  ), // ⟶
  '\u21D2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21D2 \Rightarrow
  ), // ⇒
  '\u27F9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u27F9 \Longrightarrow
  ), // ⟹
  '\u2194': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2194 \leftrightarrow
  ), // ↔
  '\u27F7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u27F7 \longleftrightarrow
  ), // ⟷
  '\u21D4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21D4 \Leftrightarrow
  ), // ⇔
  '\u27FA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u27FA \Longleftrightarrow
  ), // ⟺
  '\u21A6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21A6 \mapsto
  ), // ↦
  '\u27FC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u27FC \longmapsto
  ), // ⟼
  '\u2197': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2197 \nearrow
  ), // ↗
  '\u21A9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21A9 \hookleftarrow
  ), // ↩
  '\u21AA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21AA \hookrightarrow
  ), // ↪
  '\u2198': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2198 \searrow
  ), // ↘
  '\u21BC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21BC \leftharpoonup
  ), // ↼
  '\u21C0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21C0 \rightharpoonup
  ), // ⇀
  '\u2199': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2199 \swarrow
  ), // ↙
  '\u21BD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21BD \leftharpoondown
  ), // ↽
  '\u21C1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21C1 \rightharpoondown
  ), // ⇁
  '\u2196': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2196 \nwarrow
  ), // ↖
  '\u21CC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21CC \rightleftharpoons
  ), // ⇌
  '\u226E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u226E \nless
  ), // ≮
  '\u2A87': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A87 \lneq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE010'), // \nleqslant
    ),
  ), // ⪇
  '\u2268': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2268 \lneqq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE00C'), // \lvertneqq
    ),
  ), // ≨
  '\u22E6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22E6 \lnsim
  ), // ⋦
  '\u2A89': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A89 \lnapprox
  ), // ⪉
  '\u2280': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2280 \nprec
  ), // ⊀
  '\u22E0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22E0 \npreceq
  ), // ⋠
  '\u22E8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22E8 \precnsim
  ), // ⋨
  '\u2AB9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2AB9 \precnapprox
  ), // ⪹
  '\u2241': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2241 \nsim
  ), // ≁
  '\u2224': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2224 \nmid
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE006'), // \nshortmid
    ),
  ), // ∤
  '\u22AC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22AC \nvdash
  ), // ⊬
  '\u22AD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22AD \nvDash
  ), // ⊭
  '\u22EC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22EC \ntrianglelefteq
  ), // ⋬
  '\u228A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u228A \subsetneq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE01A'), // \varsubsetneq
    ),
  ), // ⊊
  '\u2ACB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2ACB \subsetneqq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE017'), // \varsubsetneqq
    ),
  ), // ⫋
  '\u226F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u226F \ngtr
  ), // ≯
  '\u2A88': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A88 \gneq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE00F'), // \ngeqslant
    ),
  ), // ⪈
  '\u2269': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2269 \gneqq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE00D'), // \gvertneqq
    ),
  ), // ≩
  '\u22E7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22E7 \gnsim
  ), // ⋧
  '\u2A8A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A8A \gnapprox
  ), // ⪊
  '\u2281': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2281 \nsucc
  ), // ⊁
  '\u22E1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22E1 \nsucceq
  ), // ⋡
  '\u22E9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22E9 \succnsim
  ), // ⋩
  '\u2ABA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2ABA \succnapprox
  ), // ⪺
  '\u2246': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2246 \ncong
  ), // ≆
  '\u2226': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2226 \nparallel
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE007'), // \nshortparallel
    ),
  ), // ∦
  '\u22AF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22AF \nVDash
  ), // ⊯
  '\u22ED': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22ED \ntrianglerighteq
  ), // ⋭
  '\u228B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u228B \supsetneq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE01B'), // \varsupsetneq
    ),
  ), // ⊋
  '\u2ACC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2ACC \supsetneqq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE019'), // \varsupsetneqq
    ),
  ), // ⫌
  '\u22AE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22AE \nVdash
  ), // ⊮
  '\u2AB5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2AB5 \precneqq
  ), // ⪵
  '\u2AB6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2AB6 \succneqq
  ), // ⪶
  '\u219A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u219A \nleftarrow
  ), // ↚
  '\u219B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u219B \nrightarrow
  ), // ↛
  '\u21CD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21CD \nLeftarrow
  ), // ⇍
  '\u21CF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21CF \nRightarrow
  ), // ⇏
  '\u21AE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21AE \nleftrightarrow
  ), // ↮
  '\u21CE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21CE \nLeftrightarrow
  ), // ⇎
  '\u2221': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u2221 \measuredangle
  ), // ∡
  '\u2132': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u2132 \Finv
  ), // Ⅎ
  '\u2141': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u2141 \Game
  ), // ⅁
  '\u2222': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u2222 \sphericalangle
  ), // ∢
  '\u2201': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u2201 \complement
  ), // ∁
  '\u00F0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u00F0 \eth
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00F0
  ), // ð
  '\u00A5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u00A5 \yen
    text: RenderConfig(TexAtomType.ord, amsrm), // \u00A5 \yen
  ), // ¥
  '\u2713': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u2713 \checkmark
    text: RenderConfig(TexAtomType.ord, amsrm), // \checkmark
  ), // ✓
  '\u2136': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u2136 \beth
  ), // ℶ
  '\u2138': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u2138 \daleth
  ), // ℸ
  '\u2137': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u2137 \gimel
  ), // ℷ
  '\u03DD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \u03DD \digamma
  ), // ϝ
  '\u250C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, amsrm), // \u250C \@ulcorner
  ), // ┌
  '\u2510': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, amsrm), // \u2510 \@urcorner
  ), // ┐
  '\u2514': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, amsrm), // \u2514 \@llcorner
  ), // └
  '\u2518': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, amsrm), // \u2518 \@lrcorner
  ), // ┘
  '\u2266': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2266 \leqq
  ), // ≦
  '\u2A7D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A7D \leqslant
  ), // ⩽
  '\u2A95': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A95 \eqslantless
  ), // ⪕
  '\u2272': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2272 \lesssim
  ), // ≲
  '\u2A85': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A85 \lessapprox
  ), // ⪅
  '\u224A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u224A \approxeq
  ), // ≊
  '\u22D8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22D8 \lll \llless
  ), // ⋘
  '\u2276': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2276 \lessgtr
  ), // ≶
  '\u22DA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22DA \lesseqgtr
  ), // ⋚
  '\u2A8B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A8B \lesseqqgtr
  ), // ⪋
  '\u2253': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2253 \risingdotseq
  ), // ≓
  '\u2252': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2252 \fallingdotseq
  ), // ≒
  '\u223D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u223D \backsim
  ), // ∽
  '\u22CD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22CD \backsimeq
  ), // ⋍
  '\u2AC5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2AC5 \subseteqq
  ), // ⫅
  '\u22D0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22D0 \Subset
  ), // ⋐
  '\u228F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u228F \sqsubset
  ), // ⊏
  '\u227C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u227C \preccurlyeq
  ), // ≼
  '\u22DE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22DE \curlyeqprec
  ), // ⋞
  '\u227E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u227E \precsim
  ), // ≾
  '\u2AB7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2AB7 \precapprox
  ), // ⪷
  '\u22A8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22A8 \vDash
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, mainrm), // \models
    ),
  ), // ⊨
  '\u22AA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22AA \Vvdash
  ), // ⊪
  '\u224F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u224F \bumpeq
  ), // ≏
  '\u224E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u224E \Bumpeq
  ), // ≎
  '\u2267': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2267 \geqq
  ), // ≧
  '\u2A7E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A7E \geqslant
  ), // ⩾
  '\u2A96': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A96 \eqslantgtr
  ), // ⪖
  '\u2273': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2273 \gtrsim
  ), // ≳
  '\u2A86': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A86 \gtrapprox
  ), // ⪆
  '\u22D9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22D9 \ggg \gggtr
  ), // ⋙
  '\u2277': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2277 \gtrless
  ), // ≷
  '\u22DB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22DB \gtreqless
  ), // ⋛
  '\u2A8C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2A8C \gtreqqless
  ), // ⪌
  '\u2256': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2256 \eqcirc
  ), // ≖
  '\u2257': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2257 \circeq
  ), // ≗
  '\u225C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u225C \triangleq
  ), // ≜
  '\u2AC6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2AC6 \supseteqq
  ), // ⫆
  '\u22D1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22D1 \Supset
  ), // ⋑
  '\u2290': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2290 \sqsupset
  ), // ⊐
  '\u227D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u227D \succcurlyeq
  ), // ≽
  '\u22DF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22DF \curlyeqsucc
  ), // ⋟
  '\u227F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u227F \succsim
  ), // ≿
  '\u2AB8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2AB8 \succapprox
  ), // ⪸
  '\u22A9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22A9 \Vdash
  ), // ⊩
  '\u226C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u226C \between
  ), // ≬
  '\u22D4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22D4 \pitchfork
  ), // ⋔
  '\u2234': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2234 \therefore
  ), // ∴
  '\u2235': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2235 \because
  ), // ∵
  '\u2242': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2242 \eqsim
  ), // ≂
  '\u2251': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2251 \doteqdot \Doteq
  ), // ≑
  '\u2214': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u2214 \dotplus
  ), // ∔
  '\u22D2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22D2 \Cap \doublecap
  ), // ⋒
  '\u22D3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22D3 \Cup \doublecup
  ), // ⋓
  '\u2A5E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u2A5E \doublebarwedge
  ), // ⩞
  '\u229F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u229F \boxminus
  ), // ⊟
  '\u229E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u229E \boxplus
  ), // ⊞
  '\u22C7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22C7 \divideontimes
  ), // ⋇
  '\u22C9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22C9 \ltimes
  ), // ⋉
  '\u22CA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22CA \rtimes
  ), // ⋊
  '\u22CB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22CB \leftthreetimes
  ), // ⋋
  '\u22CC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22CC \rightthreetimes
  ), // ⋌
  '\u22CF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22CF \curlywedge
  ), // ⋏
  '\u22CE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22CE \curlyvee
  ), // ⋎
  '\u229D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u229D \circleddash
  ), // ⊝
  '\u229B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u229B \circledast
  ), // ⊛
  '\u22BA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22BA \intercal
  ), // ⊺
  '\u22A0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22A0 \boxtimes
  ), // ⊠
  '\u21E2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21E2 \dashrightarrow
  ), // ⇢
  '\u21E0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21E0 \dashleftarrow
  ), // ⇠
  '\u21C7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21C7 \leftleftarrows
  ), // ⇇
  '\u21C6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21C6 \leftrightarrows
  ), // ⇆
  '\u21DA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21DA \Lleftarrow
  ), // ⇚
  '\u219E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u219E \twoheadleftarrow
  ), // ↞
  '\u21A2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21A2 \leftarrowtail
  ), // ↢
  '\u21AB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21AB \looparrowleft
  ), // ↫
  '\u21CB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21CB \leftrightharpoons
  ), // ⇋
  '\u21B6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21B6 \curvearrowleft
  ), // ↶
  '\u21BA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21BA \circlearrowleft
  ), // ↺
  '\u21B0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21B0 \Lsh
  ), // ↰
  '\u21C8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21C8 \upuparrows
  ), // ⇈
  '\u21BF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21BF \upharpoonleft
  ), // ↿
  '\u21C3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21C3 \downharpoonleft
  ), // ⇃
  '\u22B8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u22B8 \multimap
  ), // ⊸
  '\u21AD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21AD \leftrightsquigarrow
  ), // ↭
  '\u21C9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21C9 \rightrightarrows
  ), // ⇉
  '\u21C4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21C4 \rightleftarrows
  ), // ⇄
  '\u21A0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21A0 \twoheadrightarrow
  ), // ↠
  '\u21A3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21A3 \rightarrowtail
  ), // ↣
  '\u21AC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21AC \looparrowright
  ), // ↬
  '\u21B7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21B7 \curvearrowright
  ), // ↷
  '\u21BB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21BB \circlearrowright
  ), // ↻
  '\u21B1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21B1 \Rsh
  ), // ↱
  '\u21CA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21CA \downdownarrows
  ), // ⇊
  '\u21BE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21BE \upharpoonright \restriction
  ), // ↾
  '\u21C2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21C2 \downharpoonright
  ), // ⇂
  '\u21DD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21DD \rightsquigarrow \leadsto
  ), // ⇝
  '\u21DB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u21DB \Rrightarrow
  ), // ⇛
  '`': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, '\u2018'), // `
    text: RenderConfig(TexAtomType.ord, mainrm, '\u2018'), // `
  ), // `
  '\u2220': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2220 \angle
  ), // ∠
  '\u221E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u221E \infty
  ), // ∞
  '\u0393': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u0393 \Gamma
  ), // Γ
  '\u0394': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u0394 \Delta
  ), // Δ
  '\u0398': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u0398 \Theta
  ), // Θ
  '\u039B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u039B \Lambda
  ), // Λ
  '\u039E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u039E \Xi
  ), // Ξ
  '\u03A0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u03A0 \Pi
  ), // Π
  '\u03A3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u03A3 \Sigma
  ), // Σ
  '\u03A5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u03A5 \Upsilon
  ), // Υ
  '\u03A6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u03A6 \Phi
  ), // Φ
  '\u03A8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u03A8 \Psi
  ), // Ψ
  '\u03A9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u03A9 \Omega
  ), // Ω
  '\u0391': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \u0391
  ), // Α
  '\u0392': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \u0392
  ), // Β
  '\u0395': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \u0395
  ), // Ε
  '\u0396': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \u0396
  ), // Ζ
  '\u0397': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \u0397
  ), // Η
  '\u0399': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \u0399
  ), // Ι
  '\u039A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \u039A
  ), // Κ
  '\u039C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \u039C
  ), // Μ
  '\u039D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \u039D
  ), // Ν
  '\u039F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \u039F
  ), // Ο
  '\u03A1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \u03A1
  ), // Ρ
  '\u03A4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \u03A4
  ), // Τ
  '\u03A7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \u03A7
  ), // Χ
  '\u00AC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u00AC \neg \lnot
  ), // ¬
  '\u03B1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03B1 \alpha
  ), // α
  '\u03B2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03B2 \beta
  ), // β
  '\u03B3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03B3 \gamma
  ), // γ
  '\u03B4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03B4 \delta
  ), // δ
  '\u03F5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03F5 \epsilon
  ), // ϵ
  '\u03B6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03B6 \zeta
  ), // ζ
  '\u03B7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03B7 \eta
  ), // η
  '\u03B8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03B8 \theta
  ), // θ
  '\u03B9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03B9 \iota
  ), // ι
  '\u03BA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03BA \kappa
  ), // κ
  '\u03BB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03BB \lambda
  ), // λ
  '\u03BC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03BC \mu
  ), // μ
  '\u03BD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03BD \nu
  ), // ν
  '\u03BE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03BE \xi
  ), // ξ
  '\u03BF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03BF \omicron
  ), // ο
  '\u03C0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C0 \pi
  ), // π
  '\u03C1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C1 \rho
  ), // ρ
  '\u03C3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C3 \sigma
  ), // σ
  '\u03C4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C4 \tau
  ), // τ
  '\u03C5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C5 \upsilon
  ), // υ
  '\u03D5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03D5 \phi
  ), // ϕ
  '\u03C7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C7 \chi
  ), // χ
  '\u03C8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C8 \psi
  ), // ψ
  '\u03C9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C9 \omega
  ), // ω
  '\u03B5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03B5 \varepsilon
  ), // ε
  '\u03D1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03D1 \vartheta
  ), // ϑ
  '\u03D6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03D6 \varpi
  ), // ϖ
  '\u03F1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03F1 \varrho
  ), // ϱ
  '\u03C2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C2 \varsigma
  ), // ς
  '\u03C6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u03C6 \varphi
  ), // φ
  '*': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm, '\u2217'), // *
    text: RenderConfig(TexAtomType.ord, mainrm), // *
  ), // *
  '+': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // +
    text: RenderConfig(TexAtomType.ord, mainrm), // +
  ), // +
  '-': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm, '\u2212'), // -
    text: RenderConfig(TexAtomType.ord, mainrm), // -
  ), // -
  '\u22C5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u22C5 \cdotp \cdot
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.bin, amsrm), // \centerdot
    ),
  ), // ⋅
  '\u00F7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u00F7 \div
  ), // ÷
  '\u00B1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u00B1 \pm
  ), // ±
  '\u00D7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u00D7 \times
  ), // ×
  '\u2229': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2229 \cap
  ), // ∩
  '\u222A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u222A \cup
  ), // ∪
  '\u2227': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2227 \land \wedge
  ), // ∧
  '\u2228': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2228 \lor \vee
  ), // ∨
  '(': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, mainrm), // ( \lparen
    text: RenderConfig(TexAtomType.ord, mainrm), // (
  ), // (
  '[': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, mainrm), // [ \lbrack
    text: RenderConfig(TexAtomType.ord, mainrm), // [ \lbrack
  ), // [
  '\u27E8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, mainrm), // \u27E8 \langle
  ), // ⟨
  ')': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // ) \rparen
    text: RenderConfig(TexAtomType.ord, mainrm), // )
  ), // )
  ']': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // ] \rbrack
    text: RenderConfig(TexAtomType.ord, mainrm), // ] \rbrack
  ), // ]
  '?': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // ?
    text: RenderConfig(TexAtomType.ord, mainrm), // ?
  ), // ?
  '!': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // !
    text: RenderConfig(TexAtomType.ord, mainrm), // !
  ), // !
  '\u27E9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // \u27E9 \rangle
  ), // ⟩
  '=': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // =
    text: RenderConfig(TexAtomType.ord, mainrm), // =
  ), // =
  '<': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // < \lt
    text: RenderConfig(TexAtomType.ord, mainrm), // < \textless
  ), // <
  '>': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // > \gt
    text: RenderConfig(TexAtomType.ord, mainrm), // > \textgreater
  ), // >
  ':': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // :
    text: RenderConfig(TexAtomType.ord, mainrm), // :
  ), // :
  '\u2248': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2248 \approx
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm), // \thickapprox
    ),
  ), // ≈
  '\u2245': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2245 \cong
  ), // ≅
  '\u2265': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2265 \ge \geq
  ), // ≥
  '\u2208': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2208 \in
  ), // ∈
  '\u2282': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2282 \subset
  ), // ⊂
  '\u2283': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2283 \supset
  ), // ⊃
  '\u2286': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2286 \subseteq
  ), // ⊆
  '\u2287': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2287 \supseteq
  ), // ⊇
  '\u2288': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2288 \nsubseteq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE016'), // \nsubseteqq
    ),
  ), // ⊈
  '\u2289': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2289 \nsupseteq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE018'), // \nsupseteqq
    ),
  ), // ⊉
  '\u2190': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2190 \gets \leftarrow
  ), // ←
  '\u2264': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2264 \le \leq
  ), // ≤
  '\u2192': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2192 \rightarrow \to
  ), // →
  '\u2271': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2271 \ngeq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE00E'), // \ngeqq
    ),
  ), // ≱
  '\u2270': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \u2270 \nleq
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm, '\uE011'), // \nleqq
    ),
  ), // ≰
  ',': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.punct, mainrm), // ,
    text: RenderConfig(TexAtomType.ord, mainrm), // ,
  ), // ,
  ';': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.punct, mainrm), // ;
    text: RenderConfig(TexAtomType.ord, mainrm), // ;
  ), // ;
  '\u22BC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22BC \barwedge
  ), // ⊼
  '\u22BB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22BB \veebar
  ), // ⊻
  '\u2299': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2299 \odot
  ), // ⊙
  '\u2295': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2295 \oplus
  ), // ⊕
  '\u2297': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2297 \otimes
  ), // ⊗
  '\u2202': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u2202 \partial
  ), // ∂
  '\u2298': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \u2298 \oslash
  ), // ⊘
  '\u229A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u229A \circledcirc
  ), // ⊚
  '\u22A1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \u22A1 \boxdot
  ), // ⊡
  '\u230A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, mainrm), // \u230A \lfloor
  ), // ⌊
  '\u230B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // \u230B \rfloor
  ), // ⌋
  '\u2308': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, mainrm), // \u2308 \lceil
  ), // ⌈
  '\u2309': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // \u2309 \rceil
  ), // ⌉
  '|': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm, '\u2223'), // |
    text: RenderConfig(TexAtomType.ord, mainrm), // | \textbar
  ), // |
  '\u2191': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2191 \uparrow
  ), // ↑
  '\u21D1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21D1 \Uparrow
  ), // ⇑
  '\u2193': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2193 \downarrow
  ), // ↓
  '\u21D3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21D3 \Downarrow
  ), // ⇓
  '\u2195': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u2195 \updownarrow
  ), // ↕
  '\u21D5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \u21D5 \Updownarrow
  ), // ⇕
  '\u2026': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.inner, mainrm), // \u2026 \mathellipsis \ldots
    text: RenderConfig(TexAtomType.inner, mainrm), // \u2026 \textellipsis \ldots
  ), // …
  '\u22EF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.inner, mainrm), // \u22EF \@cdots
  ), // ⋯
  '\u22F1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.inner, mainrm), // \u22F1 \ddots
  ), // ⋱
  '\u0131': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainit), // \u0131 \imath
    text: RenderConfig(TexAtomType.ord, mainrm), // \u0131 \i
  ), // ı
  '\u0237': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainit), // \u0237 \jmath
    text: RenderConfig(TexAtomType.ord, mainrm), // \u0237 \j
  ), // ȷ
  '\u00B0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \u00B0 \degree
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00B0 \degree \textdegree
  ), // °
  '\u00A3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainit), // \u00A3 \pounds \mathsterling
    text: RenderConfig(TexAtomType.ord, mainit), // \u00A3 \pounds \textsterling
  ), // £
  '/': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // /
    text: RenderConfig(TexAtomType.ord, mainrm), // /
  ), // /
  '@': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // @
    text: RenderConfig(TexAtomType.ord, mainrm), // @
  ), // @
  '.': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // . \ldotp
    text: RenderConfig(TexAtomType.ord, mainrm), // .
  ), // .
  '\"': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // "
    text: RenderConfig(TexAtomType.ord, mainrm), // "
  ), // "
  'A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // A
    text: RenderConfig(TexAtomType.ord, mainrm), // A
  ), // A
  'B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // B
    text: RenderConfig(TexAtomType.ord, mainrm), // B
  ), // B
  'C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // C
    text: RenderConfig(TexAtomType.ord, mainrm), // C
  ), // C
  'D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // D
    text: RenderConfig(TexAtomType.ord, mainrm), // D
  ), // D
  'E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // E
    text: RenderConfig(TexAtomType.ord, mainrm), // E
  ), // E
  'F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // F
    text: RenderConfig(TexAtomType.ord, mainrm), // F
  ), // F
  'G': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // G
    text: RenderConfig(TexAtomType.ord, mainrm), // G
  ), // G
  'H': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // H
    text: RenderConfig(TexAtomType.ord, mainrm), // H
  ), // H
  'I': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // I
    text: RenderConfig(TexAtomType.ord, mainrm), // I
  ), // I
  'J': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // J
    text: RenderConfig(TexAtomType.ord, mainrm), // J
  ), // J
  'K': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // K
    text: RenderConfig(TexAtomType.ord, mainrm), // K
  ), // K
  'L': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // L
    text: RenderConfig(TexAtomType.ord, mainrm), // L
  ), // L
  'M': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // M
    text: RenderConfig(TexAtomType.ord, mainrm), // M
  ), // M
  'N': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // N
    text: RenderConfig(TexAtomType.ord, mainrm), // N
  ), // N
  'O': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // O
    text: RenderConfig(TexAtomType.ord, mainrm), // O
  ), // O
  'P': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // P
    text: RenderConfig(TexAtomType.ord, mainrm), // P
  ), // P
  'Q': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // Q
    text: RenderConfig(TexAtomType.ord, mainrm), // Q
  ), // Q
  'R': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // R
    text: RenderConfig(TexAtomType.ord, mainrm), // R
  ), // R
  'S': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // S
    text: RenderConfig(TexAtomType.ord, mainrm), // S
  ), // S
  'T': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // T
    text: RenderConfig(TexAtomType.ord, mainrm), // T
  ), // T
  'U': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // U
    text: RenderConfig(TexAtomType.ord, mainrm), // U
  ), // U
  'V': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // V
    text: RenderConfig(TexAtomType.ord, mainrm), // V
  ), // V
  'W': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // W
    text: RenderConfig(TexAtomType.ord, mainrm), // W
  ), // W
  'X': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // X
    text: RenderConfig(TexAtomType.ord, mainrm), // X
  ), // X
  'Y': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // Y
    text: RenderConfig(TexAtomType.ord, mainrm), // Y
  ), // Y
  'Z': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // Z
    text: RenderConfig(TexAtomType.ord, mainrm), // Z
  ), // Z
  'a': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // a
    text: RenderConfig(TexAtomType.ord, mainrm), // a
  ), // a
  'b': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // b
    text: RenderConfig(TexAtomType.ord, mainrm), // b
  ), // b
  'c': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // c
    text: RenderConfig(TexAtomType.ord, mainrm), // c
  ), // c
  'd': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // d
    text: RenderConfig(TexAtomType.ord, mainrm), // d
  ), // d
  'e': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // e
    text: RenderConfig(TexAtomType.ord, mainrm), // e
  ), // e
  'f': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // f
    text: RenderConfig(TexAtomType.ord, mainrm), // f
  ), // f
  'g': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // g
    text: RenderConfig(TexAtomType.ord, mainrm), // g
  ), // g
  'h': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // h
    text: RenderConfig(TexAtomType.ord, mainrm), // h
  ), // h
  'i': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // i
    text: RenderConfig(TexAtomType.ord, mainrm), // i
  ), // i
  'j': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // j
    text: RenderConfig(TexAtomType.ord, mainrm), // j
  ), // j
  'k': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // k
    text: RenderConfig(TexAtomType.ord, mainrm), // k
  ), // k
  'l': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // l
    text: RenderConfig(TexAtomType.ord, mainrm), // l
  ), // l
  'm': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // m
    text: RenderConfig(TexAtomType.ord, mainrm), // m
  ), // m
  'n': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // n
    text: RenderConfig(TexAtomType.ord, mainrm), // n
  ), // n
  'o': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // o
    text: RenderConfig(TexAtomType.ord, mainrm), // o
  ), // o
  'p': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // p
    text: RenderConfig(TexAtomType.ord, mainrm), // p
  ), // p
  'q': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // q
    text: RenderConfig(TexAtomType.ord, mainrm), // q
  ), // q
  'r': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // r
    text: RenderConfig(TexAtomType.ord, mainrm), // r
  ), // r
  's': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // s
    text: RenderConfig(TexAtomType.ord, mainrm), // s
  ), // s
  't': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // t
    text: RenderConfig(TexAtomType.ord, mainrm), // t
  ), // t
  'u': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // u
    text: RenderConfig(TexAtomType.ord, mainrm), // u
  ), // u
  'v': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // v
    text: RenderConfig(TexAtomType.ord, mainrm), // v
  ), // v
  'w': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // w
    text: RenderConfig(TexAtomType.ord, mainrm), // w
  ), // w
  'x': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // x
    text: RenderConfig(TexAtomType.ord, mainrm), // x
  ), // x
  'y': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // y
    text: RenderConfig(TexAtomType.ord, mainrm), // y
  ), // y
  'z': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // z
    text: RenderConfig(TexAtomType.ord, mainrm), // z
  ), // z
  '\u2102': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm, 'C'), // \u2102
    text: RenderConfig(TexAtomType.ord, amsrm, 'C'), // \u2102
  ), // ℂ
  '\u210D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm, 'H'), // \u210D
    text: RenderConfig(TexAtomType.ord, amsrm, 'H'), // \u210D
  ), // ℍ
  '\u2115': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm, 'N'), // \u2115
    text: RenderConfig(TexAtomType.ord, amsrm, 'N'), // \u2115
  ), // ℕ
  '\u2119': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm, 'P'), // \u2119
    text: RenderConfig(TexAtomType.ord, amsrm, 'P'), // \u2119
  ), // ℙ
  '\u211A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm, 'Q'), // \u211A
    text: RenderConfig(TexAtomType.ord, amsrm, 'Q'), // \u211A
  ), // ℚ
  '\u211D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm, 'R'), // \u211D
    text: RenderConfig(TexAtomType.ord, amsrm, 'R'), // \u211D
  ), // ℝ
  '\u2124': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm, 'Z'), // \u2124
    text: RenderConfig(TexAtomType.ord, amsrm, 'Z'), // \u2124
  ), // ℤ
  '\u210E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \u210E
    text: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \u210E
  ), // ℎ
  '\uD835\uDC00': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDC00
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDC00
  ), // 𝐀
  '\uD835\uDC34': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDC34
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDC34
  ), // 𝐴
  '\uD835\uDC68': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDC68
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDC68
  ), // 𝑨
  '\uD835\uDD04': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDD04
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDD04
  ), // 𝔄
  '\uD835\uDDA0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDDA0
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDDA0
  ), // 𝖠
  '\uD835\uDDD4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDDD4
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDDD4
  ), // 𝗔
  '\uD835\uDE08': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDE08
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDE08
  ), // 𝘈
  '\uD835\uDE70': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDE70
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDE70
  ), // 𝙰
  '\uD835\uDD38': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDD38
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDD38
  ), // 𝔸
  '\uD835\uDC9C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'A'), // \uD835\uDC9C
    text: RenderConfig(TexAtomType.ord, mainrm, 'A'), // \uD835\uDC9C
  ), // 𝒜
  '\uD835\uDC01': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDC01
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDC01
  ), // 𝐁
  '\uD835\uDC35': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDC35
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDC35
  ), // 𝐵
  '\uD835\uDC69': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDC69
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDC69
  ), // 𝑩
  '\uD835\uDD05': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDD05
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDD05
  ), // 𝔅
  '\uD835\uDDA1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDDA1
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDDA1
  ), // 𝖡
  '\uD835\uDDD5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDDD5
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDDD5
  ), // 𝗕
  '\uD835\uDE09': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDE09
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDE09
  ), // 𝘉
  '\uD835\uDE71': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDE71
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDE71
  ), // 𝙱
  '\uD835\uDD39': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDD39
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDD39
  ), // 𝔹
  '\uD835\uDC9D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'B'), // \uD835\uDC9D
    text: RenderConfig(TexAtomType.ord, mainrm, 'B'), // \uD835\uDC9D
  ), // 𝒝
  '\uD835\uDC02': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDC02
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDC02
  ), // 𝐂
  '\uD835\uDC36': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDC36
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDC36
  ), // 𝐶
  '\uD835\uDC6A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDC6A
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDC6A
  ), // 𝑪
  '\uD835\uDD06': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDD06
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDD06
  ), // 𝔆
  '\uD835\uDDA2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDDA2
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDDA2
  ), // 𝖢
  '\uD835\uDDD6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDDD6
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDDD6
  ), // 𝗖
  '\uD835\uDE0A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDE0A
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDE0A
  ), // 𝘊
  '\uD835\uDE72': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDE72
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDE72
  ), // 𝙲
  '\uD835\uDD3A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDD3A
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDD3A
  ), // 𝔺
  '\uD835\uDC9E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'C'), // \uD835\uDC9E
    text: RenderConfig(TexAtomType.ord, mainrm, 'C'), // \uD835\uDC9E
  ), // 𝒞
  '\uD835\uDC03': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDC03
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDC03
  ), // 𝐃
  '\uD835\uDC37': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDC37
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDC37
  ), // 𝐷
  '\uD835\uDC6B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDC6B
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDC6B
  ), // 𝑫
  '\uD835\uDD07': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDD07
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDD07
  ), // 𝔇
  '\uD835\uDDA3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDDA3
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDDA3
  ), // 𝖣
  '\uD835\uDDD7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDDD7
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDDD7
  ), // 𝗗
  '\uD835\uDE0B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDE0B
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDE0B
  ), // 𝘋
  '\uD835\uDE73': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDE73
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDE73
  ), // 𝙳
  '\uD835\uDD3B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDD3B
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDD3B
  ), // 𝔻
  '\uD835\uDC9F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'D'), // \uD835\uDC9F
    text: RenderConfig(TexAtomType.ord, mainrm, 'D'), // \uD835\uDC9F
  ), // 𝒟
  '\uD835\uDC04': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDC04
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDC04
  ), // 𝐄
  '\uD835\uDC38': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDC38
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDC38
  ), // 𝐸
  '\uD835\uDC6C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDC6C
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDC6C
  ), // 𝑬
  '\uD835\uDD08': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDD08
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDD08
  ), // 𝔈
  '\uD835\uDDA4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDDA4
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDDA4
  ), // 𝖤
  '\uD835\uDDD8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDDD8
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDDD8
  ), // 𝗘
  '\uD835\uDE0C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDE0C
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDE0C
  ), // 𝘌
  '\uD835\uDE74': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDE74
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDE74
  ), // 𝙴
  '\uD835\uDD3C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDD3C
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDD3C
  ), // 𝔼
  '\uD835\uDCA0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'E'), // \uD835\uDCA0
    text: RenderConfig(TexAtomType.ord, mainrm, 'E'), // \uD835\uDCA0
  ), // 𝒠
  '\uD835\uDC05': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDC05
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDC05
  ), // 𝐅
  '\uD835\uDC39': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDC39
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDC39
  ), // 𝐹
  '\uD835\uDC6D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDC6D
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDC6D
  ), // 𝑭
  '\uD835\uDD09': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDD09
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDD09
  ), // 𝔉
  '\uD835\uDDA5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDDA5
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDDA5
  ), // 𝖥
  '\uD835\uDDD9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDDD9
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDDD9
  ), // 𝗙
  '\uD835\uDE0D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDE0D
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDE0D
  ), // 𝘍
  '\uD835\uDE75': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDE75
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDE75
  ), // 𝙵
  '\uD835\uDD3D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDD3D
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDD3D
  ), // 𝔽
  '\uD835\uDCA1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'F'), // \uD835\uDCA1
    text: RenderConfig(TexAtomType.ord, mainrm, 'F'), // \uD835\uDCA1
  ), // 𝒡
  '\uD835\uDC06': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDC06
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDC06
  ), // 𝐆
  '\uD835\uDC3A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDC3A
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDC3A
  ), // 𝐺
  '\uD835\uDC6E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDC6E
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDC6E
  ), // 𝑮
  '\uD835\uDD0A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDD0A
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDD0A
  ), // 𝔊
  '\uD835\uDDA6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDDA6
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDDA6
  ), // 𝖦
  '\uD835\uDDDA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDDDA
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDDDA
  ), // 𝗚
  '\uD835\uDE0E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDE0E
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDE0E
  ), // 𝘎
  '\uD835\uDE76': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDE76
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDE76
  ), // 𝙶
  '\uD835\uDD3E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDD3E
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDD3E
  ), // 𝔾
  '\uD835\uDCA2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'G'), // \uD835\uDCA2
    text: RenderConfig(TexAtomType.ord, mainrm, 'G'), // \uD835\uDCA2
  ), // 𝒢
  '\uD835\uDC07': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDC07
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDC07
  ), // 𝐇
  '\uD835\uDC3B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDC3B
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDC3B
  ), // 𝐻
  '\uD835\uDC6F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDC6F
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDC6F
  ), // 𝑯
  '\uD835\uDD0B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDD0B
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDD0B
  ), // 𝔋
  '\uD835\uDDA7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDDA7
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDDA7
  ), // 𝖧
  '\uD835\uDDDB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDDDB
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDDDB
  ), // 𝗛
  '\uD835\uDE0F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDE0F
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDE0F
  ), // 𝘏
  '\uD835\uDE77': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDE77
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDE77
  ), // 𝙷
  '\uD835\uDD3F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDD3F
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDD3F
  ), // 𝔿
  '\uD835\uDCA3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'H'), // \uD835\uDCA3
    text: RenderConfig(TexAtomType.ord, mainrm, 'H'), // \uD835\uDCA3
  ), // 𝒣
  '\uD835\uDC08': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDC08
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDC08
  ), // 𝐈
  '\uD835\uDC3C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDC3C
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDC3C
  ), // 𝐼
  '\uD835\uDC70': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDC70
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDC70
  ), // 𝑰
  '\uD835\uDD0C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDD0C
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDD0C
  ), // 𝔌
  '\uD835\uDDA8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDDA8
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDDA8
  ), // 𝖨
  '\uD835\uDDDC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDDDC
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDDDC
  ), // 𝗜
  '\uD835\uDE10': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDE10
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDE10
  ), // 𝘐
  '\uD835\uDE78': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDE78
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDE78
  ), // 𝙸
  '\uD835\uDD40': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDD40
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDD40
  ), // 𝕀
  '\uD835\uDCA4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'I'), // \uD835\uDCA4
    text: RenderConfig(TexAtomType.ord, mainrm, 'I'), // \uD835\uDCA4
  ), // 𝒤
  '\uD835\uDC09': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDC09
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDC09
  ), // 𝐉
  '\uD835\uDC3D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDC3D
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDC3D
  ), // 𝐽
  '\uD835\uDC71': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDC71
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDC71
  ), // 𝑱
  '\uD835\uDD0D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDD0D
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDD0D
  ), // 𝔍
  '\uD835\uDDA9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDDA9
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDDA9
  ), // 𝖩
  '\uD835\uDDDD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDDDD
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDDDD
  ), // 𝗝
  '\uD835\uDE11': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDE11
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDE11
  ), // 𝘑
  '\uD835\uDE79': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDE79
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDE79
  ), // 𝙹
  '\uD835\uDD41': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDD41
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDD41
  ), // 𝕁
  '\uD835\uDCA5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'J'), // \uD835\uDCA5
    text: RenderConfig(TexAtomType.ord, mainrm, 'J'), // \uD835\uDCA5
  ), // 𝒥
  '\uD835\uDC0A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDC0A
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDC0A
  ), // 𝐊
  '\uD835\uDC3E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDC3E
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDC3E
  ), // 𝐾
  '\uD835\uDC72': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDC72
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDC72
  ), // 𝑲
  '\uD835\uDD0E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDD0E
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDD0E
  ), // 𝔎
  '\uD835\uDDAA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDDAA
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDDAA
  ), // 𝖪
  '\uD835\uDDDE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDDDE
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDDDE
  ), // 𝗞
  '\uD835\uDE12': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDE12
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDE12
  ), // 𝘒
  '\uD835\uDE7A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDE7A
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDE7A
  ), // 𝙺
  '\uD835\uDD42': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDD42
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDD42
  ), // 𝕂
  '\uD835\uDCA6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'K'), // \uD835\uDCA6
    text: RenderConfig(TexAtomType.ord, mainrm, 'K'), // \uD835\uDCA6
  ), // 𝒦
  '\uD835\uDC0B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDC0B
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDC0B
  ), // 𝐋
  '\uD835\uDC3F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDC3F
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDC3F
  ), // 𝐿
  '\uD835\uDC73': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDC73
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDC73
  ), // 𝑳
  '\uD835\uDD0F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDD0F
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDD0F
  ), // 𝔏
  '\uD835\uDDAB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDDAB
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDDAB
  ), // 𝖫
  '\uD835\uDDDF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDDDF
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDDDF
  ), // 𝗟
  '\uD835\uDE13': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDE13
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDE13
  ), // 𝘓
  '\uD835\uDE7B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDE7B
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDE7B
  ), // 𝙻
  '\uD835\uDD43': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDD43
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDD43
  ), // 𝕃
  '\uD835\uDCA7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'L'), // \uD835\uDCA7
    text: RenderConfig(TexAtomType.ord, mainrm, 'L'), // \uD835\uDCA7
  ), // 𝒧
  '\uD835\uDC0C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDC0C
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDC0C
  ), // 𝐌
  '\uD835\uDC40': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDC40
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDC40
  ), // 𝑀
  '\uD835\uDC74': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDC74
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDC74
  ), // 𝑴
  '\uD835\uDD10': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDD10
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDD10
  ), // 𝔐
  '\uD835\uDDAC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDDAC
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDDAC
  ), // 𝖬
  '\uD835\uDDE0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDDE0
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDDE0
  ), // 𝗠
  '\uD835\uDE14': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDE14
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDE14
  ), // 𝘔
  '\uD835\uDE7C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDE7C
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDE7C
  ), // 𝙼
  '\uD835\uDD44': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDD44
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDD44
  ), // 𝕄
  '\uD835\uDCA8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'M'), // \uD835\uDCA8
    text: RenderConfig(TexAtomType.ord, mainrm, 'M'), // \uD835\uDCA8
  ), // 𝒨
  '\uD835\uDC0D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDC0D
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDC0D
  ), // 𝐍
  '\uD835\uDC41': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDC41
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDC41
  ), // 𝑁
  '\uD835\uDC75': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDC75
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDC75
  ), // 𝑵
  '\uD835\uDD11': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDD11
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDD11
  ), // 𝔑
  '\uD835\uDDAD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDDAD
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDDAD
  ), // 𝖭
  '\uD835\uDDE1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDDE1
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDDE1
  ), // 𝗡
  '\uD835\uDE15': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDE15
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDE15
  ), // 𝘕
  '\uD835\uDE7D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDE7D
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDE7D
  ), // 𝙽
  '\uD835\uDD45': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDD45
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDD45
  ), // 𝕅
  '\uD835\uDCA9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'N'), // \uD835\uDCA9
    text: RenderConfig(TexAtomType.ord, mainrm, 'N'), // \uD835\uDCA9
  ), // 𝒩
  '\uD835\uDC0E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDC0E
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDC0E
  ), // 𝐎
  '\uD835\uDC42': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDC42
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDC42
  ), // 𝑂
  '\uD835\uDC76': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDC76
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDC76
  ), // 𝑶
  '\uD835\uDD12': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDD12
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDD12
  ), // 𝔒
  '\uD835\uDDAE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDDAE
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDDAE
  ), // 𝖮
  '\uD835\uDDE2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDDE2
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDDE2
  ), // 𝗢
  '\uD835\uDE16': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDE16
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDE16
  ), // 𝘖
  '\uD835\uDE7E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDE7E
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDE7E
  ), // 𝙾
  '\uD835\uDD46': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDD46
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDD46
  ), // 𝕆
  '\uD835\uDCAA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'O'), // \uD835\uDCAA
    text: RenderConfig(TexAtomType.ord, mainrm, 'O'), // \uD835\uDCAA
  ), // 𝒪
  '\uD835\uDC0F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDC0F
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDC0F
  ), // 𝐏
  '\uD835\uDC43': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDC43
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDC43
  ), // 𝑃
  '\uD835\uDC77': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDC77
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDC77
  ), // 𝑷
  '\uD835\uDD13': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDD13
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDD13
  ), // 𝔓
  '\uD835\uDDAF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDDAF
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDDAF
  ), // 𝖯
  '\uD835\uDDE3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDDE3
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDDE3
  ), // 𝗣
  '\uD835\uDE17': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDE17
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDE17
  ), // 𝘗
  '\uD835\uDE7F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDE7F
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDE7F
  ), // 𝙿
  '\uD835\uDD47': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDD47
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDD47
  ), // 𝕇
  '\uD835\uDCAB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'P'), // \uD835\uDCAB
    text: RenderConfig(TexAtomType.ord, mainrm, 'P'), // \uD835\uDCAB
  ), // 𝒫
  '\uD835\uDC10': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDC10
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDC10
  ), // 𝐐
  '\uD835\uDC44': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDC44
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDC44
  ), // 𝑄
  '\uD835\uDC78': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDC78
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDC78
  ), // 𝑸
  '\uD835\uDD14': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDD14
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDD14
  ), // 𝔔
  '\uD835\uDDB0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDDB0
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDDB0
  ), // 𝖰
  '\uD835\uDDE4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDDE4
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDDE4
  ), // 𝗤
  '\uD835\uDE18': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDE18
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDE18
  ), // 𝘘
  '\uD835\uDE80': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDE80
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDE80
  ), // 𝚀
  '\uD835\uDD48': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDD48
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDD48
  ), // 𝕈
  '\uD835\uDCAC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Q'), // \uD835\uDCAC
    text: RenderConfig(TexAtomType.ord, mainrm, 'Q'), // \uD835\uDCAC
  ), // 𝒬
  '\uD835\uDC11': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDC11
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDC11
  ), // 𝐑
  '\uD835\uDC45': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDC45
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDC45
  ), // 𝑅
  '\uD835\uDC79': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDC79
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDC79
  ), // 𝑹
  '\uD835\uDD15': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDD15
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDD15
  ), // 𝔕
  '\uD835\uDDB1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDDB1
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDDB1
  ), // 𝖱
  '\uD835\uDDE5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDDE5
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDDE5
  ), // 𝗥
  '\uD835\uDE19': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDE19
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDE19
  ), // 𝘙
  '\uD835\uDE81': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDE81
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDE81
  ), // 𝚁
  '\uD835\uDD49': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDD49
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDD49
  ), // 𝕉
  '\uD835\uDCAD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'R'), // \uD835\uDCAD
    text: RenderConfig(TexAtomType.ord, mainrm, 'R'), // \uD835\uDCAD
  ), // 𝒭
  '\uD835\uDC12': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDC12
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDC12
  ), // 𝐒
  '\uD835\uDC46': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDC46
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDC46
  ), // 𝑆
  '\uD835\uDC7A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDC7A
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDC7A
  ), // 𝑺
  '\uD835\uDD16': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDD16
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDD16
  ), // 𝔖
  '\uD835\uDDB2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDDB2
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDDB2
  ), // 𝖲
  '\uD835\uDDE6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDDE6
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDDE6
  ), // 𝗦
  '\uD835\uDE1A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDE1A
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDE1A
  ), // 𝘚
  '\uD835\uDE82': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDE82
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDE82
  ), // 𝚂
  '\uD835\uDD4A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDD4A
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDD4A
  ), // 𝕊
  '\uD835\uDCAE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'S'), // \uD835\uDCAE
    text: RenderConfig(TexAtomType.ord, mainrm, 'S'), // \uD835\uDCAE
  ), // 𝒮
  '\uD835\uDC13': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDC13
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDC13
  ), // 𝐓
  '\uD835\uDC47': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDC47
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDC47
  ), // 𝑇
  '\uD835\uDC7B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDC7B
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDC7B
  ), // 𝑻
  '\uD835\uDD17': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDD17
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDD17
  ), // 𝔗
  '\uD835\uDDB3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDDB3
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDDB3
  ), // 𝖳
  '\uD835\uDDE7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDDE7
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDDE7
  ), // 𝗧
  '\uD835\uDE1B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDE1B
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDE1B
  ), // 𝘛
  '\uD835\uDE83': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDE83
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDE83
  ), // 𝚃
  '\uD835\uDD4B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDD4B
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDD4B
  ), // 𝕋
  '\uD835\uDCAF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'T'), // \uD835\uDCAF
    text: RenderConfig(TexAtomType.ord, mainrm, 'T'), // \uD835\uDCAF
  ), // 𝒯
  '\uD835\uDC14': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDC14
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDC14
  ), // 𝐔
  '\uD835\uDC48': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDC48
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDC48
  ), // 𝑈
  '\uD835\uDC7C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDC7C
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDC7C
  ), // 𝑼
  '\uD835\uDD18': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDD18
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDD18
  ), // 𝔘
  '\uD835\uDDB4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDDB4
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDDB4
  ), // 𝖴
  '\uD835\uDDE8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDDE8
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDDE8
  ), // 𝗨
  '\uD835\uDE1C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDE1C
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDE1C
  ), // 𝘜
  '\uD835\uDE84': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDE84
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDE84
  ), // 𝚄
  '\uD835\uDD4C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDD4C
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDD4C
  ), // 𝕌
  '\uD835\uDCB0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'U'), // \uD835\uDCB0
    text: RenderConfig(TexAtomType.ord, mainrm, 'U'), // \uD835\uDCB0
  ), // 𝒰
  '\uD835\uDC15': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDC15
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDC15
  ), // 𝐕
  '\uD835\uDC49': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDC49
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDC49
  ), // 𝑉
  '\uD835\uDC7D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDC7D
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDC7D
  ), // 𝑽
  '\uD835\uDD19': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDD19
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDD19
  ), // 𝔙
  '\uD835\uDDB5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDDB5
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDDB5
  ), // 𝖵
  '\uD835\uDDE9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDDE9
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDDE9
  ), // 𝗩
  '\uD835\uDE1D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDE1D
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDE1D
  ), // 𝘝
  '\uD835\uDE85': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDE85
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDE85
  ), // 𝚅
  '\uD835\uDD4D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDD4D
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDD4D
  ), // 𝕍
  '\uD835\uDCB1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'V'), // \uD835\uDCB1
    text: RenderConfig(TexAtomType.ord, mainrm, 'V'), // \uD835\uDCB1
  ), // 𝒱
  '\uD835\uDC16': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDC16
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDC16
  ), // 𝐖
  '\uD835\uDC4A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDC4A
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDC4A
  ), // 𝑊
  '\uD835\uDC7E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDC7E
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDC7E
  ), // 𝑾
  '\uD835\uDD1A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDD1A
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDD1A
  ), // 𝔚
  '\uD835\uDDB6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDDB6
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDDB6
  ), // 𝖶
  '\uD835\uDDEA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDDEA
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDDEA
  ), // 𝗪
  '\uD835\uDE1E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDE1E
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDE1E
  ), // 𝘞
  '\uD835\uDE86': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDE86
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDE86
  ), // 𝚆
  '\uD835\uDD4E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDD4E
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDD4E
  ), // 𝕎
  '\uD835\uDCB2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'W'), // \uD835\uDCB2
    text: RenderConfig(TexAtomType.ord, mainrm, 'W'), // \uD835\uDCB2
  ), // 𝒲
  '\uD835\uDC17': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDC17
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDC17
  ), // 𝐗
  '\uD835\uDC4B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDC4B
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDC4B
  ), // 𝑋
  '\uD835\uDC7F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDC7F
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDC7F
  ), // 𝑿
  '\uD835\uDD1B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDD1B
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDD1B
  ), // 𝔛
  '\uD835\uDDB7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDDB7
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDDB7
  ), // 𝖷
  '\uD835\uDDEB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDDEB
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDDEB
  ), // 𝗫
  '\uD835\uDE1F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDE1F
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDE1F
  ), // 𝘟
  '\uD835\uDE87': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDE87
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDE87
  ), // 𝚇
  '\uD835\uDD4F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDD4F
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDD4F
  ), // 𝕏
  '\uD835\uDCB3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'X'), // \uD835\uDCB3
    text: RenderConfig(TexAtomType.ord, mainrm, 'X'), // \uD835\uDCB3
  ), // 𝒳
  '\uD835\uDC18': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDC18
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDC18
  ), // 𝐘
  '\uD835\uDC4C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDC4C
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDC4C
  ), // 𝑌
  '\uD835\uDC80': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDC80
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDC80
  ), // 𝒀
  '\uD835\uDD1C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDD1C
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDD1C
  ), // 𝔜
  '\uD835\uDDB8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDDB8
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDDB8
  ), // 𝖸
  '\uD835\uDDEC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDDEC
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDDEC
  ), // 𝗬
  '\uD835\uDE20': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDE20
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDE20
  ), // 𝘠
  '\uD835\uDE88': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDE88
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDE88
  ), // 𝚈
  '\uD835\uDD50': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDD50
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDD50
  ), // 𝕐
  '\uD835\uDCB4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Y'), // \uD835\uDCB4
    text: RenderConfig(TexAtomType.ord, mainrm, 'Y'), // \uD835\uDCB4
  ), // 𝒴
  '\uD835\uDC19': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDC19
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDC19
  ), // 𝐙
  '\uD835\uDC4D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDC4D
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDC4D
  ), // 𝑍
  '\uD835\uDC81': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDC81
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDC81
  ), // 𝒁
  '\uD835\uDD1D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDD1D
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDD1D
  ), // 𝔝
  '\uD835\uDDB9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDDB9
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDDB9
  ), // 𝖹
  '\uD835\uDDED': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDDED
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDDED
  ), // 𝗭
  '\uD835\uDE21': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDE21
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDE21
  ), // 𝘡
  '\uD835\uDE89': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDE89
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDE89
  ), // 𝚉
  '\uD835\uDD51': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDD51
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDD51
  ), // 𝕑
  '\uD835\uDCB5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'Z'), // \uD835\uDCB5
    text: RenderConfig(TexAtomType.ord, mainrm, 'Z'), // \uD835\uDCB5
  ), // 𝒵
  '\uD835\uDC1A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'a'), // \uD835\uDC1A
    text: RenderConfig(TexAtomType.ord, mainrm, 'a'), // \uD835\uDC1A
  ), // 𝐚
  '\uD835\uDC4E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'a'), // \uD835\uDC4E
    text: RenderConfig(TexAtomType.ord, mainrm, 'a'), // \uD835\uDC4E
  ), // 𝑎
  '\uD835\uDC82': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'a'), // \uD835\uDC82
    text: RenderConfig(TexAtomType.ord, mainrm, 'a'), // \uD835\uDC82
  ), // 𝒂
  '\uD835\uDD1E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'a'), // \uD835\uDD1E
    text: RenderConfig(TexAtomType.ord, mainrm, 'a'), // \uD835\uDD1E
  ), // 𝔞
  '\uD835\uDDBA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'a'), // \uD835\uDDBA
    text: RenderConfig(TexAtomType.ord, mainrm, 'a'), // \uD835\uDDBA
  ), // 𝖺
  '\uD835\uDDEE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'a'), // \uD835\uDDEE
    text: RenderConfig(TexAtomType.ord, mainrm, 'a'), // \uD835\uDDEE
  ), // 𝗮
  '\uD835\uDE22': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'a'), // \uD835\uDE22
    text: RenderConfig(TexAtomType.ord, mainrm, 'a'), // \uD835\uDE22
  ), // 𝘢
  '\uD835\uDE8A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'a'), // \uD835\uDE8A
    text: RenderConfig(TexAtomType.ord, mainrm, 'a'), // \uD835\uDE8A
  ), // 𝚊
  '\uD835\uDC1B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'b'), // \uD835\uDC1B
    text: RenderConfig(TexAtomType.ord, mainrm, 'b'), // \uD835\uDC1B
  ), // 𝐛
  '\uD835\uDC4F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'b'), // \uD835\uDC4F
    text: RenderConfig(TexAtomType.ord, mainrm, 'b'), // \uD835\uDC4F
  ), // 𝑏
  '\uD835\uDC83': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'b'), // \uD835\uDC83
    text: RenderConfig(TexAtomType.ord, mainrm, 'b'), // \uD835\uDC83
  ), // 𝒃
  '\uD835\uDD1F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'b'), // \uD835\uDD1F
    text: RenderConfig(TexAtomType.ord, mainrm, 'b'), // \uD835\uDD1F
  ), // 𝔟
  '\uD835\uDDBB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'b'), // \uD835\uDDBB
    text: RenderConfig(TexAtomType.ord, mainrm, 'b'), // \uD835\uDDBB
  ), // 𝖻
  '\uD835\uDDEF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'b'), // \uD835\uDDEF
    text: RenderConfig(TexAtomType.ord, mainrm, 'b'), // \uD835\uDDEF
  ), // 𝗯
  '\uD835\uDE23': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'b'), // \uD835\uDE23
    text: RenderConfig(TexAtomType.ord, mainrm, 'b'), // \uD835\uDE23
  ), // 𝘣
  '\uD835\uDE8B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'b'), // \uD835\uDE8B
    text: RenderConfig(TexAtomType.ord, mainrm, 'b'), // \uD835\uDE8B
  ), // 𝚋
  '\uD835\uDC1C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'c'), // \uD835\uDC1C
    text: RenderConfig(TexAtomType.ord, mainrm, 'c'), // \uD835\uDC1C
  ), // 𝐜
  '\uD835\uDC50': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'c'), // \uD835\uDC50
    text: RenderConfig(TexAtomType.ord, mainrm, 'c'), // \uD835\uDC50
  ), // 𝑐
  '\uD835\uDC84': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'c'), // \uD835\uDC84
    text: RenderConfig(TexAtomType.ord, mainrm, 'c'), // \uD835\uDC84
  ), // 𝒄
  '\uD835\uDD20': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'c'), // \uD835\uDD20
    text: RenderConfig(TexAtomType.ord, mainrm, 'c'), // \uD835\uDD20
  ), // 𝔠
  '\uD835\uDDBC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'c'), // \uD835\uDDBC
    text: RenderConfig(TexAtomType.ord, mainrm, 'c'), // \uD835\uDDBC
  ), // 𝖼
  '\uD835\uDDF0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'c'), // \uD835\uDDF0
    text: RenderConfig(TexAtomType.ord, mainrm, 'c'), // \uD835\uDDF0
  ), // 𝗰
  '\uD835\uDE24': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'c'), // \uD835\uDE24
    text: RenderConfig(TexAtomType.ord, mainrm, 'c'), // \uD835\uDE24
  ), // 𝘤
  '\uD835\uDE8C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'c'), // \uD835\uDE8C
    text: RenderConfig(TexAtomType.ord, mainrm, 'c'), // \uD835\uDE8C
  ), // 𝚌
  '\uD835\uDC1D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'd'), // \uD835\uDC1D
    text: RenderConfig(TexAtomType.ord, mainrm, 'd'), // \uD835\uDC1D
  ), // 𝐝
  '\uD835\uDC51': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'd'), // \uD835\uDC51
    text: RenderConfig(TexAtomType.ord, mainrm, 'd'), // \uD835\uDC51
  ), // 𝑑
  '\uD835\uDC85': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'd'), // \uD835\uDC85
    text: RenderConfig(TexAtomType.ord, mainrm, 'd'), // \uD835\uDC85
  ), // 𝒅
  '\uD835\uDD21': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'd'), // \uD835\uDD21
    text: RenderConfig(TexAtomType.ord, mainrm, 'd'), // \uD835\uDD21
  ), // 𝔡
  '\uD835\uDDBD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'd'), // \uD835\uDDBD
    text: RenderConfig(TexAtomType.ord, mainrm, 'd'), // \uD835\uDDBD
  ), // 𝖽
  '\uD835\uDDF1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'd'), // \uD835\uDDF1
    text: RenderConfig(TexAtomType.ord, mainrm, 'd'), // \uD835\uDDF1
  ), // 𝗱
  '\uD835\uDE25': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'd'), // \uD835\uDE25
    text: RenderConfig(TexAtomType.ord, mainrm, 'd'), // \uD835\uDE25
  ), // 𝘥
  '\uD835\uDE8D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'd'), // \uD835\uDE8D
    text: RenderConfig(TexAtomType.ord, mainrm, 'd'), // \uD835\uDE8D
  ), // 𝚍
  '\uD835\uDC1E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'e'), // \uD835\uDC1E
    text: RenderConfig(TexAtomType.ord, mainrm, 'e'), // \uD835\uDC1E
  ), // 𝐞
  '\uD835\uDC52': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'e'), // \uD835\uDC52
    text: RenderConfig(TexAtomType.ord, mainrm, 'e'), // \uD835\uDC52
  ), // 𝑒
  '\uD835\uDC86': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'e'), // \uD835\uDC86
    text: RenderConfig(TexAtomType.ord, mainrm, 'e'), // \uD835\uDC86
  ), // 𝒆
  '\uD835\uDD22': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'e'), // \uD835\uDD22
    text: RenderConfig(TexAtomType.ord, mainrm, 'e'), // \uD835\uDD22
  ), // 𝔢
  '\uD835\uDDBE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'e'), // \uD835\uDDBE
    text: RenderConfig(TexAtomType.ord, mainrm, 'e'), // \uD835\uDDBE
  ), // 𝖾
  '\uD835\uDDF2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'e'), // \uD835\uDDF2
    text: RenderConfig(TexAtomType.ord, mainrm, 'e'), // \uD835\uDDF2
  ), // 𝗲
  '\uD835\uDE26': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'e'), // \uD835\uDE26
    text: RenderConfig(TexAtomType.ord, mainrm, 'e'), // \uD835\uDE26
  ), // 𝘦
  '\uD835\uDE8E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'e'), // \uD835\uDE8E
    text: RenderConfig(TexAtomType.ord, mainrm, 'e'), // \uD835\uDE8E
  ), // 𝚎
  '\uD835\uDC1F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'f'), // \uD835\uDC1F
    text: RenderConfig(TexAtomType.ord, mainrm, 'f'), // \uD835\uDC1F
  ), // 𝐟
  '\uD835\uDC53': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'f'), // \uD835\uDC53
    text: RenderConfig(TexAtomType.ord, mainrm, 'f'), // \uD835\uDC53
  ), // 𝑓
  '\uD835\uDC87': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'f'), // \uD835\uDC87
    text: RenderConfig(TexAtomType.ord, mainrm, 'f'), // \uD835\uDC87
  ), // 𝒇
  '\uD835\uDD23': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'f'), // \uD835\uDD23
    text: RenderConfig(TexAtomType.ord, mainrm, 'f'), // \uD835\uDD23
  ), // 𝔣
  '\uD835\uDDBF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'f'), // \uD835\uDDBF
    text: RenderConfig(TexAtomType.ord, mainrm, 'f'), // \uD835\uDDBF
  ), // 𝖿
  '\uD835\uDDF3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'f'), // \uD835\uDDF3
    text: RenderConfig(TexAtomType.ord, mainrm, 'f'), // \uD835\uDDF3
  ), // 𝗳
  '\uD835\uDE27': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'f'), // \uD835\uDE27
    text: RenderConfig(TexAtomType.ord, mainrm, 'f'), // \uD835\uDE27
  ), // 𝘧
  '\uD835\uDE8F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'f'), // \uD835\uDE8F
    text: RenderConfig(TexAtomType.ord, mainrm, 'f'), // \uD835\uDE8F
  ), // 𝚏
  '\uD835\uDC20': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'g'), // \uD835\uDC20
    text: RenderConfig(TexAtomType.ord, mainrm, 'g'), // \uD835\uDC20
  ), // 𝐠
  '\uD835\uDC54': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'g'), // \uD835\uDC54
    text: RenderConfig(TexAtomType.ord, mainrm, 'g'), // \uD835\uDC54
  ), // 𝑔
  '\uD835\uDC88': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'g'), // \uD835\uDC88
    text: RenderConfig(TexAtomType.ord, mainrm, 'g'), // \uD835\uDC88
  ), // 𝒈
  '\uD835\uDD24': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'g'), // \uD835\uDD24
    text: RenderConfig(TexAtomType.ord, mainrm, 'g'), // \uD835\uDD24
  ), // 𝔤
  '\uD835\uDDC0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'g'), // \uD835\uDDC0
    text: RenderConfig(TexAtomType.ord, mainrm, 'g'), // \uD835\uDDC0
  ), // 𝗀
  '\uD835\uDDF4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'g'), // \uD835\uDDF4
    text: RenderConfig(TexAtomType.ord, mainrm, 'g'), // \uD835\uDDF4
  ), // 𝗴
  '\uD835\uDE28': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'g'), // \uD835\uDE28
    text: RenderConfig(TexAtomType.ord, mainrm, 'g'), // \uD835\uDE28
  ), // 𝘨
  '\uD835\uDE90': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'g'), // \uD835\uDE90
    text: RenderConfig(TexAtomType.ord, mainrm, 'g'), // \uD835\uDE90
  ), // 𝚐
  '\uD835\uDC21': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \uD835\uDC21
    text: RenderConfig(TexAtomType.ord, mainrm, 'h'), // \uD835\uDC21
  ), // 𝐡
  '\uD835\uDC55': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \uD835\uDC55
    text: RenderConfig(TexAtomType.ord, mainrm, 'h'), // \uD835\uDC55
  ), // 𝑕
  '\uD835\uDC89': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \uD835\uDC89
    text: RenderConfig(TexAtomType.ord, mainrm, 'h'), // \uD835\uDC89
  ), // 𝒉
  '\uD835\uDD25': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \uD835\uDD25
    text: RenderConfig(TexAtomType.ord, mainrm, 'h'), // \uD835\uDD25
  ), // 𝔥
  '\uD835\uDDC1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \uD835\uDDC1
    text: RenderConfig(TexAtomType.ord, mainrm, 'h'), // \uD835\uDDC1
  ), // 𝗁
  '\uD835\uDDF5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \uD835\uDDF5
    text: RenderConfig(TexAtomType.ord, mainrm, 'h'), // \uD835\uDDF5
  ), // 𝗵
  '\uD835\uDE29': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \uD835\uDE29
    text: RenderConfig(TexAtomType.ord, mainrm, 'h'), // \uD835\uDE29
  ), // 𝘩
  '\uD835\uDE91': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'h'), // \uD835\uDE91
    text: RenderConfig(TexAtomType.ord, mainrm, 'h'), // \uD835\uDE91
  ), // 𝚑
  '\uD835\uDC22': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'i'), // \uD835\uDC22
    text: RenderConfig(TexAtomType.ord, mainrm, 'i'), // \uD835\uDC22
  ), // 𝐢
  '\uD835\uDC56': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'i'), // \uD835\uDC56
    text: RenderConfig(TexAtomType.ord, mainrm, 'i'), // \uD835\uDC56
  ), // 𝑖
  '\uD835\uDC8A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'i'), // \uD835\uDC8A
    text: RenderConfig(TexAtomType.ord, mainrm, 'i'), // \uD835\uDC8A
  ), // 𝒊
  '\uD835\uDD26': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'i'), // \uD835\uDD26
    text: RenderConfig(TexAtomType.ord, mainrm, 'i'), // \uD835\uDD26
  ), // 𝔦
  '\uD835\uDDC2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'i'), // \uD835\uDDC2
    text: RenderConfig(TexAtomType.ord, mainrm, 'i'), // \uD835\uDDC2
  ), // 𝗂
  '\uD835\uDDF6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'i'), // \uD835\uDDF6
    text: RenderConfig(TexAtomType.ord, mainrm, 'i'), // \uD835\uDDF6
  ), // 𝗶
  '\uD835\uDE2A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'i'), // \uD835\uDE2A
    text: RenderConfig(TexAtomType.ord, mainrm, 'i'), // \uD835\uDE2A
  ), // 𝘪
  '\uD835\uDE92': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'i'), // \uD835\uDE92
    text: RenderConfig(TexAtomType.ord, mainrm, 'i'), // \uD835\uDE92
  ), // 𝚒
  '\uD835\uDC23': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'j'), // \uD835\uDC23
    text: RenderConfig(TexAtomType.ord, mainrm, 'j'), // \uD835\uDC23
  ), // 𝐣
  '\uD835\uDC57': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'j'), // \uD835\uDC57
    text: RenderConfig(TexAtomType.ord, mainrm, 'j'), // \uD835\uDC57
  ), // 𝑗
  '\uD835\uDC8B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'j'), // \uD835\uDC8B
    text: RenderConfig(TexAtomType.ord, mainrm, 'j'), // \uD835\uDC8B
  ), // 𝒋
  '\uD835\uDD27': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'j'), // \uD835\uDD27
    text: RenderConfig(TexAtomType.ord, mainrm, 'j'), // \uD835\uDD27
  ), // 𝔧
  '\uD835\uDDC3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'j'), // \uD835\uDDC3
    text: RenderConfig(TexAtomType.ord, mainrm, 'j'), // \uD835\uDDC3
  ), // 𝗃
  '\uD835\uDDF7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'j'), // \uD835\uDDF7
    text: RenderConfig(TexAtomType.ord, mainrm, 'j'), // \uD835\uDDF7
  ), // 𝗷
  '\uD835\uDE2B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'j'), // \uD835\uDE2B
    text: RenderConfig(TexAtomType.ord, mainrm, 'j'), // \uD835\uDE2B
  ), // 𝘫
  '\uD835\uDE93': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'j'), // \uD835\uDE93
    text: RenderConfig(TexAtomType.ord, mainrm, 'j'), // \uD835\uDE93
  ), // 𝚓
  '\uD835\uDC24': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'k'), // \uD835\uDC24
    text: RenderConfig(TexAtomType.ord, mainrm, 'k'), // \uD835\uDC24
  ), // 𝐤
  '\uD835\uDC58': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'k'), // \uD835\uDC58
    text: RenderConfig(TexAtomType.ord, mainrm, 'k'), // \uD835\uDC58
  ), // 𝑘
  '\uD835\uDC8C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'k'), // \uD835\uDC8C
    text: RenderConfig(TexAtomType.ord, mainrm, 'k'), // \uD835\uDC8C
  ), // 𝒌
  '\uD835\uDD28': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'k'), // \uD835\uDD28
    text: RenderConfig(TexAtomType.ord, mainrm, 'k'), // \uD835\uDD28
  ), // 𝔨
  '\uD835\uDDC4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'k'), // \uD835\uDDC4
    text: RenderConfig(TexAtomType.ord, mainrm, 'k'), // \uD835\uDDC4
  ), // 𝗄
  '\uD835\uDDF8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'k'), // \uD835\uDDF8
    text: RenderConfig(TexAtomType.ord, mainrm, 'k'), // \uD835\uDDF8
  ), // 𝗸
  '\uD835\uDE2C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'k'), // \uD835\uDE2C
    text: RenderConfig(TexAtomType.ord, mainrm, 'k'), // \uD835\uDE2C
  ), // 𝘬
  '\uD835\uDE94': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'k'), // \uD835\uDE94
    text: RenderConfig(TexAtomType.ord, mainrm, 'k'), // \uD835\uDE94
  ), // 𝚔
  '\uD835\uDC25': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'l'), // \uD835\uDC25
    text: RenderConfig(TexAtomType.ord, mainrm, 'l'), // \uD835\uDC25
  ), // 𝐥
  '\uD835\uDC59': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'l'), // \uD835\uDC59
    text: RenderConfig(TexAtomType.ord, mainrm, 'l'), // \uD835\uDC59
  ), // 𝑙
  '\uD835\uDC8D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'l'), // \uD835\uDC8D
    text: RenderConfig(TexAtomType.ord, mainrm, 'l'), // \uD835\uDC8D
  ), // 𝒍
  '\uD835\uDD29': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'l'), // \uD835\uDD29
    text: RenderConfig(TexAtomType.ord, mainrm, 'l'), // \uD835\uDD29
  ), // 𝔩
  '\uD835\uDDC5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'l'), // \uD835\uDDC5
    text: RenderConfig(TexAtomType.ord, mainrm, 'l'), // \uD835\uDDC5
  ), // 𝗅
  '\uD835\uDDF9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'l'), // \uD835\uDDF9
    text: RenderConfig(TexAtomType.ord, mainrm, 'l'), // \uD835\uDDF9
  ), // 𝗹
  '\uD835\uDE2D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'l'), // \uD835\uDE2D
    text: RenderConfig(TexAtomType.ord, mainrm, 'l'), // \uD835\uDE2D
  ), // 𝘭
  '\uD835\uDE95': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'l'), // \uD835\uDE95
    text: RenderConfig(TexAtomType.ord, mainrm, 'l'), // \uD835\uDE95
  ), // 𝚕
  '\uD835\uDC26': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'm'), // \uD835\uDC26
    text: RenderConfig(TexAtomType.ord, mainrm, 'm'), // \uD835\uDC26
  ), // 𝐦
  '\uD835\uDC5A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'm'), // \uD835\uDC5A
    text: RenderConfig(TexAtomType.ord, mainrm, 'm'), // \uD835\uDC5A
  ), // 𝑚
  '\uD835\uDC8E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'm'), // \uD835\uDC8E
    text: RenderConfig(TexAtomType.ord, mainrm, 'm'), // \uD835\uDC8E
  ), // 𝒎
  '\uD835\uDD2A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'm'), // \uD835\uDD2A
    text: RenderConfig(TexAtomType.ord, mainrm, 'm'), // \uD835\uDD2A
  ), // 𝔪
  '\uD835\uDDC6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'm'), // \uD835\uDDC6
    text: RenderConfig(TexAtomType.ord, mainrm, 'm'), // \uD835\uDDC6
  ), // 𝗆
  '\uD835\uDDFA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'm'), // \uD835\uDDFA
    text: RenderConfig(TexAtomType.ord, mainrm, 'm'), // \uD835\uDDFA
  ), // 𝗺
  '\uD835\uDE2E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'm'), // \uD835\uDE2E
    text: RenderConfig(TexAtomType.ord, mainrm, 'm'), // \uD835\uDE2E
  ), // 𝘮
  '\uD835\uDE96': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'm'), // \uD835\uDE96
    text: RenderConfig(TexAtomType.ord, mainrm, 'm'), // \uD835\uDE96
  ), // 𝚖
  '\uD835\uDC27': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'n'), // \uD835\uDC27
    text: RenderConfig(TexAtomType.ord, mainrm, 'n'), // \uD835\uDC27
  ), // 𝐧
  '\uD835\uDC5B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'n'), // \uD835\uDC5B
    text: RenderConfig(TexAtomType.ord, mainrm, 'n'), // \uD835\uDC5B
  ), // 𝑛
  '\uD835\uDC8F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'n'), // \uD835\uDC8F
    text: RenderConfig(TexAtomType.ord, mainrm, 'n'), // \uD835\uDC8F
  ), // 𝒏
  '\uD835\uDD2B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'n'), // \uD835\uDD2B
    text: RenderConfig(TexAtomType.ord, mainrm, 'n'), // \uD835\uDD2B
  ), // 𝔫
  '\uD835\uDDC7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'n'), // \uD835\uDDC7
    text: RenderConfig(TexAtomType.ord, mainrm, 'n'), // \uD835\uDDC7
  ), // 𝗇
  '\uD835\uDDFB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'n'), // \uD835\uDDFB
    text: RenderConfig(TexAtomType.ord, mainrm, 'n'), // \uD835\uDDFB
  ), // 𝗻
  '\uD835\uDE2F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'n'), // \uD835\uDE2F
    text: RenderConfig(TexAtomType.ord, mainrm, 'n'), // \uD835\uDE2F
  ), // 𝘯
  '\uD835\uDE97': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'n'), // \uD835\uDE97
    text: RenderConfig(TexAtomType.ord, mainrm, 'n'), // \uD835\uDE97
  ), // 𝚗
  '\uD835\uDC28': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'o'), // \uD835\uDC28
    text: RenderConfig(TexAtomType.ord, mainrm, 'o'), // \uD835\uDC28
  ), // 𝐨
  '\uD835\uDC5C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'o'), // \uD835\uDC5C
    text: RenderConfig(TexAtomType.ord, mainrm, 'o'), // \uD835\uDC5C
  ), // 𝑜
  '\uD835\uDC90': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'o'), // \uD835\uDC90
    text: RenderConfig(TexAtomType.ord, mainrm, 'o'), // \uD835\uDC90
  ), // 𝒐
  '\uD835\uDD2C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'o'), // \uD835\uDD2C
    text: RenderConfig(TexAtomType.ord, mainrm, 'o'), // \uD835\uDD2C
  ), // 𝔬
  '\uD835\uDDC8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'o'), // \uD835\uDDC8
    text: RenderConfig(TexAtomType.ord, mainrm, 'o'), // \uD835\uDDC8
  ), // 𝗈
  '\uD835\uDDFC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'o'), // \uD835\uDDFC
    text: RenderConfig(TexAtomType.ord, mainrm, 'o'), // \uD835\uDDFC
  ), // 𝗼
  '\uD835\uDE30': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'o'), // \uD835\uDE30
    text: RenderConfig(TexAtomType.ord, mainrm, 'o'), // \uD835\uDE30
  ), // 𝘰
  '\uD835\uDE98': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'o'), // \uD835\uDE98
    text: RenderConfig(TexAtomType.ord, mainrm, 'o'), // \uD835\uDE98
  ), // 𝚘
  '\uD835\uDC29': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'p'), // \uD835\uDC29
    text: RenderConfig(TexAtomType.ord, mainrm, 'p'), // \uD835\uDC29
  ), // 𝐩
  '\uD835\uDC5D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'p'), // \uD835\uDC5D
    text: RenderConfig(TexAtomType.ord, mainrm, 'p'), // \uD835\uDC5D
  ), // 𝑝
  '\uD835\uDC91': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'p'), // \uD835\uDC91
    text: RenderConfig(TexAtomType.ord, mainrm, 'p'), // \uD835\uDC91
  ), // 𝒑
  '\uD835\uDD2D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'p'), // \uD835\uDD2D
    text: RenderConfig(TexAtomType.ord, mainrm, 'p'), // \uD835\uDD2D
  ), // 𝔭
  '\uD835\uDDC9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'p'), // \uD835\uDDC9
    text: RenderConfig(TexAtomType.ord, mainrm, 'p'), // \uD835\uDDC9
  ), // 𝗉
  '\uD835\uDDFD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'p'), // \uD835\uDDFD
    text: RenderConfig(TexAtomType.ord, mainrm, 'p'), // \uD835\uDDFD
  ), // 𝗽
  '\uD835\uDE31': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'p'), // \uD835\uDE31
    text: RenderConfig(TexAtomType.ord, mainrm, 'p'), // \uD835\uDE31
  ), // 𝘱
  '\uD835\uDE99': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'p'), // \uD835\uDE99
    text: RenderConfig(TexAtomType.ord, mainrm, 'p'), // \uD835\uDE99
  ), // 𝚙
  '\uD835\uDC2A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'q'), // \uD835\uDC2A
    text: RenderConfig(TexAtomType.ord, mainrm, 'q'), // \uD835\uDC2A
  ), // 𝐪
  '\uD835\uDC5E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'q'), // \uD835\uDC5E
    text: RenderConfig(TexAtomType.ord, mainrm, 'q'), // \uD835\uDC5E
  ), // 𝑞
  '\uD835\uDC92': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'q'), // \uD835\uDC92
    text: RenderConfig(TexAtomType.ord, mainrm, 'q'), // \uD835\uDC92
  ), // 𝒒
  '\uD835\uDD2E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'q'), // \uD835\uDD2E
    text: RenderConfig(TexAtomType.ord, mainrm, 'q'), // \uD835\uDD2E
  ), // 𝔮
  '\uD835\uDDCA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'q'), // \uD835\uDDCA
    text: RenderConfig(TexAtomType.ord, mainrm, 'q'), // \uD835\uDDCA
  ), // 𝗊
  '\uD835\uDDFE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'q'), // \uD835\uDDFE
    text: RenderConfig(TexAtomType.ord, mainrm, 'q'), // \uD835\uDDFE
  ), // 𝗾
  '\uD835\uDE32': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'q'), // \uD835\uDE32
    text: RenderConfig(TexAtomType.ord, mainrm, 'q'), // \uD835\uDE32
  ), // 𝘲
  '\uD835\uDE9A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'q'), // \uD835\uDE9A
    text: RenderConfig(TexAtomType.ord, mainrm, 'q'), // \uD835\uDE9A
  ), // 𝚚
  '\uD835\uDC2B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'r'), // \uD835\uDC2B
    text: RenderConfig(TexAtomType.ord, mainrm, 'r'), // \uD835\uDC2B
  ), // 𝐫
  '\uD835\uDC5F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'r'), // \uD835\uDC5F
    text: RenderConfig(TexAtomType.ord, mainrm, 'r'), // \uD835\uDC5F
  ), // 𝑟
  '\uD835\uDC93': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'r'), // \uD835\uDC93
    text: RenderConfig(TexAtomType.ord, mainrm, 'r'), // \uD835\uDC93
  ), // 𝒓
  '\uD835\uDD2F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'r'), // \uD835\uDD2F
    text: RenderConfig(TexAtomType.ord, mainrm, 'r'), // \uD835\uDD2F
  ), // 𝔯
  '\uD835\uDDCB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'r'), // \uD835\uDDCB
    text: RenderConfig(TexAtomType.ord, mainrm, 'r'), // \uD835\uDDCB
  ), // 𝗋
  '\uD835\uDDFF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'r'), // \uD835\uDDFF
    text: RenderConfig(TexAtomType.ord, mainrm, 'r'), // \uD835\uDDFF
  ), // 𝗿
  '\uD835\uDE33': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'r'), // \uD835\uDE33
    text: RenderConfig(TexAtomType.ord, mainrm, 'r'), // \uD835\uDE33
  ), // 𝘳
  '\uD835\uDE9B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'r'), // \uD835\uDE9B
    text: RenderConfig(TexAtomType.ord, mainrm, 'r'), // \uD835\uDE9B
  ), // 𝚛
  '\uD835\uDC2C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 's'), // \uD835\uDC2C
    text: RenderConfig(TexAtomType.ord, mainrm, 's'), // \uD835\uDC2C
  ), // 𝐬
  '\uD835\uDC60': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 's'), // \uD835\uDC60
    text: RenderConfig(TexAtomType.ord, mainrm, 's'), // \uD835\uDC60
  ), // 𝑠
  '\uD835\uDC94': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 's'), // \uD835\uDC94
    text: RenderConfig(TexAtomType.ord, mainrm, 's'), // \uD835\uDC94
  ), // 𝒔
  '\uD835\uDD30': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 's'), // \uD835\uDD30
    text: RenderConfig(TexAtomType.ord, mainrm, 's'), // \uD835\uDD30
  ), // 𝔰
  '\uD835\uDDCC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 's'), // \uD835\uDDCC
    text: RenderConfig(TexAtomType.ord, mainrm, 's'), // \uD835\uDDCC
  ), // 𝗌
  '\uD835\uDE00': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 's'), // \uD835\uDE00
    text: RenderConfig(TexAtomType.ord, mainrm, 's'), // \uD835\uDE00
  ), // 𝘀
  '\uD835\uDE34': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 's'), // \uD835\uDE34
    text: RenderConfig(TexAtomType.ord, mainrm, 's'), // \uD835\uDE34
  ), // 𝘴
  '\uD835\uDE9C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 's'), // \uD835\uDE9C
    text: RenderConfig(TexAtomType.ord, mainrm, 's'), // \uD835\uDE9C
  ), // 𝚜
  '\uD835\uDC2D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 't'), // \uD835\uDC2D
    text: RenderConfig(TexAtomType.ord, mainrm, 't'), // \uD835\uDC2D
  ), // 𝐭
  '\uD835\uDC61': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 't'), // \uD835\uDC61
    text: RenderConfig(TexAtomType.ord, mainrm, 't'), // \uD835\uDC61
  ), // 𝑡
  '\uD835\uDC95': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 't'), // \uD835\uDC95
    text: RenderConfig(TexAtomType.ord, mainrm, 't'), // \uD835\uDC95
  ), // 𝒕
  '\uD835\uDD31': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 't'), // \uD835\uDD31
    text: RenderConfig(TexAtomType.ord, mainrm, 't'), // \uD835\uDD31
  ), // 𝔱
  '\uD835\uDDCD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 't'), // \uD835\uDDCD
    text: RenderConfig(TexAtomType.ord, mainrm, 't'), // \uD835\uDDCD
  ), // 𝗍
  '\uD835\uDE01': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 't'), // \uD835\uDE01
    text: RenderConfig(TexAtomType.ord, mainrm, 't'), // \uD835\uDE01
  ), // 𝘁
  '\uD835\uDE35': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 't'), // \uD835\uDE35
    text: RenderConfig(TexAtomType.ord, mainrm, 't'), // \uD835\uDE35
  ), // 𝘵
  '\uD835\uDE9D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 't'), // \uD835\uDE9D
    text: RenderConfig(TexAtomType.ord, mainrm, 't'), // \uD835\uDE9D
  ), // 𝚝
  '\uD835\uDC2E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'u'), // \uD835\uDC2E
    text: RenderConfig(TexAtomType.ord, mainrm, 'u'), // \uD835\uDC2E
  ), // 𝐮
  '\uD835\uDC62': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'u'), // \uD835\uDC62
    text: RenderConfig(TexAtomType.ord, mainrm, 'u'), // \uD835\uDC62
  ), // 𝑢
  '\uD835\uDC96': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'u'), // \uD835\uDC96
    text: RenderConfig(TexAtomType.ord, mainrm, 'u'), // \uD835\uDC96
  ), // 𝒖
  '\uD835\uDD32': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'u'), // \uD835\uDD32
    text: RenderConfig(TexAtomType.ord, mainrm, 'u'), // \uD835\uDD32
  ), // 𝔲
  '\uD835\uDDCE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'u'), // \uD835\uDDCE
    text: RenderConfig(TexAtomType.ord, mainrm, 'u'), // \uD835\uDDCE
  ), // 𝗎
  '\uD835\uDE02': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'u'), // \uD835\uDE02
    text: RenderConfig(TexAtomType.ord, mainrm, 'u'), // \uD835\uDE02
  ), // 𝘂
  '\uD835\uDE36': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'u'), // \uD835\uDE36
    text: RenderConfig(TexAtomType.ord, mainrm, 'u'), // \uD835\uDE36
  ), // 𝘶
  '\uD835\uDE9E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'u'), // \uD835\uDE9E
    text: RenderConfig(TexAtomType.ord, mainrm, 'u'), // \uD835\uDE9E
  ), // 𝚞
  '\uD835\uDC2F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'v'), // \uD835\uDC2F
    text: RenderConfig(TexAtomType.ord, mainrm, 'v'), // \uD835\uDC2F
  ), // 𝐯
  '\uD835\uDC63': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'v'), // \uD835\uDC63
    text: RenderConfig(TexAtomType.ord, mainrm, 'v'), // \uD835\uDC63
  ), // 𝑣
  '\uD835\uDC97': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'v'), // \uD835\uDC97
    text: RenderConfig(TexAtomType.ord, mainrm, 'v'), // \uD835\uDC97
  ), // 𝒗
  '\uD835\uDD33': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'v'), // \uD835\uDD33
    text: RenderConfig(TexAtomType.ord, mainrm, 'v'), // \uD835\uDD33
  ), // 𝔳
  '\uD835\uDDCF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'v'), // \uD835\uDDCF
    text: RenderConfig(TexAtomType.ord, mainrm, 'v'), // \uD835\uDDCF
  ), // 𝗏
  '\uD835\uDE03': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'v'), // \uD835\uDE03
    text: RenderConfig(TexAtomType.ord, mainrm, 'v'), // \uD835\uDE03
  ), // 𝘃
  '\uD835\uDE37': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'v'), // \uD835\uDE37
    text: RenderConfig(TexAtomType.ord, mainrm, 'v'), // \uD835\uDE37
  ), // 𝘷
  '\uD835\uDE9F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'v'), // \uD835\uDE9F
    text: RenderConfig(TexAtomType.ord, mainrm, 'v'), // \uD835\uDE9F
  ), // 𝚟
  '\uD835\uDC30': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'w'), // \uD835\uDC30
    text: RenderConfig(TexAtomType.ord, mainrm, 'w'), // \uD835\uDC30
  ), // 𝐰
  '\uD835\uDC64': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'w'), // \uD835\uDC64
    text: RenderConfig(TexAtomType.ord, mainrm, 'w'), // \uD835\uDC64
  ), // 𝑤
  '\uD835\uDC98': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'w'), // \uD835\uDC98
    text: RenderConfig(TexAtomType.ord, mainrm, 'w'), // \uD835\uDC98
  ), // 𝒘
  '\uD835\uDD34': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'w'), // \uD835\uDD34
    text: RenderConfig(TexAtomType.ord, mainrm, 'w'), // \uD835\uDD34
  ), // 𝔴
  '\uD835\uDDD0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'w'), // \uD835\uDDD0
    text: RenderConfig(TexAtomType.ord, mainrm, 'w'), // \uD835\uDDD0
  ), // 𝗐
  '\uD835\uDE04': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'w'), // \uD835\uDE04
    text: RenderConfig(TexAtomType.ord, mainrm, 'w'), // \uD835\uDE04
  ), // 𝘄
  '\uD835\uDE38': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'w'), // \uD835\uDE38
    text: RenderConfig(TexAtomType.ord, mainrm, 'w'), // \uD835\uDE38
  ), // 𝘸
  '\uD835\uDEA0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'w'), // \uD835\uDEA0
    text: RenderConfig(TexAtomType.ord, mainrm, 'w'), // \uD835\uDEA0
  ), // 𝚠
  '\uD835\uDC31': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'x'), // \uD835\uDC31
    text: RenderConfig(TexAtomType.ord, mainrm, 'x'), // \uD835\uDC31
  ), // 𝐱
  '\uD835\uDC65': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'x'), // \uD835\uDC65
    text: RenderConfig(TexAtomType.ord, mainrm, 'x'), // \uD835\uDC65
  ), // 𝑥
  '\uD835\uDC99': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'x'), // \uD835\uDC99
    text: RenderConfig(TexAtomType.ord, mainrm, 'x'), // \uD835\uDC99
  ), // 𝒙
  '\uD835\uDD35': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'x'), // \uD835\uDD35
    text: RenderConfig(TexAtomType.ord, mainrm, 'x'), // \uD835\uDD35
  ), // 𝔵
  '\uD835\uDDD1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'x'), // \uD835\uDDD1
    text: RenderConfig(TexAtomType.ord, mainrm, 'x'), // \uD835\uDDD1
  ), // 𝗑
  '\uD835\uDE05': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'x'), // \uD835\uDE05
    text: RenderConfig(TexAtomType.ord, mainrm, 'x'), // \uD835\uDE05
  ), // 𝘅
  '\uD835\uDE39': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'x'), // \uD835\uDE39
    text: RenderConfig(TexAtomType.ord, mainrm, 'x'), // \uD835\uDE39
  ), // 𝘹
  '\uD835\uDEA1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'x'), // \uD835\uDEA1
    text: RenderConfig(TexAtomType.ord, mainrm, 'x'), // \uD835\uDEA1
  ), // 𝚡
  '\uD835\uDC32': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'y'), // \uD835\uDC32
    text: RenderConfig(TexAtomType.ord, mainrm, 'y'), // \uD835\uDC32
  ), // 𝐲
  '\uD835\uDC66': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'y'), // \uD835\uDC66
    text: RenderConfig(TexAtomType.ord, mainrm, 'y'), // \uD835\uDC66
  ), // 𝑦
  '\uD835\uDC9A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'y'), // \uD835\uDC9A
    text: RenderConfig(TexAtomType.ord, mainrm, 'y'), // \uD835\uDC9A
  ), // 𝒚
  '\uD835\uDD36': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'y'), // \uD835\uDD36
    text: RenderConfig(TexAtomType.ord, mainrm, 'y'), // \uD835\uDD36
  ), // 𝔶
  '\uD835\uDDD2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'y'), // \uD835\uDDD2
    text: RenderConfig(TexAtomType.ord, mainrm, 'y'), // \uD835\uDDD2
  ), // 𝗒
  '\uD835\uDE06': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'y'), // \uD835\uDE06
    text: RenderConfig(TexAtomType.ord, mainrm, 'y'), // \uD835\uDE06
  ), // 𝘆
  '\uD835\uDE3A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'y'), // \uD835\uDE3A
    text: RenderConfig(TexAtomType.ord, mainrm, 'y'), // \uD835\uDE3A
  ), // 𝘺
  '\uD835\uDEA2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'y'), // \uD835\uDEA2
    text: RenderConfig(TexAtomType.ord, mainrm, 'y'), // \uD835\uDEA2
  ), // 𝚢
  '\uD835\uDC33': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'z'), // \uD835\uDC33
    text: RenderConfig(TexAtomType.ord, mainrm, 'z'), // \uD835\uDC33
  ), // 𝐳
  '\uD835\uDC67': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'z'), // \uD835\uDC67
    text: RenderConfig(TexAtomType.ord, mainrm, 'z'), // \uD835\uDC67
  ), // 𝑧
  '\uD835\uDC9B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'z'), // \uD835\uDC9B
    text: RenderConfig(TexAtomType.ord, mainrm, 'z'), // \uD835\uDC9B
  ), // 𝒛
  '\uD835\uDD37': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'z'), // \uD835\uDD37
    text: RenderConfig(TexAtomType.ord, mainrm, 'z'), // \uD835\uDD37
  ), // 𝔷
  '\uD835\uDDD3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'z'), // \uD835\uDDD3
    text: RenderConfig(TexAtomType.ord, mainrm, 'z'), // \uD835\uDDD3
  ), // 𝗓
  '\uD835\uDE07': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'z'), // \uD835\uDE07
    text: RenderConfig(TexAtomType.ord, mainrm, 'z'), // \uD835\uDE07
  ), // 𝘇
  '\uD835\uDE3B': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'z'), // \uD835\uDE3B
    text: RenderConfig(TexAtomType.ord, mainrm, 'z'), // \uD835\uDE3B
  ), // 𝘻
  '\uD835\uDEA3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'z'), // \uD835\uDEA3
    text: RenderConfig(TexAtomType.ord, mainrm, 'z'), // \uD835\uDEA3
  ), // 𝚣
  '\uD835\uDD5C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, 'k'), // \uD835\uDD5C
    text: RenderConfig(TexAtomType.ord, mainrm, 'k'), // \uD835\uDD5C
  ), // 𝕜
  '\uD835\uDFCE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '0'), // \uD835\uDFCE
    text: RenderConfig(TexAtomType.ord, mainrm, '0'), // \uD835\uDFCE
  ), // 𝟎
  '\uD835\uDFE2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '0'), // \uD835\uDFE2
    text: RenderConfig(TexAtomType.ord, mainrm, '0'), // \uD835\uDFE2
  ), // 𝟢
  '\uD835\uDFEC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '0'), // \uD835\uDFEC
    text: RenderConfig(TexAtomType.ord, mainrm, '0'), // \uD835\uDFEC
  ), // 𝟬
  '\uD835\uDFF6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '0'), // \uD835\uDFF6
    text: RenderConfig(TexAtomType.ord, mainrm, '0'), // \uD835\uDFF6
  ), // 𝟶
  '\uD835\uDFCF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '1'), // \uD835\uDFCF
    text: RenderConfig(TexAtomType.ord, mainrm, '1'), // \uD835\uDFCF
  ), // 𝟏
  '\uD835\uDFE3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '1'), // \uD835\uDFE3
    text: RenderConfig(TexAtomType.ord, mainrm, '1'), // \uD835\uDFE3
  ), // 𝟣
  '\uD835\uDFED': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '1'), // \uD835\uDFED
    text: RenderConfig(TexAtomType.ord, mainrm, '1'), // \uD835\uDFED
  ), // 𝟭
  '\uD835\uDFF7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '1'), // \uD835\uDFF7
    text: RenderConfig(TexAtomType.ord, mainrm, '1'), // \uD835\uDFF7
  ), // 𝟷
  '\uD835\uDFD0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '2'), // \uD835\uDFD0
    text: RenderConfig(TexAtomType.ord, mainrm, '2'), // \uD835\uDFD0
  ), // 𝟐
  '\uD835\uDFE4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '2'), // \uD835\uDFE4
    text: RenderConfig(TexAtomType.ord, mainrm, '2'), // \uD835\uDFE4
  ), // 𝟤
  '\uD835\uDFEE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '2'), // \uD835\uDFEE
    text: RenderConfig(TexAtomType.ord, mainrm, '2'), // \uD835\uDFEE
  ), // 𝟮
  '\uD835\uDFF8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '2'), // \uD835\uDFF8
    text: RenderConfig(TexAtomType.ord, mainrm, '2'), // \uD835\uDFF8
  ), // 𝟸
  '\uD835\uDFD1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '3'), // \uD835\uDFD1
    text: RenderConfig(TexAtomType.ord, mainrm, '3'), // \uD835\uDFD1
  ), // 𝟑
  '\uD835\uDFE5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '3'), // \uD835\uDFE5
    text: RenderConfig(TexAtomType.ord, mainrm, '3'), // \uD835\uDFE5
  ), // 𝟥
  '\uD835\uDFEF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '3'), // \uD835\uDFEF
    text: RenderConfig(TexAtomType.ord, mainrm, '3'), // \uD835\uDFEF
  ), // 𝟯
  '\uD835\uDFF9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '3'), // \uD835\uDFF9
    text: RenderConfig(TexAtomType.ord, mainrm, '3'), // \uD835\uDFF9
  ), // 𝟹
  '\uD835\uDFD2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '4'), // \uD835\uDFD2
    text: RenderConfig(TexAtomType.ord, mainrm, '4'), // \uD835\uDFD2
  ), // 𝟒
  '\uD835\uDFE6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '4'), // \uD835\uDFE6
    text: RenderConfig(TexAtomType.ord, mainrm, '4'), // \uD835\uDFE6
  ), // 𝟦
  '\uD835\uDFF0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '4'), // \uD835\uDFF0
    text: RenderConfig(TexAtomType.ord, mainrm, '4'), // \uD835\uDFF0
  ), // 𝟰
  '\uD835\uDFFA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '4'), // \uD835\uDFFA
    text: RenderConfig(TexAtomType.ord, mainrm, '4'), // \uD835\uDFFA
  ), // 𝟺
  '\uD835\uDFD3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '5'), // \uD835\uDFD3
    text: RenderConfig(TexAtomType.ord, mainrm, '5'), // \uD835\uDFD3
  ), // 𝟓
  '\uD835\uDFE7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '5'), // \uD835\uDFE7
    text: RenderConfig(TexAtomType.ord, mainrm, '5'), // \uD835\uDFE7
  ), // 𝟧
  '\uD835\uDFF1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '5'), // \uD835\uDFF1
    text: RenderConfig(TexAtomType.ord, mainrm, '5'), // \uD835\uDFF1
  ), // 𝟱
  '\uD835\uDFFB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '5'), // \uD835\uDFFB
    text: RenderConfig(TexAtomType.ord, mainrm, '5'), // \uD835\uDFFB
  ), // 𝟻
  '\uD835\uDFD4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '6'), // \uD835\uDFD4
    text: RenderConfig(TexAtomType.ord, mainrm, '6'), // \uD835\uDFD4
  ), // 𝟔
  '\uD835\uDFE8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '6'), // \uD835\uDFE8
    text: RenderConfig(TexAtomType.ord, mainrm, '6'), // \uD835\uDFE8
  ), // 𝟨
  '\uD835\uDFF2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '6'), // \uD835\uDFF2
    text: RenderConfig(TexAtomType.ord, mainrm, '6'), // \uD835\uDFF2
  ), // 𝟲
  '\uD835\uDFFC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '6'), // \uD835\uDFFC
    text: RenderConfig(TexAtomType.ord, mainrm, '6'), // \uD835\uDFFC
  ), // 𝟼
  '\uD835\uDFD5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '7'), // \uD835\uDFD5
    text: RenderConfig(TexAtomType.ord, mainrm, '7'), // \uD835\uDFD5
  ), // 𝟕
  '\uD835\uDFE9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '7'), // \uD835\uDFE9
    text: RenderConfig(TexAtomType.ord, mainrm, '7'), // \uD835\uDFE9
  ), // 𝟩
  '\uD835\uDFF3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '7'), // \uD835\uDFF3
    text: RenderConfig(TexAtomType.ord, mainrm, '7'), // \uD835\uDFF3
  ), // 𝟳
  '\uD835\uDFFD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '7'), // \uD835\uDFFD
    text: RenderConfig(TexAtomType.ord, mainrm, '7'), // \uD835\uDFFD
  ), // 𝟽
  '\uD835\uDFD6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '8'), // \uD835\uDFD6
    text: RenderConfig(TexAtomType.ord, mainrm, '8'), // \uD835\uDFD6
  ), // 𝟖
  '\uD835\uDFEA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '8'), // \uD835\uDFEA
    text: RenderConfig(TexAtomType.ord, mainrm, '8'), // \uD835\uDFEA
  ), // 𝟪
  '\uD835\uDFF4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '8'), // \uD835\uDFF4
    text: RenderConfig(TexAtomType.ord, mainrm, '8'), // \uD835\uDFF4
  ), // 𝟴
  '\uD835\uDFFE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '8'), // \uD835\uDFFE
    text: RenderConfig(TexAtomType.ord, mainrm, '8'), // \uD835\uDFFE
  ), // 𝟾
  '\uD835\uDFD7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '9'), // \uD835\uDFD7
    text: RenderConfig(TexAtomType.ord, mainrm, '9'), // \uD835\uDFD7
  ), // 𝟗
  '\uD835\uDFEB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '9'), // \uD835\uDFEB
    text: RenderConfig(TexAtomType.ord, mainrm, '9'), // \uD835\uDFEB
  ), // 𝟫
  '\uD835\uDFF5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '9'), // \uD835\uDFF5
    text: RenderConfig(TexAtomType.ord, mainrm, '9'), // \uD835\uDFF5
  ), // 𝟵
  '\uD835\uDFFF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault, '9'), // \uD835\uDFFF
    text: RenderConfig(TexAtomType.ord, mainrm, '9'), // \uD835\uDFFF
  ), // 𝟿
  '\u00C7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u00C7
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00C7
  ), // Ç
  '\u00D0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u00D0
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00D0
  ), // Ð
  '\u00DE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u00DE
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00DE
  ), // Þ
  '\u00E7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u00E7
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00E7
  ), // ç
  '\u00FE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mathdefault), // \u00FE
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00FE
  ), // þ
  '\u00A0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.spacing, mainrm), // \u00A0 \  ~ \space \nobreakspace
    text: RenderConfig(TexAtomType.spacing, mainrm), // \u00A0 \  ~ \space \nobreakspace
  ), //
  ' ': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.spacing, mainrm, '\u00A0'), //
    text: RenderConfig(TexAtomType.spacing, mainrm, '\u00A0'), //
  ), //
  '\u00A7': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00A7 \S
  ), // §
  '\u00B6': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00B6 \P
  ), // ¶
  '\u00DF': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00DF \ss
  ), // ß
  '\u00E6': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00E6 \ae
  ), // æ
  '\u0153': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u0153 \oe
  ), // œ
  '\u00F8': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00F8 \o
  ), // ø
  '\u00C6': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00C6 \AE
  ), // Æ
  '\u0152': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u0152 \OE
  ), // Œ
  '\u00D8': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u00D8 \O
  ), // Ø
  '\'': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm, '\u2019'), // \'
  ), // '
  '\u2013': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u2013 -- \textendash
  ), // –
  '\u2014': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u2014 --- \textemdash
  ), // —
  '\u2018': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u2018 \textquoteleft
  ), // ‘
  '\u2019': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u2019 \textquoteright
  ), // ’
  '\u201C': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u201C `` \textquotedblleft
  ), // “
  '\u201D': SymbolRenderConfig(
    text: RenderConfig(TexAtomType.ord, mainrm), // \u201D \'\' \textquotedblright
  ), // ”
  '\u231C': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, amsrm, '\u250C'), // \u250C \@ulcorner
  ), // ⌜
  '\u231D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, amsrm, '\u2510'), // \u2510 \@urcorner
  ), // ⌝
  '\u231E': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, amsrm, '\u2514'), // \u2514 \@llcorner
  ), // ⌞
  '\u231F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, amsrm, '\u2518'), // \u2518 \@lrcorner
  ), // ⌟
  '\u22A5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \perp \bot
  ), // ⊥
  '\u2225': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm), // \parallel \shortparallel \lVert \rVert \| \Vert
    text: RenderConfig(TexAtomType.ord, mainrm), // \textbardbl
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm), // \shortparallel
    ),
  ), // ∥
  '#': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \#
    text: RenderConfig(TexAtomType.ord, mainrm), // \#
  ), // #
  '&': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \& \And
    text: RenderConfig(TexAtomType.ord, mainrm), // \&
  ), // &
  '\u2020': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \dag \dagger
    text: RenderConfig(TexAtomType.ord, mainrm), // \dag \textdagger
  ), // †
  '\u2021': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \ddag \ddagger
    text: RenderConfig(TexAtomType.ord, mainrm), // \ddag \textdaggerdbl
  ), // ‡
  '\u25EF': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \bigcirc
    text: RenderConfig(null, mainrm), // \textcircled
  ), // ◯
  '\u2219': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \bullet
  ), // ∙
  '\u2A3F': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \amalg
  ), // ⨿
  '\u22EA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \ntriangleleft
  ), // ⋪
  '\u22EB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \ntriangleright
  ), // ⋫
  '\u22B4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \unlhd \trianglelefteq
  ), // ⊴
  '\u22B5': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \unrhd \trianglerighteq
  ), // ⊵
  '\u25B3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \vartriangle \triangle \bigtriangleup
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm), // \vartriangle
    ),
  ), // △
  '\u25BD': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \triangledown \bigtriangledown
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.ord, amsrm), // \triangledown
    ),
  ), // ▽
  '\u25CA': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \lozenge \Diamond
  ), // ◊
  '\u24C8': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \circledS
  ), // Ⓢ
  '\u00AE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \circledR
    text: RenderConfig(TexAtomType.ord, amsrm), // \circledR
  ), // ®
  '\u2204': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \nexists
  ), // ∄
  '\u2127': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \mho
  ), // ℧
  '\u2035': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \backprime
  ), // ‵
  '\u25B2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \blacktriangle
  ), // ▲
  '\u25BC': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \blacktriangledown
  ), // ▼
  '\u25A0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \blacksquare
  ), // ■
  '\u29EB': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \blacklozenge
  ), // ⧫
  '\u2605': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \bigstar
  ), // ★
  '\u2571': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \diagup
  ), // ╱
  '\u2572': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \diagdown
  ), // ╲
  '\u25A1': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \square \Box
  ), // □
  '\u03F0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \varkappa
  ), // ϰ
  '\u22D6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \lessdot
  ), // ⋖
  '\u22B2': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \vartriangleleft \lhd
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.rel, amsrm), // \vartriangleleft
    ),
  ), // ⊲
  '\u22D7': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, amsrm), // \gtrdot
  ), // ⋗
  '\u22B3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \vartriangleright \rhd
  ), // ⊳
  '\u25C0': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \blacktriangleleft
  ), // ◀
  '\u220D': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \backepsilon
  ), // ∍
  '\u25B6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, amsrm), // \blacktriangleright
  ), // ▶
  '\u2216': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \smallsetminus \setminus
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.bin, amsrm), // \smallsetminus
    ),
  ), // ∖
  '\$': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \\$
    text: RenderConfig(TexAtomType.ord, mainrm), // \\$ \textdollar
  ), // $
  '%': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \%
    text: RenderConfig(TexAtomType.ord, mainrm), // \%
  ), // %
  '_': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \_
    text: RenderConfig(TexAtomType.ord, mainrm), // \_ \textunderscore
  ), // _
  '\u2032': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \prime
  ), // ′
  '\u22A4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \top
  ), // ⊤
  '\u2205': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \emptyset \varnothing
    variantForm: SymbolRenderConfig(
      math: RenderConfig(TexAtomType.ord, amsrm), // \varnothing
    ),
  ), // ∅
  '\u2218': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \circ
  ), // ∘
  '\u221A': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \surd
  ), // √
  '\u0338': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.rel, mainrm, '\uE020'), // \not
  ), // ̸
  '\u22C4': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \diamond
  ), // ⋄
  '\u22C6': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \star
  ), // ⋆
  '\u25C3': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \triangleleft
  ), // ◃
  '\u25B9': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.bin, mainrm), // \triangleright
  ), // ▹
  '{': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.open, mainrm), // \{ \lbrace
    text: RenderConfig(TexAtomType.ord, mainrm), // \{ \textbraceleft
  ), // {
  '}': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.close, mainrm), // \} \rbrace
    text: RenderConfig(TexAtomType.ord, mainrm), // \} \textbraceright
  ), // }
  '\\': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \backslash
    text: RenderConfig(TexAtomType.ord, mainrm), // \textbackslash
  ), // \
  '\u2210': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \coprod
  ), // ∐
  '\u22C1': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \bigvee
  ), // ⋁
  '\u22C0': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \bigwedge
  ), // ⋀
  '\u2A04': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \biguplus
  ), // ⨄
  '\u22C2': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \bigcap
  ), // ⋂
  '\u22C3': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \bigcup
  ), // ⋃
  '\u222B': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \int \intop \smallint
  ), // ∫
  '\u222C': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \iint
  ), // ∬
  '\u222D': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \iiint
  ), // ∭
  '\u220F': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \prod
  ), // ∏
  '\u2211': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \sum
  ), // ∑
  '\u2A02': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \bigotimes
  ), // ⨂
  '\u2A01': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \bigoplus
  ), // ⨁
  '\u2A00': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \bigodot
  ), // ⨀
  '\u222E': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \oint
  ), // ∮
  '\u222F': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \oiint
  ), // ∯
  '\u2230': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \oiiint
  ), // ∰
  '\u2A06': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \bigsqcup
  ), // ⨆
  '\u22EE': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, mainrm), // \varvdots
  ), // ⋮
  '\u02CA': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \acute
    text: RenderConfig(null, mainrm), // \\'
  ), // ˊ
  '\u02CB': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \grave
    text: RenderConfig(null, mainrm), // \`
  ), // ˋ
  '\u00A8': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \ddot
    text: RenderConfig(null, mainrm), // \"
  ), // ¨
  '~': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \tilde
    text: RenderConfig(TexAtomType.ord, mainrm), // \textasciitilde
  ), // ~
  '\u02C9': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \bar
    text: RenderConfig(null, mainrm), // \=
  ), // ˉ
  '\u02D8': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \breve
    text: RenderConfig(null, mainrm), // \u
  ), // ˘
  '\u02C7': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \check
    text: RenderConfig(null, mainrm), // \v
  ), // ˇ
  '^': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \hat
    text: RenderConfig(TexAtomType.ord, mainrm), // \textasciicircum
  ), // ^
  '\u20D7': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \vec
  ), // ⃗
  '\u02D9': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \dot
    text: RenderConfig(null, mainrm), // \.
  ), // ˙
  '\u02DA': SymbolRenderConfig(
    math: RenderConfig(null, mainrm), // \mathring
    text: RenderConfig(null, mainrm), // \r
  ), // ˚
  '\u2720': SymbolRenderConfig(
    math: RenderConfig(TexAtomType.ord, amsrm), // \maltese
    text: RenderConfig(TexAtomType.ord, amsrm), // \maltese
  ), // ✠
  '\u02C6': SymbolRenderConfig(
    text: RenderConfig(null, mainrm), // \^
  ), // ˆ
  '\u02DC': SymbolRenderConfig(
    text: RenderConfig(null, mainrm), // \~
  ), // ˜
  '\u02DD': SymbolRenderConfig(
    text: RenderConfig(null, mainrm), // \H
  ), // ˝
};

const ligatures = {
  '–': '--',
  '—': '---',
  '“': '``',
  '”': "''",
};

// Composite symbols caused by the folding of \not
const negatedOperatorSymbols = {
  '\u219A': ['\u0338', '\u2190'],
  '\u219B': ['\u0338', '\u2192'],
  '\u21AE': ['\u0338', '\u2194'],
  '\u21CD': ['\u0338', '\u21D0'],
  '\u21CF': ['\u0338', '\u21D2'],
  '\u21CE': ['\u0338', '\u21D4'],
  '\u2209': ['\u0338', '\u2208'],
  '\u220C': ['\u0338', '\u220B'],
  '\u2224': ['\u0338', '\u2223'],
  '\u2226': ['\u0338', '\u2225'],
  '\u2241': ['\u0338', '\u223C'],
  // '\u2241': ['\u0338', '\u007E'],
  '\u2244': ['\u0338', '\u2243'],
  '\u2247': ['\u0338', '\u2245'],
  '\u2249': ['\u0338', '\u2248'],
  '\u226D': ['\u0338', '\u224D'],
  '\u2260': ['\u0338', '\u003D'],
  '\u2262': ['\u0338', '\u2261'],
  '\u226E': ['\u0338', '\u003C'],
  '\u226F': ['\u0338', '\u003E'],
  '\u2270': ['\u0338', '\u2264'],
  '\u2271': ['\u0338', '\u2265'],
  '\u2274': ['\u0338', '\u2272'],
  '\u2275': ['\u0338', '\u2273'],
  '\u2278': ['\u0338', '\u2276'],
  '\u2279': ['\u0338', '\u2277'],
  '\u2280': ['\u0338', '\u227A'],
  '\u2281': ['\u0338', '\u227B'],
  '\u2284': ['\u0338', '\u2282'],
  '\u2285': ['\u0338', '\u2283'],
  '\u2288': ['\u0338', '\u2286'],
  '\u2289': ['\u0338', '\u2287'],
  '\u22AC': ['\u0338', '\u22A2'],
  '\u22AD': ['\u0338', '\u22A8'],
  '\u22AE': ['\u0338', '\u22A9'],
  '\u22AF': ['\u0338', '\u22AB'],
  '\u22E0': ['\u0338', '\u227C'],
  '\u22E1': ['\u0338', '\u227D'],
  '\u22E2': ['\u0338', '\u2291'],
  '\u22E3': ['\u0338', '\u2292'],
  '\u22EA': ['\u0338', '\u22B2'],
  '\u22EB': ['\u0338', '\u22B3'],
  '\u22EC': ['\u0338', '\u22B4'],
  '\u22ED': ['\u0338', '\u22B5'],
  '\u2204': ['\u0338', '\u2203'],
};

// Compacted composite symbols

const compactedCompositeSymbols = {
  '\u2237': [':', ':'], //\dblcolon
  '\u2254': [':', '='], //\coloneqq
  '\u2255': ['=', ':'], //\eqqcolon
  '\u2239': ['-', ':'], //\eqcolon
  '\u27e6': ['[', '['], //\llbracket
  '\u27e7': [']', ']'], //\rrbracket
  '\u2983': ['{', '['], //\lBrace
  '\u2984': [']', '}'], //\rBrace
};

final compactedCompositeSymbolSpacings = {
  '\u2237': mu(-0.9), //\dblcolon
  '\u2254': mu(-1.2), //\coloneqq
  '\u2255': mu(-3.2), //\eqqcolon
  '\u2239': mu(-3.2), //\eqcolon
  '\u27e6': mu(-3.2), //\llbracket
  '\u27e7': mu(-3.2), //\rrbracket
  '\u2983': mu(-3.2), //\lBrace
  '\u2984': mu(-3.2), //\rBrace
};

final compactedCompositeSymbolTypes = {
  '\u2237': TexAtomType.rel, //\dblcolon
  '\u2254': TexAtomType.rel, //\coloneqq
  '\u2255': TexAtomType.rel, //\eqqcolon
  '\u2239': TexAtomType.rel, //\eqcolon
  '\u27e6': TexAtomType.open, //\llbracket
  '\u27e7': TexAtomType.close, //\rrbracket
  '\u2983': TexAtomType.open, //\lBrace
  '\u2984': TexAtomType.close, //\rBrace
};
// These symbols are too complex, we need to store their widget
// const complexSymbolRenderResult = {
//   // Stacked operator
//   '\u2258',
//   '\u2259',
//   '\u225A',
//   '\u225B',
//   '\u225D', //\defeq
//   '\u225E',
//   '\u225F',

//   // Circled char
//   '\u00A9',
// };

const decoratedEqualSymbols = {
  // '\u2258',
  '\u2259',
  '\u225A',
  '\u225B',
  '\u225D',
  '\u225E',
  '\u225F',
};

// ignore_for_file: prefer_single_quotes
const unicodeSymbols = {
  "\u00e1": "\u0061\u0301", // á = \'{a}
  "\u00e0": "\u0061\u0300", // à = \`{a}
  "\u00e4": "\u0061\u0308", // ä = \"{a}
  "\u01df": "\u0061\u0308\u0304", // ǟ = \"\={a}
  "\u00e3": "\u0061\u0303", // ã = \~{a}
  "\u0101": "\u0061\u0304", // ā = \={a}
  "\u0103": "\u0061\u0306", // ă = \u{a}
  "\u1eaf": "\u0061\u0306\u0301", // ắ = \u\'{a}
  "\u1eb1": "\u0061\u0306\u0300", // ằ = \u\`{a}
  "\u1eb5": "\u0061\u0306\u0303", // ẵ = \u\~{a}
  "\u01ce": "\u0061\u030c", // ǎ = \v{a}
  "\u00e2": "\u0061\u0302", // â = \^{a}
  "\u1ea5": "\u0061\u0302\u0301", // ấ = \^\'{a}
  "\u1ea7": "\u0061\u0302\u0300", // ầ = \^\`{a}
  "\u1eab": "\u0061\u0302\u0303", // ẫ = \^\~{a}
  "\u0227": "\u0061\u0307", // ȧ = \.{a}
  "\u01e1": "\u0061\u0307\u0304", // ǡ = \.\={a}
  "\u00e5": "\u0061\u030a", // å = \r{a}
  "\u01fb": "\u0061\u030a\u0301", // ǻ = \r\'{a}
  "\u1e03": "\u0062\u0307", // ḃ = \.{b}
  "\u0107": "\u0063\u0301", // ć = \'{c}
  "\u010d": "\u0063\u030c", // č = \v{c}
  "\u0109": "\u0063\u0302", // ĉ = \^{c}
  "\u010b": "\u0063\u0307", // ċ = \.{c}
  "\u010f": "\u0064\u030c", // ď = \v{d}
  "\u1e0b": "\u0064\u0307", // ḋ = \.{d}
  "\u00e9": "\u0065\u0301", // é = \'{e}
  "\u00e8": "\u0065\u0300", // è = \`{e}
  "\u00eb": "\u0065\u0308", // ë = \"{e}
  "\u1ebd": "\u0065\u0303", // ẽ = \~{e}
  "\u0113": "\u0065\u0304", // ē = \={e}
  "\u1e17": "\u0065\u0304\u0301", // ḗ = \=\'{e}
  "\u1e15": "\u0065\u0304\u0300", // ḕ = \=\`{e}
  "\u0115": "\u0065\u0306", // ĕ = \u{e}
  "\u011b": "\u0065\u030c", // ě = \v{e}
  "\u00ea": "\u0065\u0302", // ê = \^{e}
  "\u1ebf": "\u0065\u0302\u0301", // ế = \^\'{e}
  "\u1ec1": "\u0065\u0302\u0300", // ề = \^\`{e}
  "\u1ec5": "\u0065\u0302\u0303", // ễ = \^\~{e}
  "\u0117": "\u0065\u0307", // ė = \.{e}
  "\u1e1f": "\u0066\u0307", // ḟ = \.{f}
  "\u01f5": "\u0067\u0301", // ǵ = \'{g}
  "\u1e21": "\u0067\u0304", // ḡ = \={g}
  "\u011f": "\u0067\u0306", // ğ = \u{g}
  "\u01e7": "\u0067\u030c", // ǧ = \v{g}
  "\u011d": "\u0067\u0302", // ĝ = \^{g}
  "\u0121": "\u0067\u0307", // ġ = \.{g}
  "\u1e27": "\u0068\u0308", // ḧ = \"{h}
  "\u021f": "\u0068\u030c", // ȟ = \v{h}
  "\u0125": "\u0068\u0302", // ĥ = \^{h}
  "\u1e23": "\u0068\u0307", // ḣ = \.{h}
  "\u00ed": "\u0069\u0301", // í = \'{i}
  "\u00ec": "\u0069\u0300", // ì = \`{i}
  "\u00ef": "\u0069\u0308", // ï = \"{i}
  "\u1e2f": "\u0069\u0308\u0301", // ḯ = \"\'{i}
  "\u0129": "\u0069\u0303", // ĩ = \~{i}
  "\u012b": "\u0069\u0304", // ī = \={i}
  "\u012d": "\u0069\u0306", // ĭ = \u{i}
  "\u01d0": "\u0069\u030c", // ǐ = \v{i}
  "\u00ee": "\u0069\u0302", // î = \^{i}
  "\u01f0": "\u006a\u030c", // ǰ = \v{j}
  "\u0135": "\u006a\u0302", // ĵ = \^{j}
  "\u1e31": "\u006b\u0301", // ḱ = \'{k}
  "\u01e9": "\u006b\u030c", // ǩ = \v{k}
  "\u013a": "\u006c\u0301", // ĺ = \'{l}
  "\u013e": "\u006c\u030c", // ľ = \v{l}
  "\u1e3f": "\u006d\u0301", // ḿ = \'{m}
  "\u1e41": "\u006d\u0307", // ṁ = \.{m}
  "\u0144": "\u006e\u0301", // ń = \'{n}
  "\u01f9": "\u006e\u0300", // ǹ = \`{n}
  "\u00f1": "\u006e\u0303", // ñ = \~{n}
  "\u0148": "\u006e\u030c", // ň = \v{n}
  "\u1e45": "\u006e\u0307", // ṅ = \.{n}
  "\u00f3": "\u006f\u0301", // ó = \'{o}
  "\u00f2": "\u006f\u0300", // ò = \`{o}
  "\u00f6": "\u006f\u0308", // ö = \"{o}
  "\u022b": "\u006f\u0308\u0304", // ȫ = \"\={o}
  "\u00f5": "\u006f\u0303", // õ = \~{o}
  "\u1e4d": "\u006f\u0303\u0301", // ṍ = \~\'{o}
  "\u1e4f": "\u006f\u0303\u0308", // ṏ = \~\"{o}
  "\u022d": "\u006f\u0303\u0304", // ȭ = \~\={o}
  "\u014d": "\u006f\u0304", // ō = \={o}
  "\u1e53": "\u006f\u0304\u0301", // ṓ = \=\'{o}
  "\u1e51": "\u006f\u0304\u0300", // ṑ = \=\`{o}
  "\u014f": "\u006f\u0306", // ŏ = \u{o}
  "\u01d2": "\u006f\u030c", // ǒ = \v{o}
  "\u00f4": "\u006f\u0302", // ô = \^{o}
  "\u1ed1": "\u006f\u0302\u0301", // ố = \^\'{o}
  "\u1ed3": "\u006f\u0302\u0300", // ồ = \^\`{o}
  "\u1ed7": "\u006f\u0302\u0303", // ỗ = \^\~{o}
  "\u022f": "\u006f\u0307", // ȯ = \.{o}
  "\u0231": "\u006f\u0307\u0304", // ȱ = \.\={o}
  "\u0151": "\u006f\u030b", // ő = \H{o}
  "\u1e55": "\u0070\u0301", // ṕ = \'{p}
  "\u1e57": "\u0070\u0307", // ṗ = \.{p}
  "\u0155": "\u0072\u0301", // ŕ = \'{r}
  "\u0159": "\u0072\u030c", // ř = \v{r}
  "\u1e59": "\u0072\u0307", // ṙ = \.{r}
  "\u015b": "\u0073\u0301", // ś = \'{s}
  "\u1e65": "\u0073\u0301\u0307", // ṥ = \'\.{s}
  "\u0161": "\u0073\u030c", // š = \v{s}
  "\u1e67": "\u0073\u030c\u0307", // ṧ = \v\.{s}
  "\u015d": "\u0073\u0302", // ŝ = \^{s}
  "\u1e61": "\u0073\u0307", // ṡ = \.{s}
  "\u1e97": "\u0074\u0308", // ẗ = \"{t}
  "\u0165": "\u0074\u030c", // ť = \v{t}
  "\u1e6b": "\u0074\u0307", // ṫ = \.{t}
  "\u00fa": "\u0075\u0301", // ú = \'{u}
  "\u00f9": "\u0075\u0300", // ù = \`{u}
  "\u00fc": "\u0075\u0308", // ü = \"{u}
  "\u01d8": "\u0075\u0308\u0301", // ǘ = \"\'{u}
  "\u01dc": "\u0075\u0308\u0300", // ǜ = \"\`{u}
  "\u01d6": "\u0075\u0308\u0304", // ǖ = \"\={u}
  "\u01da": "\u0075\u0308\u030c", // ǚ = \"\v{u}
  "\u0169": "\u0075\u0303", // ũ = \~{u}
  "\u1e79": "\u0075\u0303\u0301", // ṹ = \~\'{u}
  "\u016b": "\u0075\u0304", // ū = \={u}
  "\u1e7b": "\u0075\u0304\u0308", // ṻ = \=\"{u}
  "\u016d": "\u0075\u0306", // ŭ = \u{u}
  "\u01d4": "\u0075\u030c", // ǔ = \v{u}
  "\u00fb": "\u0075\u0302", // û = \^{u}
  "\u016f": "\u0075\u030a", // ů = \r{u}
  "\u0171": "\u0075\u030b", // ű = \H{u}
  "\u1e7d": "\u0076\u0303", // ṽ = \~{v}
  "\u1e83": "\u0077\u0301", // ẃ = \'{w}
  "\u1e81": "\u0077\u0300", // ẁ = \`{w}
  "\u1e85": "\u0077\u0308", // ẅ = \"{w}
  "\u0175": "\u0077\u0302", // ŵ = \^{w}
  "\u1e87": "\u0077\u0307", // ẇ = \.{w}
  "\u1e98": "\u0077\u030a", // ẘ = \r{w}
  "\u1e8d": "\u0078\u0308", // ẍ = \"{x}
  "\u1e8b": "\u0078\u0307", // ẋ = \.{x}
  "\u00fd": "\u0079\u0301", // ý = \'{y}
  "\u1ef3": "\u0079\u0300", // ỳ = \`{y}
  "\u00ff": "\u0079\u0308", // ÿ = \"{y}
  "\u1ef9": "\u0079\u0303", // ỹ = \~{y}
  "\u0233": "\u0079\u0304", // ȳ = \={y}
  "\u0177": "\u0079\u0302", // ŷ = \^{y}
  "\u1e8f": "\u0079\u0307", // ẏ = \.{y}
  "\u1e99": "\u0079\u030a", // ẙ = \r{y}
  "\u017a": "\u007a\u0301", // ź = \'{z}
  "\u017e": "\u007a\u030c", // ž = \v{z}
  "\u1e91": "\u007a\u0302", // ẑ = \^{z}
  "\u017c": "\u007a\u0307", // ż = \.{z}
  "\u00c1": "\u0041\u0301", // Á = \'{A}
  "\u00c0": "\u0041\u0300", // À = \`{A}
  "\u00c4": "\u0041\u0308", // Ä = \"{A}
  "\u01de": "\u0041\u0308\u0304", // Ǟ = \"\={A}
  "\u00c3": "\u0041\u0303", // Ã = \~{A}
  "\u0100": "\u0041\u0304", // Ā = \={A}
  "\u0102": "\u0041\u0306", // Ă = \u{A}
  "\u1eae": "\u0041\u0306\u0301", // Ắ = \u\'{A}
  "\u1eb0": "\u0041\u0306\u0300", // Ằ = \u\`{A}
  "\u1eb4": "\u0041\u0306\u0303", // Ẵ = \u\~{A}
  "\u01cd": "\u0041\u030c", // Ǎ = \v{A}
  "\u00c2": "\u0041\u0302", // Â = \^{A}
  "\u1ea4": "\u0041\u0302\u0301", // Ấ = \^\'{A}
  "\u1ea6": "\u0041\u0302\u0300", // Ầ = \^\`{A}
  "\u1eaa": "\u0041\u0302\u0303", // Ẫ = \^\~{A}
  "\u0226": "\u0041\u0307", // Ȧ = \.{A}
  "\u01e0": "\u0041\u0307\u0304", // Ǡ = \.\={A}
  "\u00c5": "\u0041\u030a", // Å = \r{A}
  "\u01fa": "\u0041\u030a\u0301", // Ǻ = \r\'{A}
  "\u1e02": "\u0042\u0307", // Ḃ = \.{B}
  "\u0106": "\u0043\u0301", // Ć = \'{C}
  "\u010c": "\u0043\u030c", // Č = \v{C}
  "\u0108": "\u0043\u0302", // Ĉ = \^{C}
  "\u010a": "\u0043\u0307", // Ċ = \.{C}
  "\u010e": "\u0044\u030c", // Ď = \v{D}
  "\u1e0a": "\u0044\u0307", // Ḋ = \.{D}
  "\u00c9": "\u0045\u0301", // É = \'{E}
  "\u00c8": "\u0045\u0300", // È = \`{E}
  "\u00cb": "\u0045\u0308", // Ë = \"{E}
  "\u1ebc": "\u0045\u0303", // Ẽ = \~{E}
  "\u0112": "\u0045\u0304", // Ē = \={E}
  "\u1e16": "\u0045\u0304\u0301", // Ḗ = \=\'{E}
  "\u1e14": "\u0045\u0304\u0300", // Ḕ = \=\`{E}
  "\u0114": "\u0045\u0306", // Ĕ = \u{E}
  "\u011a": "\u0045\u030c", // Ě = \v{E}
  "\u00ca": "\u0045\u0302", // Ê = \^{E}
  "\u1ebe": "\u0045\u0302\u0301", // Ế = \^\'{E}
  "\u1ec0": "\u0045\u0302\u0300", // Ề = \^\`{E}
  "\u1ec4": "\u0045\u0302\u0303", // Ễ = \^\~{E}
  "\u0116": "\u0045\u0307", // Ė = \.{E}
  "\u1e1e": "\u0046\u0307", // Ḟ = \.{F}
  "\u01f4": "\u0047\u0301", // Ǵ = \'{G}
  "\u1e20": "\u0047\u0304", // Ḡ = \={G}
  "\u011e": "\u0047\u0306", // Ğ = \u{G}
  "\u01e6": "\u0047\u030c", // Ǧ = \v{G}
  "\u011c": "\u0047\u0302", // Ĝ = \^{G}
  "\u0120": "\u0047\u0307", // Ġ = \.{G}
  "\u1e26": "\u0048\u0308", // Ḧ = \"{H}
  "\u021e": "\u0048\u030c", // Ȟ = \v{H}
  "\u0124": "\u0048\u0302", // Ĥ = \^{H}
  "\u1e22": "\u0048\u0307", // Ḣ = \.{H}
  "\u00cd": "\u0049\u0301", // Í = \'{I}
  "\u00cc": "\u0049\u0300", // Ì = \`{I}
  "\u00cf": "\u0049\u0308", // Ï = \"{I}
  "\u1e2e": "\u0049\u0308\u0301", // Ḯ = \"\'{I}
  "\u0128": "\u0049\u0303", // Ĩ = \~{I}
  "\u012a": "\u0049\u0304", // Ī = \={I}
  "\u012c": "\u0049\u0306", // Ĭ = \u{I}
  "\u01cf": "\u0049\u030c", // Ǐ = \v{I}
  "\u00ce": "\u0049\u0302", // Î = \^{I}
  "\u0130": "\u0049\u0307", // İ = \.{I}
  "\u0134": "\u004a\u0302", // Ĵ = \^{J}
  "\u1e30": "\u004b\u0301", // Ḱ = \'{K}
  "\u01e8": "\u004b\u030c", // Ǩ = \v{K}
  "\u0139": "\u004c\u0301", // Ĺ = \'{L}
  "\u013d": "\u004c\u030c", // Ľ = \v{L}
  "\u1e3e": "\u004d\u0301", // Ḿ = \'{M}
  "\u1e40": "\u004d\u0307", // Ṁ = \.{M}
  "\u0143": "\u004e\u0301", // Ń = \'{N}
  "\u01f8": "\u004e\u0300", // Ǹ = \`{N}
  "\u00d1": "\u004e\u0303", // Ñ = \~{N}
  "\u0147": "\u004e\u030c", // Ň = \v{N}
  "\u1e44": "\u004e\u0307", // Ṅ = \.{N}
  "\u00d3": "\u004f\u0301", // Ó = \'{O}
  "\u00d2": "\u004f\u0300", // Ò = \`{O}
  "\u00d6": "\u004f\u0308", // Ö = \"{O}
  "\u022a": "\u004f\u0308\u0304", // Ȫ = \"\={O}
  "\u00d5": "\u004f\u0303", // Õ = \~{O}
  "\u1e4c": "\u004f\u0303\u0301", // Ṍ = \~\'{O}
  "\u1e4e": "\u004f\u0303\u0308", // Ṏ = \~\"{O}
  "\u022c": "\u004f\u0303\u0304", // Ȭ = \~\={O}
  "\u014c": "\u004f\u0304", // Ō = \={O}
  "\u1e52": "\u004f\u0304\u0301", // Ṓ = \=\'{O}
  "\u1e50": "\u004f\u0304\u0300", // Ṑ = \=\`{O}
  "\u014e": "\u004f\u0306", // Ŏ = \u{O}
  "\u01d1": "\u004f\u030c", // Ǒ = \v{O}
  "\u00d4": "\u004f\u0302", // Ô = \^{O}
  "\u1ed0": "\u004f\u0302\u0301", // Ố = \^\'{O}
  "\u1ed2": "\u004f\u0302\u0300", // Ồ = \^\`{O}
  "\u1ed6": "\u004f\u0302\u0303", // Ỗ = \^\~{O}
  "\u022e": "\u004f\u0307", // Ȯ = \.{O}
  "\u0230": "\u004f\u0307\u0304", // Ȱ = \.\={O}
  "\u0150": "\u004f\u030b", // Ő = \H{O}
  "\u1e54": "\u0050\u0301", // Ṕ = \'{P}
  "\u1e56": "\u0050\u0307", // Ṗ = \.{P}
  "\u0154": "\u0052\u0301", // Ŕ = \'{R}
  "\u0158": "\u0052\u030c", // Ř = \v{R}
  "\u1e58": "\u0052\u0307", // Ṙ = \.{R}
  "\u015a": "\u0053\u0301", // Ś = \'{S}
  "\u1e64": "\u0053\u0301\u0307", // Ṥ = \'\.{S}
  "\u0160": "\u0053\u030c", // Š = \v{S}
  "\u1e66": "\u0053\u030c\u0307", // Ṧ = \v\.{S}
  "\u015c": "\u0053\u0302", // Ŝ = \^{S}
  "\u1e60": "\u0053\u0307", // Ṡ = \.{S}
  "\u0164": "\u0054\u030c", // Ť = \v{T}
  "\u1e6a": "\u0054\u0307", // Ṫ = \.{T}
  "\u00da": "\u0055\u0301", // Ú = \'{U}
  "\u00d9": "\u0055\u0300", // Ù = \`{U}
  "\u00dc": "\u0055\u0308", // Ü = \"{U}
  "\u01d7": "\u0055\u0308\u0301", // Ǘ = \"\'{U}
  "\u01db": "\u0055\u0308\u0300", // Ǜ = \"\`{U}
  "\u01d5": "\u0055\u0308\u0304", // Ǖ = \"\={U}
  "\u01d9": "\u0055\u0308\u030c", // Ǚ = \"\v{U}
  "\u0168": "\u0055\u0303", // Ũ = \~{U}
  "\u1e78": "\u0055\u0303\u0301", // Ṹ = \~\'{U}
  "\u016a": "\u0055\u0304", // Ū = \={U}
  "\u1e7a": "\u0055\u0304\u0308", // Ṻ = \=\"{U}
  "\u016c": "\u0055\u0306", // Ŭ = \u{U}
  "\u01d3": "\u0055\u030c", // Ǔ = \v{U}
  "\u00db": "\u0055\u0302", // Û = \^{U}
  "\u016e": "\u0055\u030a", // Ů = \r{U}
  "\u0170": "\u0055\u030b", // Ű = \H{U}
  "\u1e7c": "\u0056\u0303", // Ṽ = \~{V}
  "\u1e82": "\u0057\u0301", // Ẃ = \'{W}
  "\u1e80": "\u0057\u0300", // Ẁ = \`{W}
  "\u1e84": "\u0057\u0308", // Ẅ = \"{W}
  "\u0174": "\u0057\u0302", // Ŵ = \^{W}
  "\u1e86": "\u0057\u0307", // Ẇ = \.{W}
  "\u1e8c": "\u0058\u0308", // Ẍ = \"{X}
  "\u1e8a": "\u0058\u0307", // Ẋ = \.{X}
  "\u00dd": "\u0059\u0301", // Ý = \'{Y}
  "\u1ef2": "\u0059\u0300", // Ỳ = \`{Y}
  "\u0178": "\u0059\u0308", // Ÿ = \"{Y}
  "\u1ef8": "\u0059\u0303", // Ỹ = \~{Y}
  "\u0232": "\u0059\u0304", // Ȳ = \={Y}
  "\u0176": "\u0059\u0302", // Ŷ = \^{Y}
  "\u1e8e": "\u0059\u0307", // Ẏ = \.{Y}
  "\u0179": "\u005a\u0301", // Ź = \'{Z}
  "\u017d": "\u005a\u030c", // Ž = \v{Z}
  "\u1e90": "\u005a\u0302", // Ẑ = \^{Z}
  "\u017b": "\u005a\u0307", // Ż = \.{Z}
  "\u03ac": "\u03b1\u0301", // ά = \'{α}
  "\u1f70": "\u03b1\u0300", // ὰ = \`{α}
  "\u1fb1": "\u03b1\u0304", // ᾱ = \={α}
  "\u1fb0": "\u03b1\u0306", // ᾰ = \u{α}
  "\u03ad": "\u03b5\u0301", // έ = \'{ε}
  "\u1f72": "\u03b5\u0300", // ὲ = \`{ε}
  "\u03ae": "\u03b7\u0301", // ή = \'{η}
  "\u1f74": "\u03b7\u0300", // ὴ = \`{η}
  "\u03af": "\u03b9\u0301", // ί = \'{ι}
  "\u1f76": "\u03b9\u0300", // ὶ = \`{ι}
  "\u03ca": "\u03b9\u0308", // ϊ = \"{ι}
  "\u0390": "\u03b9\u0308\u0301", // ΐ = \"\'{ι}
  "\u1fd2": "\u03b9\u0308\u0300", // ῒ = \"\`{ι}
  "\u1fd1": "\u03b9\u0304", // ῑ = \={ι}
  "\u1fd0": "\u03b9\u0306", // ῐ = \u{ι}
  "\u03cc": "\u03bf\u0301", // ό = \'{ο}
  "\u1f78": "\u03bf\u0300", // ὸ = \`{ο}
  "\u03cd": "\u03c5\u0301", // ύ = \'{υ}
  "\u1f7a": "\u03c5\u0300", // ὺ = \`{υ}
  "\u03cb": "\u03c5\u0308", // ϋ = \"{υ}
  "\u03b0": "\u03c5\u0308\u0301", // ΰ = \"\'{υ}
  "\u1fe2": "\u03c5\u0308\u0300", // ῢ = \"\`{υ}
  "\u1fe1": "\u03c5\u0304", // ῡ = \={υ}
  "\u1fe0": "\u03c5\u0306", // ῠ = \u{υ}
  "\u03ce": "\u03c9\u0301", // ώ = \'{ω}
  "\u1f7c": "\u03c9\u0300", // ὼ = \`{ω}
  "\u038e": "\u03a5\u0301", // Ύ = \'{Υ}
  "\u1fea": "\u03a5\u0300", // Ὺ = \`{Υ}
  "\u03ab": "\u03a5\u0308", // Ϋ = \"{Υ}
  "\u1fe9": "\u03a5\u0304", // Ῡ = \={Υ}
  "\u1fe8": "\u03a5\u0306", // Ῠ = \u{Υ}
  "\u038f": "\u03a9\u0301", // Ώ = \'{Ω}
  "\u1ffa": "\u03a9\u0300", // Ὼ = \`{Ω}
};

const unicodeAccentsSymbols = {
  '\u0300': '\u0060', // \grave
  '\u0308': '\u00a8', // \ddot
  '\u0303': '\u007e', // \tilde
  '\u0304': '\u00AF', // \bar
  '\u0301': '\u00b4', // \acute
  '\u0306': '\u02d8', // \breve
  '\u030c': '\u02c7', // \check
  '\u0302': '\u005e', // \hat
  '\u0307': '\u02d9', // \dot
  '\u030a': '\u02da', // \mathring
  '\u030b': '\u02dd', // double acute
};
