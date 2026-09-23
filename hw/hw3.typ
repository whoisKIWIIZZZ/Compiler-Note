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
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

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

#let cv = $cal(V)$
#let ce = $cal(E)$
#let cg = $cal(G)$
#let al = $chevron.l$
#let ar = $chevron.r$
#let cd = $cal(D)$
#let qh = $Q_"halt"$
#let pas = $phi.alt^star$
#let ei = $epsilon"-CLOSURE"$
= 分析解答题（30 分）
#problem[
  请举一例说明生活中有穷自动机的某种具体实例,要求将该有穷自动机实例的各部分抽象成形式化五元组描述,并说明每个状态、每个输入、每个转换关系的现实含义.
]
#solution([
  考虑开关门,它可以被抽象为
$
DD = al Q, Sigma, pas, q_0, F ar$
- $Q = {q_"关", q_"开"}
$
- $Sigma = {p, n}
$
- $q_0 = q_"关"
$
- $F = {q_"开"}
$

转移函数 $pas$ 为：

#table(
  columns: 3,
  align: center,
  [当前状态], [输入 $p$], [输入 $n$],
  [$q_"关"$], [$q_"开"$], [$q_"关"$],
  [$q_"开"$], [$q_"开"$], [$q_"关"$],
)
含义:
- 状态 $q_"关"$：自动门处于关闭状态,不能通行.
- 状态 $q_"开"$：自动门处于打开状态,可以通行.
- 输入 $p$：传感器检测到有人靠近,即“有人”.
- 输入 $n$：传感器没有检测到人,即“无人”.
- 初始状态 $q_0 = q_"关"$：系统开始时自动门是关闭的.
- 接受状态集 $F = {q_"开"}$：把“门打开、允许通行”看作自动机希望到达或被接受的状态.

各转换关系的现实含义：

1. $delta(q_"关", p) = q_"开"$：门本来是关的,检测到有人靠近,于是门打开.
2. $delta(q_"关", n) = q_"关"$：门本来是关的,也没有人靠近,于是门继续保持关闭.
3. $delta(q_"开", p) = q_"开"$：门已经打开,且仍然检测到有人,于是门保持打开.
4. $delta(q_"开", n) = q_"关"$：门已经打开,但检测不到人了,于是自动门关闭.

])


#problem[
  请构造一个DFA,它接受{a,b}上的符号串,符号串中的每个b都有a紧随在右边；并构造该语言相应的正规文法.（需要给出DFA状态转换图和形式化表示；文法需要给出形式化表示.）

]
#solution([
  记所求DFA为$DD = al Q , Sigma,pas,q_0,qh ar$,这里的$pas: Q times Sigma^star |-> Q$是拓展后的迁移函数,且满足
  - $Sigma = {a,b}$
  - $q_0 = S,qh = S$为起始和终止状态,$Q={S,A,B},$其中A是“接受中”,B为“已经错误”的拒绝状态;
  - $forall q in Q,alpha,beta in Sigma^star, alpha = x beta,$
$
pas(q, alpha) = cases(
  q","quad&alpha = epsilon,
  S","quad& (q, x) in {(S, a), (A, a)},
  A","& (q, alpha) = (S, b),
  D","& (q, alpha) in {(A, b), (D, a), (D, b)},
  pas(pas(q,x),beta)","quad&"else"
)
$
图:


#figure(
  diagram(
  node((0, 0), $S$, shape: circle, stroke: 1pt),
  node((1, 0), $A$, shape: circle, stroke: 1pt),
  node((2, 0), $B$, shape: circle, stroke: 1pt),
  // 用两个同心圆表示接受状态（双圈）
  
  edge((0, 0), (0, 0), "->", loop-angle: 90deg, bend: 130deg,label: $a$),
 edge((0, 0), (1, 0), "->", loop-angle: 10deg, bend: 30deg,label: $b$),
 edge((2, 0), (2, 0), "->", loop-angle: 90deg, bend: 130deg,label: $a,b$),
 edge((1, 0), (0, 0), "->", loop-angle: 10deg, bend: 30deg,label: $a$),
  edge((1, 0), (2, 0), "->", label: $b$),
),caption:[
  DFA转换图.图利用_typst,fletcher_绘制
]
)
$cg[S] = al cv_N,cv_T, P,S ar$文法定义为:
- $cv_N = {S,A},cv_T = {a,b}$;
- $P = {S -> a S|b A|epsilon , A -> a S}.$
])




