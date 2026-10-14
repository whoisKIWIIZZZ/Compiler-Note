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
我们有ACTION[q,a],這表明状态 q 面临输入符号 a 时的*动作*;GOTO[T,X],這表明状态 q 面对符号 X 时的*下一状态*.很像FA.

#definition[
    LR分析过程:(记状态栈是${q_0,dots,q_m}$,符号栈是${X_1,dots,X_m}$)
    - 根据栈顶状态$q_m$和当前输入符号$a_k$:
        - 若ACTION$[q_i,a_k] = S_j ==>$ 将$q_j$放入状态栈，$a_k$放入符号栈;
        - 若ACTION$[q_i,a_k]=r_j ,$记第$j$条产生式规则为$U->x,x"的符号个数" = m ,$
        则弹出两个栈顶的$m$个元素（删掉${q_(i-m+1),dots,q_i},{X_(i-m+1),dots,X_i}$），然后找到GOTO $[q_(i-m),U] = q_t$（也就是最新的栈顶状态和归约得到的产生式左侧符号）,写入$q_t,U$到对应栈.
        - 如果action对应着acc和空白,相对应着代表着接受和错误.
]

// 能不能别用繁体字，这太幽默了
#example[
    #figure(image("/assets/82b2eb04b8f3761d45f197b0b050d991_720.png", width: 60%), caption: [
        $S_i$表示state,$r_j$表示reduction,空白是error.GOTO裡的空白不是error,為什麼?
        // 因為,有的狀態本來就不允許有state轉化,例如規約的一些state,他只能做符號轉化而不是狀態轉化
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

    為了分析$i+i*i$,完整分析過程如下:
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
        text(weight: "bold")[步驟],
        text(weight: "bold")[分析栈],
        text(weight: "bold")[剩餘輸入],
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
    為什麼第三步變成了3?這是因為,第二步發生了r6這個reduction,我們需要根據當前state(0)去更新state.此時符號是F,查GOTO表發現是3,遂改寫.
]
// 为什么上面每一行这么松散
// 我真的觉得可以写个html模拟一下这个过程
//q wqqqqqqq



空产生式的LR(0)项目只有一个。
