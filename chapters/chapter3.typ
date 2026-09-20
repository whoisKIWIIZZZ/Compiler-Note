#import "../lib.typ": *
#show: conf.with(
    author: "BJHH2005,xhkzdepartedream,kiwiizzz,Zoomy",
    title: "Principles of Compilation · chapter1",
    cover: false,
    sidebar: false,
)
#show strong: set text(fill: rgb("e53985"))

#let cv = $cal(V)$
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
    $ P in ei and epsilon "转换" P -> P' in pas,"则" P' in ei $


=== $I_a$子集

#definition[$I_a$ 子集][由 $I$ 中状态出发，经历一条 $a$ 弧（跳过 $a$ 弧前的任意条 $epsilon$ 弧）可到达的状态的集合称为 $J$，则

    $ I_a = epsilon"-CLOSURE"(J) $
]

#note[$ei$中的元素在某种程度上可以被视为*等价*；$I_a$ 子集可以被视为*陪集*。]

$I_a$ 能确定 NFA 中状态子集间的映射，也就是即将构造的 DFA 中状态间的映射。
