#import "../lib.typ": *
#show: conf.with(
    author: "BJHH2005,xhkzdepartedream,kiwiizzz,Zoomy",
    title: "Principles of Compilation · chapter1",
    cover: false,
    sidebar: false,
)


#let cv = $cal(V)$
#let ce = $cal(E)$
#let cg = $cal(G)$
#let al = $chevron.l$
#let ar = $chevron.r$
#let cd = $cal(D)$
#let qh = $Q_"halt"$
#let pas = $phi.alt^star$
#let ei = $epsilon"-CLOSURE"(I)$

= Chapter3 有穷自动机
有穷自动机(FA)是词法分析程序的抽象模型。

#align(center)[
    #table(
        columns: (auto, auto, auto, auto, auto),
        align: (right, center, center, center, left),
        stroke: none,
        column-gutter: 1em,
        [对应文法], [→], [常用语言], [←], [对应自动机],
        [0型文法], [→], [短语结构语言], [←], [图灵机],
        [1型文法], [→], [上下文有关语言], [←], [线性有界自动机],
        [2型文法], [→], [上下文无关语言], [←], [下推自动机],
        [3型文法], [→], [正规（则）语言], [←], [有穷自动机],
    )
]

== 我去初音未来
=== DFA(Deterministic Finite Automaton)，确定的有穷自动机
#definition[
    所谓*确定的有穷自动机(,DFA)*,是:
    $DD = al Q,Sigma ,phi.alt, q_0,qh ar$,
    其中:
    - $Q$是有穷非空的状态集,
    - $Sigma$是有穷字母表,
    - $phi.alt: Q times Sigma -> Q$是映射,
    - $q_0 in Q,qh subset.eq Q$ 熟知的开始状态,终结状态.
]
和图灵机很像了.读者应该回忆.想不起来的去找感听
#example[
    #figure(image("/assets/image-6.png", width: 70%), caption: [来，我们来穿过这个有穷自动机去买点东西。])
]

#definition[
    *DFA的扩充.*
    如果我们记$phi.alt^star:Q times Sigma^star |-> Q , s.t.$
    + $pas(q, epsilon) = q , forall q in Q$;
    + $pas(q, a) = phi.alt(q, a),a in Sigma$;
    + $pas(q, beta) = pas(q, a alpha) = pas(pas(q, a), alpha),forall a in Sigma, alpha,beta in Sigma^star$.
    #note[也就是说把字符串从左往右拆出来一个个处理，每次$q,a arrow.r q'$。 $pas$支持原本的$phi.alt$的所有规则,这就是第二条的含义。]
    有了这个$pas$,我们就可以递归的处理形如$1100011$这样的字符串.
]
自然也有非确定有穷自动机了.区别于图灵机在$phi.alt$上规定两个路径不同,我们用poset来刻画非确定的,并且最终的终点也定义为一个集合.

=== NFA(Nondeterministic Finite Automaton)，非确定的有穷自动机
#definition[
    *非确定的有穷自动机(NFA)*,是:
    $NN = al Q,Sigma ,pas, Q_0,qh ar$,
    其中:
    - $Q$是有穷非空的状态集,
    - $Sigma$是有穷字母表,
    - $pas: Q times Sigma^star -> Q^Q$是映射,这里$Q^Q$是poset;#note[也就是说，你可以同时去不同的状态。]
        - $pas(q, epsilon)=q,forall q in Q$;
        - $pas(q, beta) = t(q,a alpha) = union.big_i t(q_i,alpha), forall a in Sigma, alpha,beta in Sigma^star$;
        - $pas(q, a) in {q_1,dots,q_n}$ .
    - $Q_0 subset.eq Q,qh subset.eq Q$ 熟知的开始状态,终结状态.
]

我们记一个自动机$FF$*接受*的语言集合是$L(FF)$.若$L(FF_1) = L(FF_2)$,则这俩自动机等价.
#example[#figure(image("/assets/image-7.png", width: 70%))]

=== FA的构造方法
模拟处理字符串，每一步都寻找在当前构造出来的部分没有的状态转换和状态。

== NFA到DFA的转换
NFA存在问题:开始状态、状态转换、$epsilon$都会带来不确定性.

