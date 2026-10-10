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

自上而下的基本思想是:
- 推导层面,从开始/识别符号出发不断建立*直接推导*,最终推导出与输入符号串相同的符号串;
- 语法树层面,自上而下的构造语法树;
- 程序翻译,从$S$出发,推导出句子$L$.

== 左递归及其消除
如果遇到$U -> U y , U =>^star U y$情形,左递归带来无限循环。所以我们要让非终结符待在产物的最左边。

#note[
    我们一般用最左推导，所以我们只需要消除*左*递归.
].

#proposition([
    - 直接递归：如果有形如$A->A alpha_i|beta_j , i in {1,2,dots,n},j in {1,2,dots,m},$则
    $
        & A -> beta_j A', \
        & A' -> alpha_i A'|epsilon
    $

    - 间接递归：
    ```cpp
    for i = 1 to n:
    	for j = 1 to i-1:
    		if 存在产生式 Ai -> Aj γ && Aj -> δ1 | δ2 | ... | δk
    			把 Ai -> Aj γ 替换为：Ai -> δ1 γ | δ2 γ | ... | δk γ  # 把排在前面的已经处理过的产生式代入后面的
    		end if
    	end for
    	消除 Ai 的直接左递归
    end for
    ```
])
// 任何人都不准动上面这个代码块的缩进，谁敢动我就跟他爆了。——xhkz
#example[
    #figure(image("/assets/image-15.png", width: 70%))
]

== 回溯及其消除
如果存在$U -> alpha_i , i in {1,2,3,dots,n}, alpha_1,alpha_2,dots,alpha_n$有相同的终结首符号，那么文法分析不知道选择哪一个产生式。

// 不妨$f_i (alpha):Sigma^star -> cv_T$表示$alpha$的第$i$个字符.

#definition[
    设文法 $G = (V_N, V_T, P, S)$，$alpha, beta in (V_N union V_T)^*$，$A in V_N$。$dollar$ 是输入结束符。

    #note[$fff(alpha)$ 是 $alpha$ 能推导出的所有串的首终结符集合；若 $alpha$ 能推导出空串，则 $epsilon in fff(alpha)$。]
    $
        fff(alpha) = { a | alpha =>^* a beta, a in V_T } union { epsilon | alpha =>^* epsilon }
    $

    #note[$fo(A)$ 是可能紧跟在 $A$ 后面的终结符集合；若 $A$ 可以出现在某个句型的最右端，则结束符也属于 $fo(A)$。]
    $
        fo(A) = { a | S =>^* alpha A a beta, a in V_T } union { dollar | S =>^* alpha A }
    $
]

#proposition([
    任一形如 $U -> alpha_1 | alpha_2 | dots | alpha_n$ 的产生式满足：

    + $alpha_1, alpha_2, dots, alpha_n$ 的终结首符号集两两不相交，即
        $ op("FIRST")(alpha_i) inter op("FIRST")(alpha_j) = emptyset quad (i != j) $

    + 如果 $exists alpha_j arrow.r.double^* epsilon$ 时，文法还需要同时满足
        $ op("FIRST")(alpha_i) inter op("FOLLOW")(U) = emptyset $
        #example[
            需要上述规则，是因为：
            #figure(
                image("/assets/image-14.png", width: 60%),
                caption: [
                    $A'$和$S$产生的$B$(且同时$A'$变成空串)都可以使接下来匹配$a$。不知道这个$a$是$A'$生成的,还是后续$S$产生的$B$生成的.
                ],
            )
        ]
])



$fo$的求法：
$ op("FOLLOW")(U) = { a | S arrow.r.double^* ... U a ... , a in V_T } $

+ 对于文法的开始/识别符号 S，令 \$ in op("FOLLOW")(S);
+ $A -> alpha B beta$，则 $op("FIRST")(beta)$ 中的非 $epsilon$ 元素 属于 $op("FOLLOW")(B)$;
+ $A -> alpha B$，或$A -> alpha B beta$ 而$op("FIRST")(beta)$含有 $epsilon$，则$op("FOLLOW")(A)$ 的元素属于 $op("FOLLOW")(B)$。

