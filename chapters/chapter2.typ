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
// 暂时只记骨架，具体内容回去填充
= Chapter2 文法和语言的形式定义
== 形式语言知识基础
=== 程序正确性

程序正确性包含两层含义：
- 书写正确：指合乎语法规则，编写的代码并不出现 Syntax Error
- 含义正确：指能够*正确理解与应用*程序中各种语法成分的语义定义、在逻辑上体现了程序书写者的意图，因而在正确地输入数据之后，就能获得预期的运行效果。简单来说，就是使计算机 do what you want

=== 语言定义

语言包含三个方面：
- 语法（怎么写）
- 语义（这句话到底要干嘛，计算机会怎么干）
- 语用（用这句话会起到什么效果）

#example[
    以`<赋值语句> ::= <变量> <赋值号> <表达式>`为例：

    - 语法：规定了必须写成 M := X + Y 这种格式。

    - 语义：规定了计算机要在内存里先算 X+Y，再覆盖 M 的老值。

    - 语用：规定了“赋值语句可用来计算和保存表达式的值”。

    （这句话的意思就是：我们发明赋值语句这个东西，目的（为什么）就是为了把计算结果存下来，下次还能用（保存状态）。如果没有这个目的，我们根本不会在设计语言时发明“赋值语句”。）
]

==== 语法(syntax)

语法是由基本符号组成程序中各个语法成分（包括最大的语法成分“程序”）的一组规则。

- 词法规则：由基本符号构成符号(单词)的书写规则
- 语法规则：由符号(单词)构成语法成分的规则

==== 语义(semantics)

语义是各个语法成分的意义，也就是各语法成分在运行阶段被计算机执行时所做的工作及其结果。

- 静态语义：编译时刻可确定的语法成分含义
- 动态语义：运行时刻才能确定的语法成分含义

==== 语用

语用是表示语言符号及其使用者之间的关系，涉及符号的来源、使用和影响，比如程序的设计风格。

#unim[作为一种编程范式/设计方法论，面向对象程序设计（OOP）就是一种典型的语用。]

== 形式语言

#definition[形式语言][形式描述用一组数学符号和规则来描述语言的方式，而形式语言是所用的数学符号和规则。]

形式语言只是从语法上研究语言，其中最基本概念是符号串和符号串集合。
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

#definition[终结符号与非终结符号][
    *终结符号*($T in cal(V)_T$)：语言的不可再分的基本符号（在语法树里，它就是叶子节点）。

    *非终结符号*($N in cal(V)_N$)：程序中可以出现的语法成分。

    #mi(`$V_T \cap V_N = \emptyset$`)
]


#let cap = mi(`\cap`)
#let cup = mi(`\cup`)

=== 产生式
//放着先


#definition[产生式][
    一个有序对$chevron.l alpha ,beta chevron.r$, 满足$alpha in (V_T cup V_N )^+,beta in (V_T cup V_N)^star$.记作$alpha -> beta , alpha ::= beta$.
]
前者可以产生后者,或者说“遇到前者我们就替换它为后者”.可以把它想成“图灵机遇到纸袋上的1就擦掉它”

例如：`<标识符> → <字母> | <标识符><字母> | <标识符><数字>`



文法的定义就是产生式的有穷非空集合.也很自然


=== 文法
$
    cal(G)[S] eq.delta chevron.l cal(V)_N,cal(V)_T,P,S chevron.r
$


$P$是产生式集合,$S$是开始符号,$ forall s in S ,exists chevron.l alpha, beta chevron.r in P, s.t. s = alpha. $

#example[
    #figure(image("/assets/image.png"))
    - $V_N$（抽象概念） = `{expr, term, factor}` （对应：表达式、项、因子）
    - $V_T$（具体符号） = `{+, -, *, /, (, ), digit}`（数字、运算符、括号）
    - $S$（起点） = `expr`
    - $P$（规则书） = 下面那一大堆箭头。

    #unim[
        为什么非要分出 T 和 F？

        如果把规则写成 `E → E + E | E * E | digit`，就会出现严重歧义。比如 `1 + 2 * 3`，计算机不知道是先算 1+2 再乘 3，还是先算 `2*3` 再加 1。分层利用文法的推导顺序，强制规定了优先级：

        - 加减法（E）只能连接项（T） -> 优先级最低。
        - 乘除法（T）只能连接因子（F） -> 优先级较高。
        - 括号和数字（F） -> 优先级最高。
    ]

    #figure(image("/assets/image-2.png", width: 70%))
]
=== 文法分类

区别在于：对产生式规则在形式上施加了不同的限制。

