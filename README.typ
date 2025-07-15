#import "/lib/header/common_header.typ": *
#show: template

= 头文件使用

== 通用头文件

即`common_header.typ`

+ `template`: 通用模板, 可直接使用, 必须在所有文件中使用.
  - 设置一级标题居中, 同时重置脚注编号.
  - 设置四级标题特殊编号(`1:`), 特殊设置.
  - 使用"Noto Serif CJK SC"和"New Computer Modern Math"字体.
  - 段落受行缩进2个字符, 有序和无序列表与其并列.
  - `quote(block: true)`.
  - 表格项同时竖直和水平居中.
  - 替换掉全角字符.
+ `auto_chinese_point`: 可直接使用, 自动将正文中的英文标点修改为中文标点. 包括句号, 逗号.
+ `split_words(split_symbol, around_symbol_left, around_symbol_right, ..arg[, around: false])`:
输入左右符号, 使用分割符号将内容分割,`around`为`false`时左右符号不显示.
+ #both(`both(@{a}, @{b}, ...[, around: true])`, `either(@{a}, @{b}, ...[, around: true])`): 使用范围见规范.
  - 调用时格式为`func(@{a}, @{b}, ...[, around: true])`或`func([around: true])[@{a}][@{b}]...`. #both(`@{a}`, `@{b}`, `...`)的类型均为#either(`str`,`content`, "...")\(即文本). `around`参数为`true`时外部有括号. 使用第二种形式调用时#both(`@{a}`, `@{b}`, `...`)外部需用中括号`[]`环绕
+ `safelink`: 安全链接, 当标签未包含时不会显示错误.
  - 调用格式: `safelink(label_in, description)`
    - `label_in`: 标签
    - `description`: 描述
+ `check_path(path) -> str`: 将所有实际指向同一文件的路径转为同一字符串.
+ `def(it)`: 使一段字符串自动在全文替换为链接. 需同时使用`definitions_template`模板.

== 数学头文件

即`math_header.typ`, 参考中国国标.

+ 修改符号(需启用模板`math_symbol_template`): QED(自动显示在右侧且为空心正方形), 大于等于, 小于等于, 求和(数学公式默认变为`limits(sum)`), 累乘(数学公式默认变为`limits(product)`), 子集(变为`subset.eq`), 不为子集(变为`subset.eq.not`), 真子集(变认为⫋), 超集(变为`supset.eq`), 不为超集(变为`supset.eq.not`), 真超集(变为⫌), 删除线从左到右
+ 添加符号(自动导入): 相似(`sim`), 全等(`cong`), 直角三角形(`rttriangle`), QED(自动显示在右侧)(`qed`), 手写体矢量字母`vecL(L)`, 圆弧字母符号(`arcL(L)`)
+ 缩写(需启用模板`math_symbol_template`): 加减(`+-`), 减加(`-+`), 全等(`sim=`), 左箭头(`=<`), 否定箭头(`=/>`)
+ `math_equation_template([num: "(1)"][, recount_head: 2][, ref_eq: "公式"], doc)`: 数学公式模板
  - `num`: 数学公式编号方式
  - `recount_head`: 在第几级标题重置公式计数
  - `ref_eq`引用公式时的描述
  - 只有带有标签的公式会被编号
  - 在有序列表和无序列表中的公式也会居中显示
  - 公式不会导致段落显示被截断