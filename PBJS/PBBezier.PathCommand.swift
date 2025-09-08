//
//  PBBezier.PathCommand.swift
//  PBJS
//
//  Created by Chadwick Wood on 8/15/24.
//

import PBAPI

extension PBBezier.PathCommand: JsParsable {
  
  public static let jsRules: [JsParseRule<Self>] = [
    .a("move", [Float.self, Float.self], {
      try .move(to: CGPoint(x: $0.x(1) as CGFloat, y: $0.x(2)))
    }),
    .a("line", [Float.self, Float.self], {
      try .addLine(to: CGPoint(x: $0.x(1) as CGFloat, y: $0.x(2)))
    }),
    .a("scale", [Float.self, Float.self], {
      try .apply(.identity.scaledBy(x: $0.x(1) as CGFloat, y: $0.x(2)))
    }),
    .a("curve", [Float.self, Float.self], optional: [Float.self], {
      try .addWeightedCurve(to: CGPoint(x: $0.x(1) as CGFloat, y: $0.x(2)), weight: $0.xq(3) ?? 0)
    })
  ]
  
}