如果有空串作为输入，那机器可以任意在空串代表的边连接的状态之间转移，这带来很大的不确定性。

将状态间的转换关系映射成状态子集间的转换关系，然后再将这个子集当作新的状态。
=== $ei$

+ 基础情形：
    $ P in I ,"则" P in ei $

+ 归纳情形：
    $ P in ei and epsilon "转换" al P,P' ar in pas,"则" P' in ei $


=== $I_a$子集

#definition[$I_a$ 子集][由 $I$ 中状态出发，经历一条 $a$ 弧（跳过 $a$ 弧前的任意条 $epsilon$ 弧）可到达的状态的集合称为 $J$，则

    $ I_a = epsilon"-CLOSURE"(J) $
]

#note[$ei$中的元素在某种程度上可以被视为*等价*；$I_a$ 子集可以被视为*陪集*。]

$I_a$ 能确定 NFA 中状态子集间的映射，也就是即将构造的 DFA 中状态间的映射。

=== 构造
我们假定一个$NN = al Q',Sigma' ,pas', Q_0,qh ar$,下面考察如何构造一个$DD$.
#proposition[
  考察这样的$DD = al Q, Sigma,pas,q_0,F ar$,
  - $Sigma = Sigma'$;
  - $q_0 = epsilon"-CLOSURE"(Q_0)$;
    - *注意,这里的$Q$由$Q'$ poset里的元素构成*,也就是说$Q subset.eq 2^(Q')$.
  - $forall q in Q => q in 2^(Q'). forall a in Sigma,$
    $
      pas(q, a) = epsilon"-CLOSURE"(union.big_(s in q)(pas'(s,a)))
    $
    - 新的$NN$的状态，都是是$DD$的状态构成的集合；
    - 对于$al q,a ar$的转移：让集合 $q$ 的每一个 NFA 状态 $s$ 都去读取字符$a$，各自达到新状态，然后把这些状态取并集；对这个并集再求$epsilon$闭包。
    - 再转换成 DFA 中的状态转换，直至 DFA 不再
  有新的状态产生为止。
  - $F={S|S in Q and  S inter qh eq.not diameter}$
]
#unim[这里其实蛮像通用图灵机来模拟非确定图灵机的构造的]
#example[
  这里由yyl整理
]

=== DFA的化简
目标是:对$DD$,寻找一个状态数部更多的DFA $MM,s.t.DD,MM$等价.
- 构造状态集的划分
- 取每一组中的一个状态作代表
- 删去多余死状态

下面来看如何构造划分：
#proposition([
  我们说两个*状态*$p <==> q$,说的是$p,q$分别出发识别$alpha in Sigma^star$都能halt.

  构造等价划分的方法是:$p,q$同属于一个子集合,iff,$
  forall a in Sigma,pas(p,a),pas(q,a) "到达当前划分的同一个子集合"
  $
  也就是说，如果这两个状态在任意的输入下都达到被划分的同一个子集合，那么这两个状态*等价*；否则它们应当属于不同划分。
])
#example[
  #image("/assets/image-8.png")
  化简后:
  #image("/assets/image-9.png")
  可以看到$I,J$被合并了。
]
// TODO:完整的方法

== FA与正规文法
由线性正规文法$cg[S]=chevron.l cal(V)_N,cal(V)_T,P,S chevron.r$可直接构造出一个$AA= al Q, Sigma,pas,q_0,qh ar$.
转换方法是：自己随便由文法构造出语法树，然后按照语法树顺序画图。

左线性:
- $Sigma = cv_T$;(G的终结符号集为A的字母表)
- $Q = cv_N,qh=S$;(G的开始符号为A的终结状态)
- $q_0 = {S} in.not cv_N$;(额外增加开始状态)
- $U ->W a => pas(W,a) = U$;
- $U -> a => pas(S,a) = U$;

右线性:
- $Sigma = cv_T$;
- $Q = cv_N,q_0=S$;(G的非终结符号作为A的状态，G的开始符号为A的开始状态)
- $q_h = {Z} in.not cv_N$;(额外增加终结状态)
- $U ->a W => pas(U,a) = W$; 
- $U ->a => pas(U,a) = Z$;

一定注意方向。
反过来,给定$AA$也能得到$cg[S]$。


