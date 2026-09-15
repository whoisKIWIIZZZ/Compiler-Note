#import "../lib.typ": *
#show: conf.with(
    author: "BJHH2005,xhkzdepartedream,kiwiizzz,Zoomy",
    title: "Principles of Compilation · chapter1",
    cover: false,
    sidebar: false,
)
// 暂时只记骨架，具体内容回去填充
= Chapter2 文法和语言的形式定义
== 形式语言知识基础
=== 程序正确性
书写正确、含义正确

=== 语言定义
语法（怎么写）、语义（这句话到底要干嘛，计算机会怎么干）、语用（用这句话会起到什么效果）

#example[`<赋值语句> ::= <变量> <赋值号> <表达式>`。

    语法：规定了必须写成 M := X + Y 这种格式。

    语义：规定了计算机要在内存里先算 X+Y，再覆盖 M 的老值。

    语用：规定了“赋值语句可用来计算和保存表达式的值”。

    这句话的意思就是：我们发明赋值语句这个东西，目的（为什么）就是为了把计算结果存下来，下次还能用（保存状态）。如果没有这个目的，我们根本不会在设计语言时发明“赋值语句”。

]

== 形式语言
只是从语法上研究语言
形式语言和编译理论中的最基本概念是符号串和符号串集合

=== 字母表
我们说一个字母表$cal(Sigma)$是一个有穷非空的集合,$a in Sigma$被称为一个*符号*,或是*元素*.

#example[
    PASCAL 语言的字母表
    26个英文字母，10 个阿拉伯数字
    20 个其它字符：`空格, +, -, *, /, =, <, >, (, ), [, ], {, }, ˊ, ,, ., ;, :, ↑ 及若干保留字(关键字)`]

#note[`<=`,`if`都视作一个符号。]

=== 符号串

*符号串$s$*：字母表中的符号所组成的任何有穷序列.
$
    s "是符号串" <== s = "Cat"(t,a),a in Sigma ,t "是符号串"
$

当然会有空串,记为$epsilon$.

#remark[*看不懂的滚回去问洋芋*.]

回忆一下，$A B = {x y | x in A , y in B}$
闭包：
#mitex(`A^* = \{\varepsilon\} \cup A \cup A^2 \cup A^3 \cup \dots`)
正闭包：
#mitex(`A^+ = A^* - \{\varepsilon\}`)


语言也呼之欲出了.$L in Sigma^n$.不用计算理论里面的定义是因为,这里没有形式化的用0和1定义每一个符号.


== 文法的形式定义
//我不听他讲了,就用ppt记笔记 是对的
#definition[终结符号与非终结符号][
    自然需要一个终止符.类比EOF,

    *终结符号*($T in cal(V)_T$)：语言的不可再分的基本符号（在语法树里，它就是叶子节点）。

    *非终结符号*($N in cal(V)_N$)：程序中可以出现的语法成分。

    #mi(`$V_T \cap V_N = \emptyset$`)
]


#let cap = mi(`\cap`)
#let cup = mi(`\cup`)

=== 产生式
//放着先


#definition[产生式][
    一个有序对$chevron.l alpha ,beta chevron.r$, 满足$alpha in (V_T cup V_N )^+,beta in (V_T cup V_N)^star$.

    被记作$alpha -> beta , alpha ::= beta$.
]
前者可以产生后者,或者说“遇到前者我们就替换它为后者”.可以把它想成“图灵机遇到纸袋上的1就擦掉它”

例如：`<标识符> → <字母> | <标识符><字母> | <标识符><数字>`

// 为什么非要分出 T 和 F？（设计精妙之处）
// 如果把规则写成 E → E + E | E * E | digit，就会出现严重歧义。比如 1 + 2 * 3，计算机不知道是先算 1+2 再乘 3，还是先算 2*3 再加 1。

// 分层的绝妙之处在于利用文法的推导顺序，强制规定了优先级：

// 加减法（E）只能连接项（T） -> 优先级最低。

// 乘除法（T）只能连接因子（F） -> 优先级较高。

// 括号和数字（F） -> 优先级最高。

文法的定义就是产生式的有穷非空集合.也很自然


=== 文法
$
    cal(G)[S] eq.delta chevron.l cal(V)_N,cal(V)_T,P,S chevron.r
$
,

$P$是产生式集合,$S$是开始符号,$ forall s in S ,exists chevron.l alpha, beta chevron.r in P, s = alpha. $

例如：
#figure(image("/assets/image.png"))
- $V_N$（抽象概念） = `{expr, term, factor}` （对应：表达式、项、因子）
- $V_T$（具体符号） = `{+, -, *, /, (, ), digit}`（数字、运算符、括号）
- $S$（起点） = `expr`
- $P$（规则书） = 下面那一大堆箭头。

#figure(image("/assets/image-2.png"))

=== 文法分类
Chomsky分类: 四种类型

0,1,2,3

0型文法 1型文法 2型文法 3型文法 短语结构文法 上下文有关文法 上下文无关文法 正规(正则)文法 Phrase Structure Grammar Context-Sensitive Grammar Context Free Grammar Regular Grammar
//@zoomy TODO:上述概念的整理 让 zmy work

对$alpha -> beta$,文法的分类在于施加额外限制:
0型文法:就是原本的定义;

1: $1 <= abs(alpha) <= abs(beta)$;

2 $alpha in cal(V)_N$;

3:线性.$A,B in cal(V)_N,a in cal(V)_T$,$ A->a "or" A->a B $是右线性,$ A->a "or" A->B a $是左线性.参考你对陪集的理解.

== 语言的形式定义

=== 推导
#definition[直接推导][
    如果 $alpha -> beta$ 是文法G的一条产生式，而 $gamma, delta$ 是 $(V_T union V_N)^*$ 中任意一个符号串，则将 $alpha -> beta$ 作用于符号串 $gamma alpha delta$ 上得到符号串 $gamma beta delta$ ，
    称符号串 $gamma beta delta$ 是符号串 $gamma alpha delta$ 的#text(fill: rgb("e53985"))[直接推导]，记为 //这红色时何意味,不妨把粗体都弄成红色
    $ gamma alpha delta => gamma beta delta $
]
// 是对的，但是晚上上科技写作的时候弄
#remark[
    - $gamma, delta$都可以是$epsilon$。
    - 从开始符号出发推导得到的符号串才是有意义的。
    - 文法范畴只涉及符号串的构成，不涉及符号串的含义，但会影响语义处理。
]

// TODO：n步推导
直接推导的逆过程称为直接归约，即由符号串 $gamma beta delta$ 可直接归约
到 $gamma alpha delta$。
