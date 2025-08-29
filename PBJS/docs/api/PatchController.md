---
title: PatchController
---

<rule>
{
  builders: [::PatchController.Builder::],
  pages: ::PatchController.PageSetup::,
  gridLayout": ".a",
  prefix: ::PatchController.Prefix::,
  effects: [::PatchController.Effect::],
}
</rule>

  try .paged(prefix: $0.xq("prefix"), color: nil, border: nil, $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.grid($0.arr("gridLayout").xformArr(Constraint.gridRowRules))], pages: $0.x("pages"))
}),

<rule>
{
  pages: ".a",
  builders: ".a",
  prefix" : ".x?",
  effects" : ".x?",
  layout" : ".x?",
}
</rule>
  try .paged(prefix: $0.xq("prefix"), color: nil, border: nil, $0.x("builders"), effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [], pages: $0.x("pages"))
}),

<rule>["index", ".p", ".p", ".f", ".d"]</rule>

  let obj = try $0.obj(4)
  return try .index($0.x(1), label: $0.x(2), $0.fn(3), color: obj.xq("color"), border: obj.xq("border"), obj.x("builders"), effects: obj.xq("effects") ?? [], layout: obj.xq("layout") ?? [])
}),

<rule>["palettes", ".d", ".n", ".p", ".s", ".s"]</rule>

  try .palettes($0.x(1), $0.x(2), $0.x(3), $0.x(4), pasteType: $0.x(5), effects: [])
}),

<rule>
{
  builders: ".a",
  gridLayout: ".a",
}
</rule>

  try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.grid($0.arr("gridLayout").xformArr(Constraint.gridRowRules))])
}),

<rule>
{
  builders: ".a",
  simpleGridLayout: ".a",
}
</rule>

  try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.simpleGrid(try $0.x("simpleGridLayout"))])
}),

<rule>
{
  gridBuilder: ".a",
  prefix: ".x?",
  color: ".x?",
  border: ".x?",
  effects: ".x?",
  layout: ".x?",
}
</rule>

  try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), [.grid($0.x("gridBuilder"))], effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [])
}),

<rule>
{
  builders: ".a",
}
</rule>

  try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [])
}),
<rule>["fm", ".a", ".x", ".d"]</rule>

  let config = try? $0.obj(3)
  let algoPath: SynthPath? = try config?.xq("algo")
  let reverse: Bool? = try config?.xq("reverse")
  let selectable: Bool? = try config?.xq("selectable")
  if $0.atIndex(2).isFn {
    return try .fm($0.x(1), opCtrlr: $0.fn(2), algoPath: algoPath, reverse: reverse, selectable: selectable)
  }
  else {
    return try .fm($0.x(1), $0.x(2), algoPath: algoPath, reverse: reverse, selectable: selectable)
  }
}),
<rule>["oneRow", ".n", ".d", ".f?"]</rule>

  return try .oneRow($0.x(1), child: $0.x(2), indexMap: $0.fnq(3))
}),