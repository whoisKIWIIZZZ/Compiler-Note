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

== FA
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
        - 再转换成 DFA 中的状态转换，直至 DFA 不再有新的状态产生为止。
    - $F={S|S in Q and S inter qh eq.not diameter}$
]
#unim[这里其实蛮像通用图灵机来模拟非确定图灵机的构造的]
#example[
    #figure(image("/assets/image-11.png", width: 60%))
]

=== DFA的化简
目标是:对$DD$,寻找一个状态数部更多的DFA $MM,s.t.DD,MM$等价.
- 构造状态集的划分
- 取每一组中的一个状态作代表
- 删去多余死状态

下面来看如何构造划分：
#proposition([
    我们说两个*状态*$p <==> q$,说的是$p,q$分别出发识别$alpha in Sigma^star$都能halt.

    构造等价划分的方法是:$p,q$同属于一个子集合,iff,$ forall a in Sigma,pas(p, a),pas(q, a) "到达当前划分的同一个子集合" $
    也就是说，如果这两个状态在任意的输入下都达到被划分的同一个子集合，那么这两个状态*等价*；否则它们应当属于不同划分。
])

#algorithm[DFA的化简][
    - 构成初始划分 $pi_0$
        - 将 $Q$ 划分为两个子集：终态子集和非终态子集，记作 $pi_0 = { Q_1, Q_2, dots, Q_n }$。
    - 对 $pi_k$ 按下述方法构造新的划分 $pi_(k+1)$
        - for $pi_k$ 中的每一子集 $Q_i$ do
            - 划分 $Q_i$，使得状态 $p$、$q$ 并入 $pi_k$ 的同一子集，iff $forall a in Sigma$，$t(p,a)$ 和 $t(q,a)$ 都到达 $pi_k$ 的同一子集中；否则，对 $Q_i$ 进行划分，使 $p$ 和 $q$ 属于划分后的不同子集；
            - 将经上述划分后的子集并入 $pi_(k+1)$。
    - 若 $pi_(k+1) eq.not pi_k$，则用 $pi_(k+1)$ 替代 $pi_k$，重复上述过程；否则，划分过程终止。

    最终划分记作 $pi_i$。化简后的 DFA $M'$ 中：

    #table(
        columns: (auto, 1fr),
        align: (center, left),
        table.header([组成], [取法]),
        [$Q'$], [$Q'$ 的状态数即最终划分 $pi_i$ 的子集个数。取 $pi_i$ 中每个子集中的一个状态代表该子集。],
        [$q_0'$], [$pi_i$ 中含 $q_0$ 的子集。],
        [$F'$], [包含 $F$ 中任一状态的子集的代表状态的集合。],
        [$Sigma'$], [$Sigma' = Sigma$。],
        [$t'$], [$pi_i$ 中子集到子集（代表状态）之间的转换；子集中其它状态的转换关系全部转换到代表状态上。],
        [不可达状态], [去掉不可达状态。],
    )
]


#example[
    #grid(
        columns: (1fr, 1fr),
        column-gutter: 1em,
        image("/assets/dfa-minimize-before.png", width: 100%), image("/assets/dfa-minimize-after.png", width: 100%),
    )

    $
        pi_1 = { Q_1 = {F, G, H}, quad Q_2 = {I, J} } \
        because quad Q_1 "中"：quad t(F, 1)=G in Q_1, quad t(G, 1)=H in Q_1, quad t(H, 1)=J in Q_2, \
        therefore quad "分解" Q_1 "为" Q_11 = {F, G}, quad Q_12 = {H} \
        "得" pi_2 = { Q_11 = {F, G}, quad Q_12 = {H}, quad Q_2 = {I, J} } \
        because quad Q_11 "中"：quad t(F, 0)=G in Q_11, quad t(G, 0)=I in Q_2, \
        therefore quad "将" Q_11 "分割成" Q_111={F}, quad Q_112={G} \
        "得" pi_3 = { Q_111 = {F}, quad Q_112 = {G}, quad Q_12 = {H}, quad Q_2 = {I, J} } \
        because quad Q_2 "中"：quad t(I, 0)=I in Q_2, quad t(J, 0)=I in Q_2, quad t(I, 1)=J in Q_2, quad t(J, 1)=J in Q_2, \
        therefore quad I "和" J "等价。" quad "最终划分为" pi_3 "。"
    $
]


== FA与正规文法
由线性正规文法$cg[S]=chevron.l cal(V)_N,cal(V)_T,P,S chevron.r$可直接构造出一个$AA= al Q, Sigma,pas,q_0,qh ar$.
转换方法是：自己随便由文法构造出语法树，然后按照语法树顺序画图。