#problem[

请将下列正规表达式转换成等价的DFA,并最小化.（要求给出详细过程、最终状态转换图和形式化表示.）

$(a|b)^star a b b (a|b)^star$ （其中的“|”是竖线,不是英文字母）
]
#solution[


Step1.如下图,这是从RE构造FA的状态转换图的过程:

#diagram(
  node((0, 0), $S$, shape: circle, stroke: 1pt),
  node((2, 0), $Z$, shape: circle, stroke: 1pt),
  edge((0, 0), (2, 0), "->", label: $(a|b)^star a b b (a|b)^star$),
  )
  #let i = -1
  #let n() = { i += 1; i }

  #diagram(
  node((0, 0), $S$, shape: circle, stroke: 1pt), 
  node((1, 0), $A$, shape: circle, stroke: 1pt),
  node((2, 0), $B$, shape: circle, stroke: 1pt),
  node((3, 0), $C$, shape: circle, stroke: 1pt),
  node((4, 0), $D$, shape: circle, stroke: 1pt),
  node((5, 0), $Z$, shape: circle, stroke: 1pt),
  edge((0, 0), (1, 0), "->", label: $(a|b)^star$),
  edge((1, 0), (2, 0), "->", label: $a$),
  edge((2, 0), (3, 0), "->", label: $b$),
edge((3, 0), (4, 0), "->", label: $ b$),
edge((4, 0), (5, 0), "->", label: $(a|b)^star$),

  )

   #diagram(
  node((-1, 0), $S$, shape: circle, stroke: 1pt), 
  node((0, 0), $T$, shape: circle, stroke: 1pt),
  node((1, 0), $A$, shape: circle, stroke: 1pt),
  node((2, 0), $B$, shape: circle, stroke: 1pt),
  node((3, 0), $C$, shape: circle, stroke: 1pt),
  node((4, 0), $D$, shape: circle, stroke: 1pt),
  node((5, 0), $E$, shape: circle, stroke: 1pt),
  node((6, 0), $Z$, shape: circle, stroke: 1pt),
  edge((0, 0), (0, 0), "->", loop-angle: 90deg, bend: 130deg,label: $a|b$),
  edge((-1, 0), (0, 0), "->", label: $epsilon$),
  edge((0, 0), (1, 0), "->", label: $epsilon$),
  edge((1, 0), (2, 0), "->", label: $a$),
  edge((2, 0), (3, 0), "->", label: $b$),
edge((3, 0), (4, 0), "->", label: $ b$),
edge((4, 0), (5, 0), "->", label: $epsilon$),
edge((5, 0), (6, 0), "->", label: $epsilon$),
edge((5, 0), (5, 0), "->",loop-angle: 90deg, bend: 130deg, label: $a|b$),

  )

   #diagram(
  node((-1, 0), $S$, shape: circle, stroke: 1pt), 
  node((0, 0), $T$, shape: circle, stroke: 1pt),
  node((1, 0), $A$, shape: circle, stroke: 1pt),
  node((2, 0), $B$, shape: circle, stroke: 1pt),
  node((3, 0), $C$, shape: circle, stroke: 1pt),
  node((4, 0), $D$, shape: circle, stroke: 1pt),
  node((5, 0), $E$, shape: circle, stroke: 1pt),
  node((6, 0), $Z$, shape: circle, stroke: 1pt),
  edge((0, 0), (0, 0), "->", loop-angle: 90deg, bend: 130deg,label: $a$),
  edge((0, 0), (0, 0), "->", loop-angle: -90deg, bend: 130deg,label: $b$),
  edge((-1, 0), (0, 0), "->", label: $epsilon$),
  edge((0, 0), (1, 0), "->", label: $epsilon$),
  edge((1, 0), (2, 0), "->", label: $a$),
  edge((2, 0), (3, 0), "->", label: $b$),
