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
= Chapter4 语法分析:自上而下
== 什么是语法分析
依据语法规则分析词法分析得到的单词串,确定
- 单词是怎样组成声明和语句 
- 声明和语句又是怎样组成程序的 
如果不合规就报错

自上而下的基本思想是:1)推导层面,从开始/识别符号出发不断建立*直接推导*,最终推导出与输入符号串相同的符号串;2)语法树层面,自上而下的构造语法树;3)程序翻译,从$S$出发,推导出句子$L$.

== 从两个问题出发
=== 递归 
如果遇到$U -> U y , U =>^star U y$情形,这会带来无限循环#note[
注意推导是最左推导,所以我们只需要消除*左*递归.
]. 我们需要消除左递归.

#proposition([
  - 如果有形如$A->A alpha_i|beta_j , i in {1,2,dots,n},j in {1,2,dots,m},$那么考虑
  $
  &A -> beta_j A',\  
  &A' -> alpha_i A'|epsilon
  $
  那么直接递归被消除了.

  如果是间接递归,考虑
  ```cpp
  for i = 1 to n:
    for j = 1 to i-1:
        若存在产生式 Ai -> Aj γ and Aj -> δ1 | δ2 | ... | δk
        则把 Ai -> Aj γ 替换为：
        Ai -> δ1 γ | δ2 γ | ... | δk γ

    消除 Ai 的直接左递归
  ```
])
#example[

]

== 回溯
如果存在$U -> alpha_i , i in {1,2,3,dots,n}, alpha_1,alpha_2,dots,alpha_n$有相同的终结首符号,那么文法分析是不知道选择哪一个$alpha_i$的.不妨$f_i (alpha):Sigma^star -> cv_T$表示$alpha$的第$i$个字符.

#proposition([
  避免回溯的条件:$U -> alpha_i , i in {1,2,3,dots,n}$满足:
  - $fff(alpha_i) eq.delta {a|alpha_i =>^star a dots and a in cv_T}$,且$fff(alpha_i)$两两不相交.当然$epsilon in fff(alpha_i) "iff" alpha_i =>^star epsilon$;
  - $fo(U) eq.delta{a|S =>^star dots U a dots,a in cv_T}$,且$a_j =>^star epsilon ==> fff(alpha_j) ∩ fo(U) = diameter$.
])
容易看出第二个条件是为什么而构造.
#figure(
  image("/assets/image-14.png"),
  caption:[
    不知道这个a是$A'$生成的,还是后续S->B生成的.
  ]
)