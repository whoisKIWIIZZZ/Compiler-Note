// ==========================================================
// 兼容融合模板：notes.bak.typ 的正文模板与 lib.typ 的侧栏模板
// ==========================================================

// --- 两个旧模块导出的依赖并集 ---
#import "@preview/numbly:0.1.0": numbly
#import "@preview/thmbox:0.3.0": *
#import "@preview/thmbox:0.3.0": note as thmbox-note
#import "@preview/hydra:0.6.2": hydra
#import "@preview/in-dexter:0.7.2": *
#import "@preview/i-figured:0.2.4"
#import "@preview/cetz:0.5.2"
#import "@preview/mitex:0.2.7": *
#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/marginalia:0.3.1" as marginalia
#import "@preview/marginalia:0.3.1": wideblock

// --- 状态与注释组件 ---
#let _sidebar-state = state("_sidebar-state", true)
#let _note-style-state = state("_note-style-state", "thmbox")
#let a-note-counter = counter("a-note")
// lib.typ 中的侧栏/内联注释。需要显式使用时可写 #margin-note[...]。
#let margin-note(body) = context {
  if _sidebar-state.get() {
    rect(
      fill: luma(79.46%),
      radius: 3pt,
      inset: 5pt,
      stroke: none,
      marginalia.note(
        counter: a-note-counter,
        numbering: (..i) => text(
          weight: 500,
          font: ("Consolas", "SimSun"),
          size: 7pt,
          fill: rgb("#ff3a3a"),
          numbering("[a]", ..i),
        ),
        body,
      ),
    )
  } else {
    a-note-counter.step()
    let marker = a-note-counter.display("[a]")
    box(
      fill: luma(240),
      radius: 2pt,
      inset: (x: 4pt, y: 3pt),
      baseline: 0%,
    )[
      #text(weight: 500, font: "JetBrains Mono", size: 7pt, fill: rgb("#ff3a3a"), marker)
      #text(size: 9pt, fill: luma(100), body)
    ]
  }
}

// #note 默认保持 notes.bak.typ 的 thmbox 语义；conf(note-style: "margin")
// 或 #show: use-margin-notes 时可将它切换为 lib.typ 的边注语义。
// thmbox 的 note 支持 #note[title][body] 和样式命名参数；lib 的边注只接受
// 一个正文位置参数，因此后者仅在调用形态完全匹配时启用。
#let note(..args) = context {
  let thmbox-form = args.pos().len() != 1 or args.named().len() != 0
  if thmbox-form or _note-style-state.get() != "margin" {
    thmbox-note(..args)
  } else {
    margin-note(..args)
  }
}
#let mnote = margin-note
#let use-margin-notes(body) = {
  _note-style-state.update("margin")
  body
}
#let use-thmbox-notes(body) = {
  _note-style-state.update("thmbox")
  body
}

#let abstract = thmbox-note.with(
  variant: "Abstract",
  color: purple,
)

#let appendix(body) = {
  set heading(numbering: "A.1")
  show heading.where(level: 1): it => {
    let nos = counter(heading).at(it.location())
    let letter = numbering("A", ..nos)
    block(sticky: true)[
      #text(weight: "bold", size: 1.2em)[Appendix #letter #it.body]
    ]
  }
  body
}

#let unim(body) = {
  block(
    fill: luma(93.73%),
    width: 100%,
    inset: (x: 1em, y: 1em),
    radius: 4pt,
    breakable: true,
    [
      #set text(fill: luma(120), size: 0.95em)
      #body
    ],
  )
}

// 用于独立索引页；在侧栏布局中让索引跨越正文和边栏宽度。
#let print-index(
  title: "索引",
  column-count: 2,
  outlined: true,
  use-page-counter: true,
  ..args,
) = context {
  let was-sidebar = _sidebar-state.get()
  let inner = [
    #if title != none {
      heading(title, level: 1, numbering: none, outlined: outlined)
    }
    #if column-count > 1 {
      columns(column-count)[#make-index(
        title: none,
        outlined: false,
        use-page-counter: use-page-counter,
        ..args,
      )]
    } else {
      make-index(
        title: none,
        outlined: false,
        use-page-counter: use-page-counter,
        ..args,
      )
    }
  ]
  pagebreak()
  _sidebar-state.update(false)
  if was-sidebar {
    wideblock(side: "both")[#inner]
  } else {
    inner
  }
}

// ======================================================
// 主配置函数：lib.typ 的 conf 加上 notes.bak.typ 的选项
// ======================================================

