#import "../lib.typ": *
#show: conf.with(
    author: "BJHH2005,xhkzdepartedream,kiwiizzz,Zoomy",
    title: "Principles of Compilation · chapter1",
    cover: false,
    sidebar: false,
)
#show strong: set text(fill: rgb("e53985"))
#let cv = $cal(V)$
#let ce = $cal(E)$
#let cg = $cal(G)$
#let al = $chevron.l$
#let ar = $chevron.r$
#let cd = $cal(D)$
#let qh = $Q_"halt"$
#let pas = $phi.alt^star$
#let ei = $epsilon"-CLOSURE"$
#let fff = $"FIRST"$
#let fo = $"FOLLOW"$
= Chapter5 语法分析:自下而上

== 移进-归约
一种自下而上分析方法的实现技术，引进一个后进先出的栈来存放符号。

按照扫描顺序把当前输入符号下推入栈中(移进)，然后查看栈顶的符号串是否可以被归约。
// @zoomy's task here
// ok, but I am learning it on ppt

四种动作：
+ 移进（shift）：读入下一个输入，符号压入符号栈、状态压入状态栈，输入指针后移。
+ 归约（reduce）：把栈顶符号串替换为相应的非终结符号。如果当前栈顶是某个产生式的右部，那就弹出完整的右部并把产生式左部压入符号栈，使用新的栈顶查询 `GOTO` 表得到新的状态并压入状态栈。这一步不移动指针。
+ 接受（accept）：当栈顶除\$外仅有识别符号，输入为\$时，结束工作。
+ 报错（error）：ACTION 表里没有合法动作，说明输入不符合文法，调用出错处理子程序处理或停止工作。

#note[通俗易懂的解释：这个过程就像拼积木。移进就是拿起下一块零件放到工作台上，归约就是把当前能组合的零件组合起来，接受就是“我拼完啦”，报错就是“无法拼好”。]


#definition[短语、直接短语、句柄][
    + 设有文法$G[Z]$，$w=x U y$是它的一个句型，如果有

        $ Z =>^* x U y quad 且 quad U =>^+ u $

        称句型$x U y$中子串u为句型$x U y$相对于非终结符号$U$的*短语*。

        #note[$Z$经过任意步推导得到$x U y$后，$U$能变成子串$u$，也就是$u$是句型中$U$产生的所有符号，则称u为句型$x u y$（注意是$x u y$而不是$x U y$）相对于非终结符号$U$的短语。]

    + 特别地，如果前述条件中 $U =>^+ u$ 为 $U => u$（一步推导）则称$u$为句型$x U y$的直接(简单)短语。

    + 句型的最左直接短语称为句柄(Handles)。
]

#example[
    #image("/assets/image-19.png")

]





== LR
我们有ACTION[q,a],这表明状态 q 面临输入符号 a 时的*动作*;GOTO[T,X],这表明状态 q 面对符号 X 时的*下一状态*.很像FA.

#definition[
    LR分析过程:(记状态栈是${q_0,dots,q_m}$,符号栈是${X_1,dots,X_m}$)
    - 根据栈顶状态$q_m$和当前输入符号$a_k$:
        - 若ACTION$[q_i,a_k] = S_j ==>$ 将$q_j$放入状态栈，$a_k$放入符号栈;
        - 若ACTION$[q_i,a_k]=r_j ,$记第$j$条产生式规则为$U->x,x"的符号个数" = m ,$
        则弹出两个栈顶的$m$个元素（删掉${q_(i-m+1),dots,q_i},{X_(i-m+1),dots,X_i}$），然后找到GOTO $[q_(i-m),U] = q_t$（也就是最新的栈顶状态和归约得到的产生式左侧符号）,写入$q_t,U$到对应栈.
        - 如果action对应着acc和空白,相对应着代表着接受和错误.
]