edge((3, 0), (4, 0), "->", label: $ b$),
edge((4, 0), (5, 0), "->", label: $epsilon$),
edge((5, 0), (6, 0), "->", label: $epsilon$),
edge((5, 0), (5, 0), "->",loop-angle: 90deg, bend: 130deg, label: $a$),
edge((5, 0), (5, 0), "->",loop-angle: -90deg, bend: 130deg, label: $b$),

  )

$phi.alt'(q, x)$ 表示从状态 $q$ 读入单个字符 $x$后直接到达的状态集合,满足

#figure(
  table(
  columns: 4,
  align: (center, center, center, center),
  stroke: 0.5pt,
  [状态 $q$], [$x = a$], [$x = b$], [$x = epsilon$],
  [$S$], [$diameter$], [$diameter$], [$\{T\}$],
  [$T$], [$\{T\}$], [$\{T\}$], [$\{A\}$],
  [$A$], [$\{B\}$], [$diameter$], [$diameter$],
  [$B$], [$diameter$], [$\{C\}$], [$diameter$],
  [$C$], [$diameter$], [$\{D\}$], [$diameter$],
  [$D$], [$diameter$], [$diameter$], [$\{E\}$],
  [$E$], [$\{E\}$], [$\{E\}$], [$\{Z\}$],
  [$Z$], [$diameter$], [$diameter$], [$diameter$],
)
)
  我们得到了一个NFA $NN = al Q',Sigma' ,pas', Q_0,qh ar$,其中:
  - $Q' = {S, T, A, B, C, D, E, Z}$
  - $Sigma' = {a, b}$
  - $Q_0 = {S}$,$F' = {Z}$,
$
pas'(q, alpha) = cases(
  ei(q)","quad & alpha = epsilon,
  union.big_(p in phi.alt'(q, x)) pas'(p, beta)","quad & alpha = x beta,
  diameter","quad &"else"
)
$
#line()
Step2.DFA.记$DD = al Q , Sigma,pas,q_0,qh ar$,这里的$pas: Q times Sigma^star |-> Q$是拓展后的迁移函数.通过求闭包立刻可以知道
   $q_0 = {S,T,A}$,进而:

#let q0 = ${S, T, A}$
#let q1 = ${T, A, B}$
#let q2 = ${T, A}$
#let q3 = ${T, A, C}$
#let q4 = ${T, A, D, E, Z}$
#let q5 = ${T, A, B, E, Z}$
#let q6 = ${T, A, E, Z}$
#let q7 = ${T, A, C, E, Z}$
- *初始状态* $q_0 = ei(S) = {S, T, A}$
  - 输入 $a$: 转移到 ${T, B}$,闭包为 ${T, A, B} = q_1$
  - 输入 $b$: 转移到 ${T}$,闭包为 ${T, A} = q_2$

- *状态* $q_1 = {T, A, B}$
  - 输入 $a$: 转移到 ${T, B}$,闭包为 ${T, A, B} = q_1$
  - 输入 $b$: 转移到 ${T, C}$,闭包为 ${T, A, C} = q_3$

- *状态* $q_2 = {T, A}$
  - 输入 $a$: 转移到 ${T, B}$,闭包为 ${T, A, B} = q_1$
  - 输入 $b$: 转移到 ${T}$,闭包为 ${T, A} = q_2$

- *状态* $q_3 = {T, A, C}$
  - 输入 $a$: 转移到 ${T, B}$,闭包为 ${T, A, B} = q_1$
  - 输入 $b$: 转移到 ${T, D}$,闭包为 ${T, A, D, E, Z} = q_4$ (包含 $Z$,为接受状态)

