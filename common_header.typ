// 通用文件头

#let par-indent = 2em
#let list-indent = 0.5em


#let template(doc) = {
  // 文档模板

  // 文档编号
  show heading.where(level: 1): it => {
    // pagebreak()
    set align(center)
    counter(footnote).update(0) // 设在页眉和页脚会导致大面积空白
    it
  }
  show heading.where(level: 4): it => {
    // 特殊设置
    set text(size: 12pt)
    it
  }
  set heading(numbering: (..nums) => {
    // if nums.pos().len() == 1 { "§ 1." } else
    if nums.pos().len() >= 4 {
      numbering("1:", ..nums.pos().slice(3))
    } else {
      numbering("§ 1.1.", ..nums)
    }
  })

  // 字体
  set text(font: "Noto Serif CJK SC")
  show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif CJK SC"))

  // 排版
  set par(first-line-indent: (amount: 2em, all: true))
  set quote(block: true)
  set table(align: (center + horizon))
  set enum(numbering: "1)")
  // 与段落缩进相同, 但子项使用别的缩进
  set enum(indent: par-indent)
  set list(indent: par-indent)
  let sub-item-indent(body) = {
    set enum(indent: list-indent)
    set list(indent: list-indent)
    body
  }
  show enum: sub-item-indent
  show list: sub-item-indent
  show table: it => {
    align(
      center,
      it,
    )
  }
  // set page(
  //   //margin: (top: 32pt, bottom: 20pt),
  //   footer: [#counter(footnote).update(0)], // 单页脚注计数
  // )

  // 神奇全角字母
  show "／": "/"
  show "＼": "\\"
  show "．": "."
  show "＿": "_"
  show "｛": "}"
  show "｝": "}"
  show "Ａ": "A"
  show "Ｂ": "B"
  show "Ｃ": "C"
  show "Ｄ": "D"
  show "Ｅ": "E"
  show "Ｆ": "F"
  show "Ｇ": "G"
  show "Ｈ": "H"
  show "Ｉ": "I"
  show "Ｊ": "J"
  show "Ｋ": "K"
  show "Ｌ": "L"
  show "Ｍ": "M"
  show "Ｎ": "N"
  show "Ｏ": "O"
  show "Ｐ": "P"
  show "Ｑ": "Q"
  show "Ｒ": "R"
  show "Ｓ": "S"
  show "Ｔ": "T"
  show "Ｕ": "U"
  show "Ｖ": "V"
  show "Ｗ": "W"
  show "Ｘ": "X"
  show "Ｙ": "Y"
  show "Ｚ": "Z"

  doc
}

#let en2ch_point_dict = (
  "\\.\\s*": "。",
  "\\,\\s*": "，",
)

#let auto_chinese_point_text(it) = {
  for (pat, replacement) in en2ch_point_dict {
    // 在每次迭代时更新it以同时保存之前的show规则
    it = {
      show regex(pat): replacement
      it
    }
  }
  it
}

// #let auto_chinese_point_enum(it) = {
//   show enum.item: it => {
//     if it.has("label") and it.label == <processed> {
//       return it
//     }
//     let new = enum.item(it.number, {
//       show text: it => {
//         show: auto_chinese_point_text
//         it
//       }
//       show enum.item: it => {
//         show: auto_chinese_point_enum
//         it
//       }
//       it
//     })
//     [#new<processed>]
//   }
//   it
// }

#let auto_chinese_point(doc) = {
  // 将正文中的英文标点修改为中文标点
  show par: it => {
    // 常规段落
    show text: it => {
      show: auto_chinese_point_text
      it
    }
    it
  }

  show list: it => {
    // 无序列表
    if it.has("label") and it.label == <processed> {
      return [1] //it
    }
    show text: it => {
      show: auto_chinese_point_text
      it
    }
    it
  }

  // #let s = state("replace-2-3", false)
  // #show enum: it => s.update(false) + it  // this is the fix
  // #show enum.item: it => {
  //   if it.has("label") and it.label == <processed> {
  //     return it
  //   }
  //   let new = enum.item(it.number, {
  //     show "2": it => context if s.get() { "3" } else { it }
  //     s.update(true)
  //     it.body
  //     s.update(false)
  //   })
  //   [#new<processed>]
  // }
  show enum: it => {
    if it.has("label") and it.label == <processed> {
      return it
    }
    show text: it => {
      show: auto_chinese_point_text
      it
    }
    it
  }
  doc
}

#let default_around_symbol_left = "{"
#let default_around_symbol_right = "}"

#let split_words(split_symbol, around_symbol_left, around_symbol_right, ..arg, around: false) = {
  [ ]
  if around {
    around_symbol_left
    arg.pos().join(" " + split_symbol + " ")
    around_symbol_right
  } else {
    arg.pos().join(split_symbol)
  }
  [ ]
}

#let both(..arg, around: false) = split_words(
  "&",
  default_around_symbol_left,
  default_around_symbol_right,
  around: around,
  ..arg,
)

#let either(..arg, around: false) = split_words(
  "/",
  default_around_symbol_left,
  default_around_symbol_right,
  around: around,
  ..arg,
)

// Check is a file has been included
#let check_label(label) = { query(label) != () }

#let safelink(label_in, description) = {
  context {
    if check_label(label_in) {
      // 如果文件已经包含，创建链接
      link(label_in, description)
    } else {
      // 如果文件未包含
      description
    }
  }
}

#let check_path(path) = {
  // 保证以不同方式表示的路径最终显示相同
  let path_list = path.split("/")
  let output = (path_list.at(0),)
  for i in range(1, path_list.len()) {
    if path_list.at(i) == ".." {
      let temp = output.pop()
    } else if path_list.at(i) == "." {} else {
      output.push(path_list.at(i))
    }
  }
  output.join("/")
}

#let sum_items(items) = {
  let output = items.at(0)
  for i in items.slice(1) {
    output = output + i
  }
  output
}

#let no_auto(item, replace) = {
  if item == auto {
    replace
  } else {
    item
  }
}

#let no_auto_2em(x) = no_auto(x, 2em)

#let eg = $e.g.$

//#let outline_offset(offset: 1, outline_label: <outline_main>, doc) = {
//  context {
//     if check_label(outline_label) {
//       set heading(offset: offset)
//       doc
//     } else { doc }
//   }
// }

#let definitions = state("definitions", ())

#let def(it) = {
  definitions.update(def => (..def, it))
  [#it#label(it.text)]
}

#let definitions_template(doc) = {
  show: body => context definitions.final().fold(body, (body, def) => {
    show def.text: it => link(label(def.text))[#it]
    body
  })
}

