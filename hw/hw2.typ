#set page(
  paper: "a4",
  margin: (x: 2.2cm, y: 2cm),
)

#set text(
  font: "New Computer Modern Sans",
  size: 11pt,
)

#set par(
  leading: 0.8em,
  justify: true,
)

#set page(paper: "a4", margin: 3em)
#import "@preview/dvdtyp:1.0.1"
#import "@preview/numbly:0.1.0": numbly
#import "@preview/thmbox:0.3.0": *
#import "@preview/cuti:0.2.1": show-cn-fakebold

#show: show-cn-fakebold
#import "@preview/mitex:0.2.5": *
#set text(font: "Songti SC")
//#show emph: text.with(font: "STKaiti")
//#show smartquote: set text(font: "Libertinus Serif")
#import "@preview/dvdtyp:1.0.1": *
#show math.equation: set text(purple, size: 1em)
#set line(length: 100%, stroke: 0.1pt)
#show: dvdtyp.with(
  title: "hw2",
  author: "易守拙 2024300001103",
)
#let cg = $cal(G)$
#let cv = $cal(V)$
#let al = $chevron.l$
#let ar = $chevron.r$
#let tt(content) = text(font: "JetBrains Mono", content)
#let ui = tt($al"UINT"ar$)
#let di =tt($al"DIGIT"ar$)
== 1. 分析解答题（30 分）

#problem[
  写出下述文法所产生的语言的形式化表示.

$ G[A] = ( {A, B, C}, {a, b, c}, P, A ) $

其中 $P$ 包含：

$
A &-> a b c \
A &-> a B b c \
B b &-> b B \
B c &-> C b c c \
b C &-> C b \
a C &-> a a B \
a C &-> a a
$

]
#solution[
  显然$a b c in L$.

  先归纳说明$
   B b^n =>^star b^(t) B b ^(n-t) =>^star b^n B ,forall t in {1,2,dots,n}.
  $
  对$t$归纳,直接利用$B b -> b B$即可.
注意到$
a^m B b^n c^t =>a^m b^(n) B  c^t => a^m b^(n)C b c^(t+1) => a^m C b^(n+1) c^(t+1) => a^(m+1) B^Q b^(n+1) c^(t+1),quad Q in {0,1}
$,且最初生成的时候$m=n=t=1$.
自然$a^n b^n c^n in L,n in NN.$那么,$L = {a^n b^n c^n | n in NN^+}.$
]
#v(1em)

== 2. 分析解答题（20 分）

#problem[
  设文法

$
G[N] = ( {N, D}, {0, 1, 2, 3, 4, 5, 6, 7}, P, N )
$

其中，

$
P = {
  N -> N D | D,
  D -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
}
$

请完成：

+ 给出符号串“3274”对应的语法树；
+ 写出得到符号串“3274”的最左推导和最右推导；
+ 说明语法树与推导序列之间是什么关系。
]
#solution[
  1. #image("/assets/image-5.png",width:30%)
  2. 
   - 最左:$N => N D => N D D => N D D D => D D D D => 3D D D =>32D D =>3 2 7 D => 3274$;
   - 最右:$N => N D => N 4=>N D. 4 => N 74=>N D 74 => N 274=> D 274 =>3274$.
  3. 一棵语法树对应多个推导序列,而最左、最右推导与语法树一一对应.
]

#v(1em)

== 3. 分析解答题（30 分）

#problem[[
  请构造一个文法，该文法能够产生所有能被 5 整除的整数
（指数学上习惯的整数表达形式）。
]]
#solution([
  考虑这样的$cg[S] = {{S,U,V,W,X},{-,0,1,2,3,4,5,6,7,8,9},P,S},$
  $
   P = {U -> -,V-> 0|5,W->0|1|2|3|4|5|6|7|8|9,S->U X V|X V|U V|V ,X->W|W X}.
  $

  来证明他满足要求.考虑$ W^t X => W^(t+1) X^Q , Q in{0,1}$,进而可以得到$X =>^star W^n ,n in NN$.
  所以$S=>^star U^Q W^n V,Q in{0,1},V$给出末位是0或5,W给出0\~9的任意数字,U给出负号.这就能生成所有能被5整除的整数.
])

#v(1em)

== 4. 分析解答题（10 分）

#problem[
  请判定下述文法是否有二义性，并给出理由。

$
G[#ui] =
(V_N, V_T, P, #ui)
$

其中，

$
V_N = {
  #ui,
  #di
}
$

$
V_T = {
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9
}
$

产生式集合为：

$
P = {
  #ui -> #di,
  #di -> #di #di,
  #di -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
}
$
]
#solution[
  有.考虑$123 in L$:
  $
   #ui &=> #di => #di #di =>#di #di #di \ &=> 1 #di #di => 1 2#di=>123
  $
  以及
    $
   #ui &=> #di => #di #di =>1 #di \ &=> 1 #di #di => 1 2#di=>123
  $
  容易检查它们都是最左推导,这意味着$123$的最左推导不唯一,进而有二义性.
]

#v(1em)

== 5. 分析解答题（10 分）
#problem[

设有文法 $G[S]$：

$
S &-> a A B b c d | epsilon \
A &-> A S d | epsilon \
B &-> S A h | e C | epsilon \
C &-> S f | C g | epsilon \
D &-> a B D | epsilon
$

该文法需要压缩吗？为什么？

]
#solution([
  需要.正向标记法:$S$可达$A,B,$进而可以达到$ C$.所以$D$不可到达,需要删掉$D &-> a B D | epsilon$.

 另外,显然$S,A,B,C$都可以推导出终结串$epsilon$,所以只需要删掉一条即可.
])