#let conf(
  title: "您的文档标题",
  subtitle: "",
  author: "作者姓名",
  date: datetime.today().display("[year]年[month]月[day]日"),
  header-title: none,
  header-chapter: none,
  font: ("New Computer Modern", "SimSun"),
  font-size: 10pt,
  paper: "a4",
  margin: (top: 2.5cm, left: 1.5cm, right: 1.5cm, bottom: 1.5cm),
  heading-numbering: numbly("第{1}章", "{1}.{2}节", "{1}.{2}.{3}", "({5:a})"),
  sidebar: true,
  sidebar-width: 50mm,
  sidebar-sep: 5mm,
  clearance: 10pt,
  book: true,
  header-use-hydra: false,
  page-numbering: none,
  show-footer: false,
  footer-pattern: none,
  roman-pages: none,
  note-style: "margin",
  cover: true,
  body,
) = {
  let font-list = if type(font) == str { (font,) } else { font }
  set text(font: font-list, size: font-size, lang: "zh")
  set par(first-line-indent: 0em, justify: true, leading: 0.65em)
  set block(spacing: 1.2em)
  set heading(numbering: heading-numbering)
  show figure.where(kind: "thmbox"): set block(breakable: true)
  show: thmbox-init(counter-level: 3)
  show: show-cn-fakebold
  context {
    _sidebar-state.update(sidebar)
    _note-style-state.update(note-style)
  }
  
  if cover {
    page(numbering: none, header: none, footer: none, margin: margin)[
      #set align(center)
      #set par(first-line-indent: 0em)
      #v(20%)
      #text(size: 32pt, weight: "bold")[#title]
      #if subtitle != "" [#v(0.5em); #text(size: 18pt, fill: luma(100))[#subtitle]]
      #v(4cm)
      #text(size: 16pt)[#author]
      #v(1em)
      #text(size: 14pt, fill: luma(80))[#date]
    ]
    pagebreak()
    counter(page).update(1)
  }
  
  show: if sidebar {
    marginalia.setup.with(
      inner: (far: margin.left, width: 0pt, sep: 0pt),
      outer: (far: margin.right, width: sidebar-width, sep: sidebar-sep),
      top: margin.top,
      bottom: margin.bottom,
      book: book,
      clearance: clearance,
    )
  } else { x => x }
  let header-left = context {
    if header-use-hydra {
      if calc.odd(here().page()) { emph(hydra(1)) } else { emph(hydra(2)) }
    } else if header-title != none {
      smallcaps(header-title)
      text(fill: luma(60%))[_ #if header-chapter != none { header-chapter } _]
    } else { [] }
  }
  
  let footer-box(content) = context {
    if not sidebar {
      content
    } else {
      let pad-x = sidebar-width + sidebar-sep
      if book and calc.odd(here().page()) {
        pad(right: pad-x, content)
      } else if book {
        pad(left: pad-x, content)
      } else {
        pad(right: pad-x, content)
      }
    }
  }
  
  let footer-content = context {
    let p = here().page()
    set text(size: 9pt, fill: luma(80))
    if roman-pages != none and p < roman-pages.at(0) {
      []
    } else if roman-pages != none and p <= roman-pages.at(1) {
      align(center, counter(page).display("I"))
    } else if footer-pattern != none {
      align(center, counter(page).display(footer-pattern))
    } else {
      align(center, counter(page).display("1"))
    }
  }
  
  let page-args = if sidebar {
    (
      paper: paper,
      numbering: page-numbering,
      header: context {
        marginalia.header(
          text-style: (size: 11.5pt, font: font-list),
          [],
          header-left,
          [Page #counter(page).display("1 of 1", both: true)],
        )
      },
      footer: if show-footer { context { footer-box(footer-content) } } else { none },
    )
  } else {
    (
      paper: paper,
      margin: margin,
      numbering: page-numbering,
      header: if header-use-hydra {
        context {
          set text(size: 11.5pt, font: ("JetBrains Mono","Consolas",) + font-list)
          if calc.odd(here().page()) {
            align(right, header-left)
          } else {
            align(left, header-left)
          }
          line(length: 100%)
        }
      } else {
        context {
          set text(size: 11.5pt, font: font-list)
          align(left + horizon)[
            #header-left
            #h(1fr)
            Page #counter(page).display("1 of 1", both: true)
          ]
        }
      },
      footer: if show-footer { context { footer-content } } else { none },
    )
  }
  set page(..page-args)
  
  show math.equation: i-figured.show-equation.with(only-labeled: true, level: 2)
  show math.equation: set text(font: ("New Computer Modern Math",) + font-list, black)
  show raw.where(block: false): it => {
    set text(font: ("Consolas", "SimSun"))
    box(fill: luma(240), inset: (x: 3pt), radius: 2pt, it)
  }
  show raw.where(block: true): it => {
    set text(font: ("Consolas", "SimSun"))
    block(
      fill: luma(252),
      stroke: 0.5pt + luma(200),
      radius: 6pt,
      width: 100%,
      clip: true,
      stack(
        dir: ttb,
        block(fill: luma(240), width: 100%, inset: 8pt, text(weight: "bold", size: 8pt, upper(it.lang))),
        block(width: 100%, inset: 12pt, it),
      ),
    )
  }
  show heading: it => {
    it
    par(text(size: 0pt, ""))
  }
  
  body
}

// ======================================================
// notes.bak.typ 兼容入口
// ======================================================

#let notes(
  font: "Source Han Serif SC",
  margin: (top: 2.5cm, left: 1.5cm, right: 1.5cm, bottom: 1.5cm),
  font-size: 12pt,
  paper: "a4",
  heading-numbering: numbly(
    "第{1}章",
    "{1}.{2}节",
    "{1}.{2}.{3}",
    "{1}.{2}.{3}.{4}",
    "({5:a})",
  ),
  footer-pattern: "北郊HH——1——计算机网络",
  roman-pages: (3, 4),
  sidebar: false,
  header-use-hydra: true,
  show-footer: true,
  page-numbering: "1",
  cover: false,
  note-style: "thmbox",
  body,
) = conf(
  font: font,
  margin: margin,
  font-size: font-size,
  paper: paper,
  heading-numbering: heading-numbering,
  footer-pattern: footer-pattern,
  roman-pages: roman-pages,
  sidebar: sidebar,
  header-use-hydra: header-use-hydra,
  show-footer: show-footer,
  page-numbering: page-numbering,
  cover: cover,
  note-style: note-style,
  body,
)
