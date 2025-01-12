* LeftRight should remove 0.12 em nulldelimiter introduced by FracNode.
* | and \u2223 needs extra moderation for the symbol (also in stacked delimiter) (\u2225Parallel & \u2016Vert)
* extract nulldelimiter
* modify symbols.dart to change the render config of surrogate pairs
* equation breaking
* gathered environment

## Won't support functionalities
- `\href`
- `\includegraphics`
- `\lap` and other horizontal lapping command (This will probably be reconsidered in the future)
- `\mathchoice` and dependent features
- `\smash`
- `\overlinesegment`, `\underlinesegment`
- `\pmb`
- `\hspace*`
- Exotic composite symbols: `\Coloneqq, \coloneq, \Coloneq, \Eqqcolon, \Eqcolon, \colonapprox, \Colonapprox, \colonsim, \Colonsim, \simcolon, \simcoloncolon, \approxcolon, \approxcoloncolon`, and also their equivalent `\coloncolonequals` ...
- `\vcentcolon`
- `\textcircle` and related `\copyright`, `\registered`, etc.

## Functionalities that will be supported later
- `gather` environment
- `Vmatrix` environment
- `\mathnormal`

## Known parsing differences to KaTeX
- `\not` can only accept selected characters following it, because it is no longer backed by `\rlap`. (This will probably be revisited).
- The parsing behavior of `\overbrace` and `\underbase` with sub-sup pairs will be in line with MathJax rather than KaTeX.
- `\u2258` will be investigated later