#table(
    columns: (auto, 1fr, 1fr),
    align: (center, left, left),
    stroke: 0.5pt + luma(70%),
    inset: 6pt,
    table.header([*项目*], [*右线性*], [*左线性*]),
    [文法], [$A arrow.r a A | 0 B$ \ $B arrow.r b B | b$], [$A arrow.r A a | B 0$ \ $B arrow.r B b | b$],
    [字母表], [$Sigma = cv_T$], [$Sigma = cv_T$ \ (G的终结符号集为A的字母表)],
    [状态集], [$Q = cv_N$ \ (G的非终结符号作为A的状态)], [$Q = cv_N$ \ (G的非终结符号作为A的状态)],
    [初态], [$q_0 = S$ \ (G的开始符号为A的开始状态)], [$q_0 = {S} in.not cv_N$ \ (额外增加开始状态)],
    [终态], [$q_h = {Z} in.not cv_N$ \ (G的开始符号为A的终结状态)], [$q_h = S$ \ (额外增加终结状态)],
    [转移],
    [$U -> a W => pas(U, a) = W$ \ $U -> a => pas(U, a) = Z$],
    [$U -> W a => pas(W, a) = U$ \ $U -> a => pas(S, a) = U$],

    [图示],
    [#align(center, image("/assets/qq_pic_left.jpg", width: 65%))],
    [#align(center, image("/assets/qq_pic_right.jpg", width: 65%))],
    // 不是告诉你用flec那个包嘛
)

一定注意方向。
反过来,给定$AA$也能得到$cg[S]$。


== 正规表达式RE,FA
#definition[
    我们称*正规表达式RE* $e in Sigma$,所有RE集合为#ce ;$e$描述的语言记作$L(e).$
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
RE具有一系列交换律、结合律等性质：

设$A$、$B$、$C$均为正规表达式，则有下列关系成立：

#enum(
    numbering: "(1)",
    [$A | B = B | A$],
    [$A | (B | C) = (A | B) | C$],
    [$A (B C) = (A B) C$],
    [$A (B | C) = A B | A C quad (B | C) A = B A | C A$],
    [$epsilon A = A epsilon = A$],
    [$(A^star)^star = A^star$],
    [$A^star = epsilon | A A^star$],
    [$(A B)^star A = A (B A)^star$],
    [$(A | B)^star = (A^star B^star)^star = (A^star | B^star)^star$],
    [$A = b | a A$ 当且仅当 $A = a^star b$],
)

当然,我们想研究的是RE$=>$FA的能力.
=== Thomposon's consturction：如何通过RE构造FA

#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
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

#align(
    table(
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
    ),
    center,
)


#let node-style = (fill: rgb("#d0eeee"), stroke: 1pt + black, inset: 3pt)
#let edge-style = (stroke: 1pt + black)

=== FA $==>$ RE
逐个删除中间结点。

所有原本“穿过”它的路径，现在都得绕过它，这就必然会产生新的边，故新边的标签必须融合原来的信息。

先从度数小的节点开始。

=== 正规文法,RG

正规文法中，产生式的形式为右线性和左线性.

RG到RE:
- $U ->alpha V,V -> beta ==> U = alpha beta$;
- $U -> alpha U | beta ==> U = alpha^star beta$;
- $U -> alpha | beta ==> U = alpha|beta$.
// TODO


== DFA的程序实现
#figure(image("/assets/image-12.png",width:60%))
- 查表：拿着拼好的 name 去符号表里查。如果是关键字（int, if），返回标记类型 1；如果是普通变量名，返回标记类型 2。
- 回退指针：只有读了下一个单词的开始才能知道这个单词结束了。
    - 比如读 `int a=10`;。为了确认 `a` 这个单词结束，机器必须再往下读一个字符 `=`。读到 `=` 发现不是字母数字，机器知道 `a` 结束了，但是 `=` 已经被读进来了。所以必须把指针退回去，把 `=` 留给下一轮循环去处理。
== 词法分析程序

单词形式：类别+属性值

类别：保留字/关键字、标识符、常数、运算符、界限符

单词的属性值：反映单词符号特征或特性的值，可以是指向符号表的指针

一类一码：把单词按大类给个统一的编号。比如：所有变量（标识符）统一编号为 1，所有数字（常数）统一编号为 2。
一符一码：每一个具体的符号，都发一个编号。比如：if 编号 3，then 编号 4，while 编号 6。

=== 符号表
简化语法分析器，通常把标识符当作终结符号 id 或 i;常量当作终结符号 num 或 d
```cpp
count = count +12;
//count 就被分析成<id,"count">
//12 => <num,12>
```
经过词法分析之后的词法单元序列会被加入到符号表. 

我不想阅读符号表的定义作用生存期

=== 词法分析程序的设计
+ 预处理：如删除注释、空格、回车换行符之类非必要信息。
  - 缓冲区环