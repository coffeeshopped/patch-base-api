//
//  PBBezier.PathCommand.swift
//  PBJS
//
//  Created by Chadwick Wood on 8/15/24.
//

import PBAPI

extension PBBezier.PathCommand: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a("move", [CGFloat.self, CGFloat.self], {
      try .move(to: CGPoint(x: $0.x(1) as CGFloat, y: $0.x(2)))
    }),
    .a("line", [CGFloat.self, CGFloat.self], {
      try .addLine(to: CGPoint(x: $0.x(1) as CGFloat, y: $0.x(2)))
    }),
    .a("scale", [CGFloat.self, CGFloat.self], {
      try .apply(.identity.scaledBy(x: $0.x(1) as CGFloat, y: $0.x(2)))
    }),
    .a("curve", [CGFloat.self, CGFloat.self], optional: [CGFloat.self], {
      try .addWeightedCurve(to: CGPoint(x: $0.x(1) as CGFloat, y: $0.x(2)), weight: $0.xq(3) ?? 0)
    })
  ]
  
}