== 正规表达式RE,FA 
#definition[
  我们称*正规表达式RE* $e in Sigma$,所有RE集合为#ce ;$e$描述的语言记作$L(e).
  $
  他满足:

- $epsilon,diameter in ce$;
- $forall a in Sigma,a in ce$;
- $e_1,e_2 in ce,$
  - $(e_1) in ce$;(为了框定优先级)
  - $e_1 e_2 in ce,L(e_1 e_2)=L(e_1)L(e_2) = {x y | x in L(e_1) and y in L(e_2)}$;
  - $e_1|e_2 in ce ,L(e_1 | e_2) = L(e_1) union L(e_2)$;
  - $e_1^star in ce , L(e_1^star) = (L(e_1))^star$.

正规表达式就是正则表达式。// 为什么要用台湾译名。
]
RE具有一系列交换律、结合律等性质,如下图.#figure(image("/assets/image-10.png",width:70%))

当然,我们想研究的是RE$=>$FA的能力.
=== Thomposon's consturction
接下来介绍如何通过RE构造FA。

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#let node-style = (
  shape: circle,
  radius: 0.28cm,
  fill: white,
  stroke: 0.7pt,
)

#let edge-style = (
  stroke: 0.7pt,
)
首先$Sigma in ce$，对于待求解的$e in ce$,构造
#fletcher.diagram(
  spacing: (1cm, 1cm),
  node((0, 0), $S$, ..node-style),
  node((1, 0), $Z$, ..node-style),
  edge((0, 0), (1, 0), $e$, "->", ..edge-style),
)即可.然后*递归的*套用下面三条规则：


// ② e1 e2
#let fig2 = fletcher.diagram(
  spacing: (1cm, 1cm),
  node((0, 0), $A$, ..node-style),
  node((1, 0), $B$, ..node-style),
  node((2, 0), $C$, ..node-style),
  edge((0, 0), (1, 0), $e_1$, "->", ..edge-style),
  edge((1, 0), (2, 0), $e_2$, "->", ..edge-style),
)

// ③ e1 | e2
#let fig3 = fletcher.diagram(
  spacing: (1cm, 1cm),
  node((0, 0), $A$, ..node-style),
  node((2, 0), $B$, ..node-style),
  edge((0, 0), (2, 0), $e_1$, "->", bend: 30deg, ..edge-style),
  edge((0, 0), (2, 0), $e_2$, "->", bend: -30deg, ..edge-style),
)

// ④ e1*
#let fig4 = fletcher.diagram(
  spacing: (1cm, 2cm),
  node((0, 0), $A$, ..node-style),
  node((1, 0), $B$, ..node-style),
  node((2, 0), $C$, ..node-style),
  edge((0, 0), (1, 0), $epsilon$, "->", ..edge-style),
  edge((1, 0), (1, 0), $e$, "->", loop-angle: 90deg, bend: 140deg, ..edge-style),
  edge((1, 0), (2, 0), $epsilon$, "->", ..edge-style),
)

#align(table(
  columns: 3,
  align: center + horizon,
  stroke: 0.4pt,
  inset: 8pt,
  // 标题行
  [*② 连接*], [*③ 选择*], [*④ 闭包*],
  // 图行
  [#fig2], [#fig3], [#fig4],
  // 文字说明行
  [$e_1 e_2$ 也是 $Sigma$ 上的 RE，], [$e_1 | e_2$ 也是 $Sigma$ 上的 RE，], [$e_1^*$ 也是 $Sigma$ 上的 RE，],
  
  [$L(e_1 e_2) = L(e_1)L(e_2)$], [$L(e_1 | e_2) = L(e_1) union L(e_2)$], [$L(e_1^*) = (L(e_1))^*$],
),center)


#let node-style = (fill: rgb("#d0eeee"), stroke: 1pt + black, inset: 3pt)
#let edge-style = (stroke: 1pt + black)

//example就可以用fletcher而不是截图来解决了


RE to FA:略


== 正规文法,RG 

正规文法中，产生式的形式为右线性和左线性.

RG到RE:
- $U ->alpha V,V -> beta ==> U = alpha beta$;
- $U -> alpha U | beta ==> U = alpha^star beta$;
- $U -> alpha | beta ==> U = alpha|beta$.