## Known rendering differences to KaTeX
- Math functions with limit-like subscript and superscript will not adapt to sub/sup under/over styles under different styles. This breaks TeX spec. This is due to the design of AST, and is in accordance with UnicodeMath designs.
- Multiple `\hlines` and `||` column separators for matrices will not be supported, just as MathJax won't either.
- `aligned` and `alignedat` will have column spacings more similar to an ordinary equation. This should be an improvement to KaTeX and MathJax.
- `\genfrac`'s delimiters will have a larger spacing with inner node. (This might be fixed in future)
- `\color` commands inside a block will NOT be applied to right delimiters. This is in line with MathJax rather than KaTeX.
- `\colon`'s behavior will be in line with MathJax rather than KaTeX.
- `\mathop` will no longer vertically center single characaters. MathJax doesn't do this either.
- `\cancel`, `\xcancel`, `\bcancel` will render differently compared to KaTeX. The vertical padding will be more similar to MathJaX.
- Due to the lack of `\mathchoice`, `\pod`, `\pmod`, `\mod` will have fixed spacing.
- `\dfrac`, `\tfrac` ... will have slight size deviation from KaTeX and will be in line with MathJax's rendering behavior.
- `\sqrt` will no longer underflow below the baseline when given a child whose height is too small (e.g. `\sqrt{.}`). This is also different from MathJaX.
- The size of `\sqrt` symbol might be slightly different. Due to a different style choosing scheme.
- There will be no automatic thinspace between `\cdots` and right delimiter, (which is odd. MathJax and Tex don't have them either)

Any other deviations from KaTeX will be considered as bug.









# References on UnicodeMath input implementation

There are two areas of UnicodeMath input support currently under consideration: user input, or a string input. The plan is to support both by treating string input as raw sequence of AtomNode, performing autocorrect, then performing an exhaustive fold with lowest precedence from the end. (This behavior is not guaranteed by the spec itself, but it seems good.)

## Difference between user input and string input
### Heuristic operation
- '\sum  a b' input by user will produce '\sum\of(a b)'. But in string input it should be '\sum\of(a) b'
- same with every operators creating an SlottableNode and moves cursor inside

The [UnicodeMath spec](https://www.unicode.org/notes/tn28/UTN28-PlainTextMath-v3.1.pdf) itself proposed a reference parsing algorithm in Appendix A. However there are some conflicts in the UnicodeMath spec.

## Conflicts and Decision

Spec-wise, this reference algorithm deviates from the spec:
- Handling of the unary operators before and after subsup (*Align with reference*)
    - '+^2', 'a^-2' as subsup? (Spec says no. Reference says yes.)
- \of \funcapply \naryand

Also, MS Word's implementation deviates from the reference:
- Handling of the normal operators after div & subsup (*Align with MS Word*)
    - '1/+2', '+1/2' as fraction? (Reference disallows both. MS Word permits the first one.)
- Differentiation between the unary plus and unary subtract (*Align with MS Word*)
    - 'a^-1' vs 'a^+1' as subsup? (Reference only allows the first. MS Word allows both.)
- ScriptBase parsing (*Align with MS Word*)
    - 'word^2' as subsup? (Reference says yes. MS Word says no.)

Some quirks in MS Word:
- `/\of  ` folds into `\frac{}{\frac{}{}}`, while `^\of ` leads to an \of on the supscript as expected. (Potentially bug)
- `/` wins in precedence in the combination `/^`. (*reproduced*)
- `(1) /2` folds into `\frac{1}{2}`, while `1 /2` folds into `1 \frac{}{2}`. (*reproduced*)
- `\sum \of  \of  ` folds into `\sum{}`. (*reproduced*)
- In `∑^∑_a▒a`, `\of` has a higher precedence than `^`.

Some conflicts between UnicodeMath and TeX:
- Rendering of subsup scripts when base comprises of multiple elements.

## Parser Scheme

The following parser scheme should be good enough to comply with the spec and mimic reference/MS Word behavior.

Operators will declare
- Their precedence
- Whether they need left operand and right operand
- Their associativity (i.e., '/' and '^' has opposite associativity)
- Whether they will unwrap parenthesis-enclosed operand (i.e. scriptBase will retain the parenthesis)

Fold operations are specified with precedence and starting pos. A one-time fold will iterate from right to left:
- Collect if not an operator.
- If met an operator with lower precedence, abort and return collected nodes. Open-close pairs will not be aborted.
- If met an operator with higher precedence,
    - If said operator needs left operand, launch an exhaustive fold to collect left operand
        - If left associative, the exhaustive fold will collect the largest block with greater-or-equal precedence.
        - If right associative, it will only allows greater precedence.
    - Give operands to the operand (If needed) and concat the result. Return.

An exhaustive fold with precedence p_start will:
- Perform a one-time fold. Denote the fold result's internal precedence as p_res. End position has either index = 0 or has a precedence p_end < p_res.
- At the end position, if p_end > p_start, continue with another exhaustive fold with the same precedence. Results from the previous steps (p_res) will be passed into the fold (p_end) as potential right operand.

Some special points:
- Some operators may throw an exception (i.e. parenthesis mismatch). This will cause a one-time fold to revert, or the immediate cycle of a exhaustive fold to revert.
- Many operators will raise their precedence if preceded by fraction operators and script operators.
- Many operators will be forcefully taken as base if the script operators cannot fetch a left operand as base.
- The folding of Naryand will only be triggered by \of
- Some operators will eventually have to rollback due to their non-local ambiguity, such as `|`.

## Unsupported UnicodeMath functions
The following features are not supported by MS Word and by Flutter Math
- \lessgtr \gtrless
- \sqsubseteq \sqsupseteq
- \ndiv

The following feature are not supported by Flutter Math
- \sdiv
- \ldiv
- Nary
- Nary limits control
- prescript ?
- multiscript with a composite base (render difference)
- \coint
- \middle

## Reference algorithm
- char ← Unicode character
- space ← ASCII space (U+0020)
- αASCII ← ASCII A-Z a-z
- nASCII ← ASCII 0-9
- αnMath ← Unicode math alphanumeric (U+1D400 – U+1D7FF with some Letterlike symbols U+2102 – U+2134)
- αnOther ← Unicode alphanumeric not including αnMath nor nASCII
- αn ← αnMath | αnOther
---
- diacritic ← Unicode combining mark
- opArray ← ‘&’ | VT | ‘■’
- opClose ← ‘)’ | ‘]’ | ‘}’ | ‘⌍’
- opCloser ← opClose | “\close”
- opDecimal ← ‘.’ | ‘,’
- opHbracket ← Unicode math horizontal bracket
- opNary ← Unicode integrals, summation, product, and other nary ops
- opOpen ← ‘(’ | ‘[’ | ‘{’ | ‘⌌’
- opOpener ← opOpen | “\open”
- opOver ← ‘/’ | “\atop”
- opBuildup ← ‘_’ | ‘^’ | ‘√’ | ‘∙’ | ‘√’ | ‘□’ | ‘/’ | ‘|’ | opArray | opOpen | opClose | opNary | opOver | opHbracket | opDecimal
- other ← char – {αn + nASCII + diacritic + opBuildup + CR}
---
- diacriticbase ← αn | nASCII | ‘(’ exp ‘)’
- diacritics ← diacritic | diacritics diacritic
- atom ← αn | diacriticbase diacritics
- atoms ← atom | atoms atom
- digits ← nASCII | digits nASCII
- number ← digits | digits opDecimal digits
---
- expBracket ← opOpener exp opCloser  
  ←  ‘||’ exp ‘||’  
  ←  ‘|’ exp ‘|’
- word ← αASCII | word αASCII
- scriptbase ← word | word nASCII | αnMath | number | other | expBracket | opNary
- soperand ← operand | ‘∞’ | ‘-’ operand | “-∞”
- expSubsup ← scriptbase ‘_’ soperand  ‘^’ soperand |   scriptbase ‘^’ soperand  ‘_’ soperand
- expSubscript ← scriptbase ‘_’ soperand
- expSuperscript ← scriptbase ‘^’ soperand
- expScript ← expSubsup | expSubscript | expSuperscript
---
- entity ← atoms | expBracket | number
- factor ← entity | entity ‘!’ | entity “!!” | function | expScript
- operand ← factor | operand factor
- box ← ‘□’ operand
- hbrack ← opHbracket operand
- sqrt ← ‘√’ operand
- cubert ← ‘∙’ operand
- fourthrt ← ‘√’ operand
- nthrt ← “√(” operand ‘&’ operand ‘)’
- function ← sqrt | cubert | fourthrt | nthrt | box | hbrack
- numerator ← operand | fraction
- fraction ← numerator opOver operand
---
- row ← exp | row ‘&’ exp
- rows ← row | rows ‘@’ row
- array ← “\array(” rows ‘)’
---
- element ← fraction | operand | array
- exp ← element | exp other element 
