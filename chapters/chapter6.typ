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
= Chapter6 语义分析和语法制导翻译
== 语法制导翻译简介

=== 引入：为什么语义分析程序需要语法制导？
语法分析程序只能分析结构，无法分析除了结构以外的任何东西。

例如：文法 `E → E + T | T，T → digit`。它的全部本领是判断 `3+5*2` 这种串是否合语法。

但是它不知道`+`是加法（可以被解释成and/or）、`3`就是3（可以被解释成别的数）。因此，想让它算出 13，必须做两件人为的事：*指定某个位置放结果，再指定合成方式*。这就是属性和语义规则。


=== 语法制导翻译的基本思想

#definition[属性文法(Attribute Grammar)][
    为每个文法符号指定一组属性；为每个产生式附加一段属性计算方法。
]

#example[
    #table(
        columns: 2,
        align: (center, left),

        [*产生式*], [*语义规则*],
        [L → En], [L.val = E.val],
        [E → E₁ + T], [E.val = E₁.val + T.val],
        [E → T], [E.val = T.val],
        [T → T₁ \* F], [T.val = T₁.val $times$ F.val],
        [T → F], [T.val = F.val],
        [F → (E)], [F.val = E.val],
        [F → digit], [F.val = digit.lexval],
    )
]





附注(annotated)语法树 / 注释分析树

属性是“我们要求编译器记住的东西”的清单，清单本身由人规定。

属性文法的语义规则有固定格式：。。。

=== 语法制导定义

定义与文法符号相关联的属性集；
定义与产生式相关联的一组语义规则

=== (语法制导的)翻译方案(syntax-directed translation scheme, SDT)

把一些额外的内容挂靠在之前的语法分析过程（将程序片段附加到文法各个产生式右部的合适位置），使得随着语法分析的进行能得到一些关于最后产生的终结符串的“性质”。

==