#table(
    columns: (auto, auto, auto, auto),
    align: (center, left, left, left),
    table.header([*类型*], [*中文名* \ *英文名*], [*形式限制*], [*特点*]),

    [0型文法],
    [短语结构文法 \ Phrase Structure Grammar],
    [$alpha arrow.r beta$，\ $alpha in (V_N union V_T)^+$，$beta in (V_N union V_T)^*$],
    [左边有非终结符就行],

    [1型文法],
    [上下文有关文法 \ Context-Sensitive Grammar],
    [$alpha arrow.r beta$，$1 <= abs(alpha) <= abs(beta)$，\ $alpha in (V_N union V_T)^+$，$beta in (V_N union V_T)^*$],
    [左边长度不能大于右边（除了S→ε），不能越变越少],

    [2型文法],
    [上下文无关文法 \ Context Free Grammar],
    [$A arrow.r beta$，$A in V_N$，$beta in (V_N union V_T)^*$],
    [左边永远只能是一个孤零零的抽象概念（非终结符）。\ 如 `<赋值语句> → <变量> = <表达式>`。

        只要看到 `<赋值语句>`，不管它前面是什么，后面是什么，都可以直接替换成右边的形式。],

    [3型文法],
    [正规（正则）文法 \ Regular Grammar],
    [右线性：$A arrow.r a$ 或 $A arrow.r a B$；\ 左线性：$A arrow.r a$ 或 $A arrow.r B a$。\ $A, B in V_N$，$a in V_T$],
    [右边只能是一个具体符号，或者一个具体符号+一个抽象概念。],
)

// 右线性、左线性，参考你对陪集的理解。

=== 文法类的关系

0型 $supset$ 1型 $supset$ 2型 $supset$ 3型。

#figure(image("/assets/image-4.png", width: 50%))


== 语言的形式定义

=== 推导
#definition[直接推导][
    如果 $alpha -> beta$ 是文法G的一条产生式，而 $gamma, delta$ 是 $(V_T union V_N)^*$ 中任意一个符号串，则将 $alpha -> beta$ 作用于符号串 $gamma alpha delta$ 上得到符号串 $gamma beta delta$ ，
    称符号串 $gamma beta delta$ 是符号串 $gamma alpha delta$ 的*直接推导*，记为
    $ gamma alpha delta => gamma beta delta $
]

#remark[
    - $gamma, delta$都可以是$epsilon$。这样定义的好处在于能兼容上下文有关文法。
    - 从开始符号出发推导得到的符号串才是有意义的。
    - 文法范畴只涉及符号串的构成，不涉及符号串的含义，但会影响语义处理。
]

// TODO：n步推导
直接推导的逆过程称为直接归约，即由符号串 $gamma beta delta$ 可直接归约
到 $gamma alpha delta$。

考虑
$alpha_0,dots,alpha_n in (cv_T cup cv_N)^star,$且$alpha_0 ==> alpha_1 ==> dots alpha_(n-1) ==> alpha_n$,
可以简记成n步推导,$alpha_0 =>^+ alpha_n$.如果$n=0$,还能写成$alpha_0 =>^star alpha_n$.


然后由一连串定义
#definition[
    - $cg[S] = al cv_N,cv_T,P,S ar and S =>^star u$,则称$u$是文法$cg[S]$的*句型*.
    - 进一步,$u in cv_T^*$,它是$cg[S]$的*句子*.
    - $L(cg[S]) eq.delta {u|S =>^star u and u in cv_T^*}$是$cg$产生的*语言*.
]


=== 为语言构造文法

给定一个$L$,我们构造$cg[S]$.
#example[
    $L(cg[S])={ \(^n \)^n|n in RR^+},$找到#cg.

    显然$\(\)和 epsilon$都会被生成.归纳的发现,$S ->(S)$也可以,这样就凑好了
    $
        cg[S] = al {S},{(,)},P,S ar, \
        P = {S -> (S)|epsilon}.
    $
]


=== 语法树
#definition[
    考虑这样的对应$cg[S] = al cv_N,cv_T,P,S ar$的树:
    - 每个结点都有标记$m in cv_N cup cv_T$;
    - $m_"root"=S$;
    - 若结点有后继,标记不能属于$cv_T$;
    - 若标记为A的结点有${X_i}$的后继,则$A->X_1 X_2 dots X_n in P$.相应的,$A -> epsilon =>$A只有$epsilon$的子节点.
    这叫做一个文法$cg$的*语法树*.
]

#figure(align(center, image("/assets/image-3.png", width: 40%)), caption: [
    $cg[E]:E->E+T|T quad T->T*F|F quad F->(E)|i$
])


有什么用?
- 考虑$u$是句型,那么它是一棵语法分析树的末端结点从左向右构成的符号串;
- 考虑$u$是句子,那么它是一棵语法分析树的末端结点从左向右构成的终结符号串;
- $L$是语法分析树生成的终结符号串的集合.


当然同一个符号串可以用不同序列推导.考虑*最左*和*最右*的,就是每一次推导中,替换*最左边*或者*最右边*的那一个.

=== 递归
#definition[
    - $U -> x U y , x,y in(cv_N cup cv_T)^*$,称作*直接递归*;
    - $U =>^star x U y$,称作*文法递归*,*间接递归*.
    - $U -> x U$,左递归(同理左间接递归);同理右.
]

好处:
- 运算符结合顺序问题,左(右)结合在文法中体现为左(右)递归.
- 运算符优先级:语法树的高层或底层

=== 问题
- 二义性
- 压缩
- \@ zmy 解决