#example[
    #figure(image("/assets/82b2eb04b8f3761d45f197b0b050d991_720.png", width: 60%), caption: [
        $S_i$表示state,$r_j$表示reduction,空白是error.GOTO里的空白不是error,为什么?
        // 因为,有的状态本来就不允许有state转化,例如规约的一些state,他只能做符号转化而不是状态转化
    ])
    文法是$cg[E]:$
    $
        & 1 quad quad quad E->E+T \
        & 2 quad quad quad E->T \
        & 3 quad quad quad T->T*F \
        & 4 quad quad quad T->F \
        & 5 quad quad quad F ->(E) \
        & 6 quad quad quad F ->i
    $

    为了分析$i+i*i$,完整分析过程如下:
    #let c(text) = box(
        fill: luma(235),
        inset: (x: 5pt, y: 2pt),
        radius: 3pt,
        raw(text),
    )

    #table(
        columns: (auto, auto, auto, auto),
        align: (center + horizon, left + horizon, left + horizon, left + horizon),
        stroke: none,
        row-gutter: 1em,
        column-gutter: 1.5em,

        // 表头
        text(weight: "bold")[步骤],
        text(weight: "bold")[分析栈],
        text(weight: "bold")[剩余输入],
        text(weight: "bold")[ACTION],

        // 数据行
        [1], c("0"), c("i+i*i$"), raw("s5"),
        [2], c("0 i 5"), c("+i*i$"), raw("r6: F→i"),
        [3], c("0 F 3"), c("+i*i$"), raw("r4: T→F"),
        [4], c("0 T 2"), c("+i*i$"), raw("r2: E→T"),
        [5], c("0 E 1"), c("+i*i$"), raw("s6"),
        [6], c("0 E 1 + 6"), c("i*i$"), raw("s5"),
        [7], c("0 E 1 + 6 i 5"), c("*i$"), raw("r6: F→i"),
        [8], c("0 E 1 + 6 F 3"), c("*i$"), raw("r4: T→F"),
        [9], c("0 E 1 + 6 T 9"), c("*i$"), raw("s7"),
        [10], c("0 E 1 + 6 T 9 * 7"), c("i$"), raw("s5"),
        [11], c("0 E 1 + 6 T 9 * 7 i 5"), c("$"), raw("r6: F→i"),
        [12], c("0 E 1 + 6 T 9 * 7 F 10"), c("$"), raw("r3: T→T*F"),
        [13], c("0 E 1 + 6 T 9"), c("$"), raw("r1: E→E+T"),
        [14], c("0 E 1"), c("$"), raw("acc"),
    )
    为什么第三步变成了3?这是因为,第二步发生了r6这个reduction,我们需要根据当前state(0)去更新state.此时符号是F,查GOTO表发现是3,遂改写.
]
// 为什么上面每一行这么松散
// 我真的觉得可以写个html模拟一下这个过程


空产生式的LR(0)项目只有一个。

== 状态转移图的构造
// @ysz 请补充本节的完整内容。包括活前缀的定义、LR(0)项目、核心项目与派生项目、DFA构造的形式化规则，以及一个类似 demos 中html的可视化例子。
=== 活前缀

文法中的产生式 $A -> X Y Z$ 表示完整推导。分析时是逐个符号识别，因此用圆点 $·$ 表示当前识别进度。

*LR(0) 项目*：带有圆点的产生式，例如：

$ A -> · X Y Z $

$ A -> X · Y Z $

$ A -> X Y Z · $

其中：

- 圆点左边：已经识别出来的部分；
- 圆点右边：期待看到的部分。



=== 从项目集到 DFA
// 假设I为文法的任一项目集(开始时仅包含S'→.S，S'为文法的识别符
// 号)，重复下述步骤求CLOSURE(I)：
// + I的任何项目均属于CLOSURE(I)
// + 如果A→α.Bβ属于CLOSURE(I)，则所有B→.γ也属于CLOSURE(I)。
// 上述工作重复到CLOSURE(I)不再扩大为止，此CLOSURE(I)即为所求的一个项目子集，将其作为DFA的一个状态。
#table(
    columns: 4,
    inset: 6pt,
    align: (left, left, left, left),
    [*项目类型*], [*形态特征*], [*含义*], [*对应动作*],
    [移进项目], [点后是终结符，如 $·a$], [等下一个符号], [移进],
    [待约项目], [点后是非终结符，如 $·B$], [等推导], [需加入闭包],
    [归约项目], [点在末尾，如 $·$], [识别完毕], [归约（可能冲突）],
)




== LR(0)分析表的构造与冲突
设当前状态为 $I_i$。

+ 移进：若 $I_i$ 中有项目 $A -> alpha . a beta$，且沿终结符 $a$ 转移到 $I_j$，则：
    $ "ACTION"[i, a] = S_j $
+ 状态转换：若沿非终结符 $A$ 转移到 $I_k$，则：
    $ "GOTO"[i, A] = k $
+ 接受：若 $I_i$ 中包含 $S' -> S .$，则：
    $ "ACTION"[i, \$] = "acc" $
+ 归约：若 $I_i$ 中有项目 $A -> alpha .$，LR(0) 规定对所有终结符和 \$ 都填：
    $ "ACTION"[i, a] = r_j $
    其中 $j$ 是用产生式 $A -> alpha$ 归约的编号。

#definition[LR(0) 文法][
    能构造出无冲突 LR(0) 分析表的文法，称为 *LR(0) 文法*。
]
绝大多数实用编程语言不能仅靠 LR(0) 处理。

=== 移进-归约冲突
#example[
    ```
    G[S]:
    S' -> E
    E -> E + T | T
    T -> T * F | F
    F -> ( E ) | i
    ```
    同时包含：
    $ E -> E + T · $
    $ T -> T · * F $
    - $E -> E + T ·$：圆点在末尾，要求归约；
    - $T -> T · * F$：圆点后有 `*`，要求移进。
    若下一个输入符号是 `*`，同一个格子既要填移进 $S$，又要填归约 $r$，即*移进-归约冲突*。]

=== 归约-归约冲突
#example[若同一状态中有：
    $ A -> alpha · $
    $ B -> alpha · $
    两个项目都要求归约，即*归约-归约冲突*。
]

=== SLR(1)
