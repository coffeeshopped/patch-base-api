---
title: PatchController
---

rule::pagesGrid

  try .paged(prefix: $0.xq("prefix"), color: nil, border: nil, $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.grid($0.arr("gridLayout").xformArr(Constraint.gridRowRules))], pages: $0.x("pages"))
}),

rule::pages

  try .paged(prefix: $0.xq("prefix"), color: nil, border: nil, $0.x("builders"), effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [], pages: $0.x("pages"))
}),

rule::index

  let obj = try $0.obj(4)
  return try .index($0.x(1), label: $0.x(2), $0.fn(3), color: obj.xq("color"), border: obj.xq("border"), obj.x("builders"), effects: obj.xq("effects") ?? [], layout: obj.xq("layout") ?? [])
}),

rule::palettes

  try .palettes($0.x(1), $0.x(2), $0.x(3), $0.x(4), pasteType: $0.x(5), effects: [])
}),

rule::buildersGrid

  try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.grid($0.arr("gridLayout").xformArr(Constraint.gridRowRules))])
}),

rule::buildersSimpleGrid

  try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: [.simpleGrid(try $0.x("simpleGridLayout"))])
}),

rule::gridBuilder

  try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), [.grid($0.x("gridBuilder"))], effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [])
}),

rule::basic

  try .patch(prefix: $0.xq("prefix"), color: $0.xq("color"), border: $0.xq("border"), $0.x("builders"), effects: $0.xq("effects") ?? [], layout: $0.xq("layout") ?? [])
}),

rule::fm

Create a controller with an FM algorithm visualization component. Pass an array of ::DXAlgorithm:: that define the structure of each of the algorithms offered by the synth. The passed PatchController will be created multiple times, one for each operator in the algorithms. The final Object is for configuration (TODO).

rule::fmFn

Same as the previous rule, except a Function is passed in place of a PatchController. The Function will be called once with each index value of each operator (0 up to the number of operators minus 1), and the Function should return a PatchController.

rule::oneRow

  return try .oneRow($0.x(1), child: $0.x(2), indexMap: $0.fnq(3))
}),