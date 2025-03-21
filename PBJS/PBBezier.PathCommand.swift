//
//  PBBezier.PathCommand.swift
//  PBJS
//
//  Created by Chadwick Wood on 8/15/24.
//

import PBAPI

extension PBBezier.PathCommand: JsParsable {
  
  static let jsRules: [JsParseRule<Self>] = [
    .a(["move", ".n", ".n"], {
      try .move(to: CGPoint(x: $0.x(1) as CGFloat, y: $0.x(2)))
    }),
    .a(["line", ".n", ".n"], {
      try .addLine(to: CGPoint(x: $0.x(1) as CGFloat, y: $0.x(2)))
    }),
    .a(["scale", ".n", ".n"], {
      try .apply(.identity.scaledBy(x: $0.x(1) as CGFloat, y: $0.x(2)))
    }),
    .a(["curve", ".n", ".n", ".n?"], {
      try .addWeightedCurve(to: CGPoint(x: $0.x(1) as CGFloat, y: $0.x(2)), weight: $0.xq(3) ?? 0)
    })
  ]
  
}