结合语法树理解。
== LL(1)文法
#definition[
    从左到右扫描输入串,从开始符号生成最左推导时，对于每一个产生式$U -> alpha_1|alpha_2....|alpha_i...|alpha_n, i in {1,2,dots,n}$,如果查看U所产生的非终结符号串的第一个非终结符，就能唯一确定当前应该选择的产生式，那么我们称这种文法是LL(1)文法.
]
自然需要考虑高效的计算$fff(alpha),fo(U)$.
#proposition[
    $fff(alpha)$的求解:
    - if $alpha = X in (cv_N union cv_T)$,
        - $X in cv_T ==> fff(x) ={X};$
        - $X in cv_N , X-> a dots,a in cv_T => a in fff(X);$
        - $x in cv_N , X ->Y dots,Y in cv_N, ==> fff(Y) - {epsilon} subset fff(X)$
        - $X ->Y_1 Y_2 dots Y_k,Y_1 Y_2 dots Y_j =>^star epsilon ==> fff(Y_std.strong(j+1))-{epsilon} subset fff(X)$;当然,if$j=k ==> epsilon in fff(X)$.
    - if $alpha=X_1X_2dots X_n in (cv_N union cv_T)^star,alpha eq.not epsilon$,
        - $fff(X_1) - {epsilon} subset fff(alpha)$;
        - $X_1 X_2 dots X_j =>^star epsilon ==>fff(X_std.strong(j+1))-{epsilon} subset fff(alpha);$if$j=n==>epsilon in fff(alpha)$.
]
这里根据定义很直观,只需要解释为什么$j+1$,是因为我们总能找到一个推导,使得$X =>^star epsilon fff(Y_std.strong(j+1)) dots$.
// 写的太抽象了，需要加上人话解读
// 傻逼计院的🐴--了 绷
// SELECT集合 shoudao

#definition[SELECT集合][
    形如 $U -> alpha_1 | alpha_2 | ... | alpha_n$ 的产生式，$"SELECT"(U -> alpha)$的定义如下：

    $$$
        "SELECT"(U -> alpha)=cases("FIRST"(alpha) & "当 " alpha " 不可空", "FIRST"(alpha) union "FOLLOW"(U) & "otherwise")
    $$$
]

== 递归子程序法
- 非终结符：变成函数。
- | (或)：变成 if-else ，一个个找正在匹配的终结符在哪个FIRST集合。如果不在FIRST集合，就找FOLLOW集合。找到之后按顺序调用非终结符的处理函数或者直接匹配终结符。如果仍然找不到，就报错。
- 序列：变成顺序执行的语句。
- 终结符：直接匹配，把它吃掉。
```cpp
// 针对非终结符 U 的递归子程序，产生式 U -> x1 | x2 | ... | xn
void parse_U() {
    if (isInFirst(x1, sym))
        parse_x1();      // p(x1)
    else if (isInFirst(x2, sym))
        parse_x2();      // p(x2)
    // ... 其他候选式
    else if (isInFirst(xn, sym))
        parse_xn();      // p(xn)
    // 若U可以经过多步推导变成空串，则需要检查：如果当前符号不属于任何候选式的 First 集，检查它是否属于 U 的 Follow 集
    else if (!isInFollow(U, sym))
        error();         // 既不在 First 也不在 Follow，报错
    // 如果 sym 在 Follow(U) 中，说明 U 成功推导出了空串(ε)，此时不做任何处理，直接返回（匹配空串成功）
}
```
产生式右部按从左到右顺序依次处理非终结符，可能出现自己调用自己的情况。
#example[
    ```cpp
    // 非终结符 C 的子程序，产生式 C -> e | dC
    void parse_C() {
        if (sym == 'e') {
            match('e');    // 处理产生式 C -> e
        }
        else if (sym == 'd') {
            match('d');    // 处理产生式 C -> dC 的第1个符号
            parse_C();     // 处理产生式 C -> dC 的第2个符号（递归）
        }
        else {
            error();
        }
    }
    ```
]