- *状态* $q_4 = {T, A, D, E, Z}$ (接受状态)
  - 输入 $a$: 转移到 ${T, B, E}$,闭包为 ${T, A, B, E, Z} = q_5$
  - 输入 $b$: 转移到 ${T, E}$,闭包为 ${T, A, E, Z} = q_6$

- *状态* $q_5 = {T, A, B, E, Z}$ (接受状态)
  - 输入 $a$: 转移到 ${T, B, E}$,闭包为 ${T, A, B, E, Z} = q_5$
  - 输入 $b$: 转移到 ${T, C, E}$,闭包为 ${T, A, C, E, Z} = q_7$

- *状态* $q_6 = {T, A, E, Z}$ (接受状态)
  - 输入 $a$: 转移到 ${T, B, E}$,闭包为 ${T, A, B, E, Z} = q_5$
  - 输入 $b$: 转移到 ${T, E}$,闭包为 ${T, A, E, Z} = q_6$

- *状态* $q_7 = {T, A, C, E, Z}$ (接受状态)
  - 输入 $a$: 转移到 ${T, B, E}$,闭包为 ${T, A, B, E, Z} = q_5$
  - 输入 $b$: 转移到 ${T, D, E}$,闭包为 ${T, A, D, E, Z} = q_4$
则
-  $Q = {q_0,q_1,q_2,q_3,q_4,q_5,q_6,q_7}$
-  $Sigma = {a,b}$
-  转移规则$phi.alt$见表
#figure(
  table(
  columns: 3,
  align: (center, center, center),
  stroke: 0.5pt,
  [状态 $q$], [$x = a$], [$x = b$],
  [$q_0$], [$q_1$], [$q_2$],
  [$q_1$], [$q_1$], [$q_3$],
  [$q_2$], [$q_1$], [$q_2$],
  [$q_3$], [$q_1$], [$q_4$],
  [$q_4$], [$q_5$], [$q_6$],
  [$q_5$], [$q_5$], [$q_7$],
  [$q_6$], [$q_5$], [$q_6$],
  [$q_7$], [$q_5$], [$q_4$],
))
,
$
pas(q, alpha) = cases(
  q","quad & alpha = epsilon,
  pas(phi.alt(q, x), beta)","quad & alpha = x beta,
  diameter","quad &"else"
)
$
- 终止状态$F = {q_4,q_5,q_6,q_7}$

#line()
Step3.最小化.
二分$Q$为${{q_0,q_1,q_2,q_3},{q_4,q_5,q_6,q_7}}$.注意到终止状态里任何一个状态都等价(看表格的后四行).
表格第四行知道${q_0,q_1,q_2}$读取一个b和${q_3}$读取一个b后转移的状态不同,后者会转移到$q_4$,进而要划分成${q_0,q_1,q_2},{q_3},{q_4,q_5,q_6,q_7}$.

类似的操作,最后得到${q_0,q_2},{q_1},{q_3},{q_4,q_5,q_6,q_7}$.
删掉$q_2,q_5,q_6,q_7$.
化简后的DFA为

$
DD_min = al
  {q_0, q_1, q_3, q_4},
  {a, b},
  pas_min,
  q_0,
  {q_4}
ar.
$
#figure(
  table(
  columns: 3,
  align: (center, center, center),
  stroke: 0.5pt,
  [状态 $q$], [$x = a$], [$x = b$],
  [$q_0$], [$q_1$], [$q_0$],
  [$q_1$], [$q_1$], [$q_3$],
  [$q_3$], [$q_1$], [$q_4$],
  [$q_4$], [$q_4$], [$q_4$],
))
,
$
pas(q, alpha) = cases(
  q","quad & alpha = epsilon,
  pas(phi.alt(q, x), beta)","quad & alpha = x beta,
  diameter","quad &"else"
)
$


]


#problem[
  
  请给出描述下述FA所识别的符号串的特征的正规表达式.要求给出详细过程.
#image("/assets/00d0a64dd3fbb9825aab26c6e19f59ca.png")
（请使用书中3.3.3节定义中的符号,不要使用正规表达式扩展后的符号.）
]

#solution([
  
])