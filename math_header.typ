// 数学文件头
#import "@preview/quick-maths:0.2.1": shorthands // 创建缩写
#import "@preview/cetz:0.4.0"

// 新定义符号
#let sim = symbol("∽")
#let cong = symbol("≌")
// #let subset = symbol(sym.subset.eq,
//   ("real", "⫋"),
//   ("not", sym.subset.eq.not)
// )
//
// #let supset = symbol(sym.supset.eq,
//   ("real", "⫌"),
//   ("not", sym.supset.eq.not)
// )


#let rttriangle = $"Rt"triangle$
#let rad = "rad"
#let qed = block(width: 100%, align(right, sym.square.stroked)) // QED
#let vecL(L) = math.accent(L, math.arrow.r.long) // 矢量字母, 这里取手写表示, 更好看些并具有容易辨认
// 圆弧字母
#let arcL(L, left: 0.4em, right: 0.4em) = {
  //math.overparen(L)
  h(left)
  math.overparen({
    h(-left)
    L
    h(-right)
  })
  h(right)
}

#let sh_symbol = (
  // 缩写
  ($+-$, $plus.minus$),
  ($-+$, $minus.plus$),
  ($sim=$, $cong$),
  ($=<$, $arrow.l.double$),
  ($=/>$, $arrow.r.double.not$),
  // ($=>$, $arrow.r.double$)
)
#let math_symbol_template(doc) = {
  // show math.equation: set text(font: "STIX Two Math") // 设置字体
  show: shorthands.with(..sh_symbol) // 修改缩写
  // 修改符号
  show sym.gt.eq: sym.gt.eq.slant // 符合国标
  show sym.lt.eq: sym.lt.eq.slant // 符合国标
  show sym.sum: math.limits(sym.sum)
  show sym.product: math.limits(sym.product)
  show sym.subset: sym.subset.eq
  show sym.subset.neq: "⫋"
  show sym.subset.not: sym.subset.eq.not
  show sym.supset: sym.supset.eq
  show sym.supset.neq: "⫌"
  show sym.supset.not: sym.supset.eq.not
  set math.cancel(inverted: true)

  doc
}

#let math_equation_template(num: "(1)", recount_head: 2, doc) = {
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      // Override equation references.
      link(el.location(), "公式" + numbering(num, ..counter(math.equation).at(el.location())))
    } else {
      // Other references as usual.
      it
    }
  }
  
  show heading.where(level: recount_head): it => {
    // 重置公式计数器位置
    counter(math.equation).update(0)
    // counter(math.equation).step(level: 0)
    it
  }
  set math.equation(numbering: num)
  // show math.equation: it => it + [#[ #[]<eq-end>]]
  show math.equation.where(block: true): it => {
    // 数学公式居中, 虽然效果没那么好, 以及减少间隔
    // set par(leading: 15em)
    if it.has("label") {
      //if "/"  in str(it.label) {
      //  counter(math.equation).update(n => n - 1)
      //  math.equation(it.body, block: true, numbering: none)
      //  return
      //} else
      if "::" in str(it.label) {
        let (a, b) = str(it.label).split("::")
        counter(math.equation).update(n => n - 1)
        [#math.equation(it.body, block: true, numbering: _ => "(" + b + ")")#label(a)]
        return
      }
    }
    if not it.has("label") {
      let fields = it.fields()
      let _ = fields.remove("body")
      fields.numbering = none
      it = [#counter(math.equation).update(v => v - 1)#math.equation(..fields, it.body)<math-equation-without-label>]
    }
    (
      block(
        width: 100%,
        inset: 1pt,
        align(center, it),
        //spacing: 1.5em,
      )
        + [#[ #[]<eq-end>]]
    )
  }
  show par: it => {
    if it.first-line-indent.amount == 0pt {
      // Prevent recursion.
      return it
    }

    context {
      let eq-end = query(selector(<eq-end>).before(here())).at(-1, default: none)
      if eq-end == none { return it }
      if eq-end.location().position() != here().position() { return it }

      // Paragraph start aligns with end of last equation, so recreate
      // the paragraph, but without indent.
      let fields = it.fields()
      let body = fields.remove("body")
      return par(
        ..fields,
        first-line-indent: 0pt,
        body,
      )
    }
  }
  doc
}

#let proff(..eqs) = {
  if eqs.pos().len() == 1 {
    eqs.pos().at(0)
  } else {
    enum(..eqs.pos())
  }
}

// #let num_lable_eq_template(eq) = {
//   // 只对有标签的公式编号
//   show math.equation.where(block: true): it => {
//     if not it.has("label") {
//       let fields = it.fields()
//       let _ = fields.remove("body")
//       fields.numbering = none
//       [#counter(math.equation).update(v => v - 1)#math.equation(..fields, it.body)<math-equation-without-label>]
//     } else {
//       it
//     }
//   }
//   eq
// }
// #set heading(numbering: "1.")
// #let ct=counter("eq")
// #set math.equation(numbering: it=>ct.display("(1-1.a)"))
// #show heading.where(level: 1): it=>it+ct.step()+ct.step(level: 2)
// #show math.equation.where(block: true): it=>{
//   it
//   if it.numbering !=none{
//     if ct.get().len()==2{
//       ct.step(level: 2)
//     }
//   }
// }
// #let eq_nonum(body)={
//   set math.equation(numbering: none)
//   body
// }
// #let subeqs(..args)={
//   for eq in args.pos(){
//     ct.step(level: 3)
//     eq
//   }
//   ct.step(level: 2)
// }
//
// #let _prepare-dict(it, level, zero-fill, leading-zero, numbering) = {
//   let numbers = counter(heading).at(it.location())
//   // if zero-fill is true add trailing zeros until the level is reached
//   while zero-fill and numbers.len() < level { numbers.push(0) }
//   // only take the first `level` numbers
//   if numbers.len() > level { numbers = numbers.slice(0, level) }
//   // strip a leading zero if requested
//   if not leading-zero and numbers.at(0, default: none) == 0 {
//     numbers = numbers.slice(1)
//   }
//
//   let dic = it.fields()
//   let _ = if "body" in dic { dic.remove("body") }
//   let _ = if "label" in dic { dic.remove("label") }
//   let _ = if "counter" in dic { dic.remove("counter") }
//   dic + (numbering: n => _typst-numbering(numbering, ..numbers, n))
// }
//
// #let show-equation(
//   it,
//   level: 1,
//   zero-fill: true,
//   leading-zero: true,
//   numbering: "(1.1)",
//   // prefix: "eqt:",
//   // only-labeled: false,
//   unnumbered-label: "-",
// ) = {
//   if (
//     only-labeled and not it.has("label")
//     or it.has("label") and (
//       str(it.label).starts-with(prefix)
//       or str(it.label) == unnumbered-label
//     )
//     or not it.block
//   ) {
//     it
//   } else {
//     let equation = math.equation(
//       it.body,
//       .._prepare-dict(it, level, zero-fill, leading-zero, numbering),
//     )
//     // if it.has("label") {
//     //   let new-label = label(prefix + str(it.label))
//     //   [#equation #new-label]
//     // } else {
//     //   let new-label = label(prefix + _prefix + "no-label")
//     //   [#equation #new-label]
//     // }
//   }
// }
