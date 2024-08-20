//
//  PBBezier.PathCommand.swift
//  PBJS
//
//  Created by Chadwick Wood on 8/15/24.
//

import PBAPI

extension PBBezier.PathCommand: JsParsable, JsArrayParsable {
  
  static let jsParsers: JsParseTransformSet<Self> = try! .init([
    (["move", ".n", ".n"], {
      .move(to: CGPoint(x: try $0.x(1) as CGFloat, y: try $0.x(2)))
    }),
    (["line", ".n", ".n"], {
      .addLine(to: CGPoint(x: try $0.x(1) as CGFloat, y: try $0.x(2)))
    }),
    (["scale", ".n", ".n"], {
      .apply(.identity.scaledBy(x: try $0.x(1) as CGFloat, y: try $0.x(2)))
    }),
  ])
  
  static let jsArrayParsers = try! jsParsers.arrayParsers()
}
