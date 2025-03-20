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
      .move(to: CGPoint(x: try $0.x(1) as CGFloat, y: try $0.x(2)))
    }),
    .a(["line", ".n", ".n"], {
      .addLine(to: CGPoint(x: try $0.x(1) as CGFloat, y: try $0.x(2)))
    }),
    .a(["scale", ".n", ".n"], {
      .apply(.identity.scaledBy(x: try $0.x(1) as CGFloat, y: try $0.x(2)))
    }),
  ]
  
}
