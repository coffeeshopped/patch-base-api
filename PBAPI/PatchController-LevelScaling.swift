
public extension PatchController.Display {
  
  enum LevelScalingCurve: Int {
    case negativeLinear = 0
    case negativeExponential = 1
    case positiveExponential = 2
    case positiveLinear = 3
  }

  static func levelScaling() -> Self {
    var layers = [PatchController.DisplayLayer]()
    
    layers.append(.l([.x], stroke: .label, dashPattern: [2,3], { values in
      var cmds = [PBBezier.PathCommand]()

      // draw a horizontal line in the center
      cmds.append(.move(to: CGPoint(x: 0, y: 0.5)))
      cmds.append(.addLine(to: CGPoint(x: 1, y: 0.5)))
      
      return cmds
    }))
    
    layers.append(.l([.y], stroke: .label, { values in
      var cmds = [PBBezier.PathCommand]()

      let breakX = values[[.brk, .pt]] ?? 0
      cmds.append(.move(to: CGPoint(x: breakX, y: 0)))
      cmds.append(.addLine(to: CGPoint(x: breakX, y: 1)))
      
      return cmds
    }))
    
    layers.append(.l([.level], stroke: .value, lineWidth: 3, { values in
      var cmds = [PBBezier.PathCommand]()

      let breakX = values[[.brk, .pt]] ?? 0
      let breakY = 0.5
      let leftCurve = LevelScalingCurve(rawValue: Int(values[[.left, .curve]] ?? 0)) ?? .negativeLinear
      let rightCurve = LevelScalingCurve(rawValue: Int(values[[.right, .curve]] ?? 0)) ?? .negativeLinear
      let leftDepth = values[[.left, .depth]] ?? 0
      let rightDepth = values[[.right, .depth]] ?? 0

      // draw left curve
      cmds.append(.move(to: CGPoint(x: breakX, y: breakY)))
      let leftCtrl = CGPoint(x: 0.25 * breakX, y: breakY)
      switch leftCurve {
        case .negativeLinear:
        cmds.append(.addLine(to: CGPoint(x: 0, y: breakY * (1.0 - leftDepth))))
        case .negativeExponential:
        cmds.append(.addCurve(to: CGPoint(x: 0, y: breakY * (1.0 - leftDepth)),
                          controlPoint1: leftCtrl,
                          controlPoint2: leftCtrl))
        case .positiveExponential:
        cmds.append(.addCurve(to: CGPoint(x: 0, y: breakY * (1.0 + leftDepth)),
                          controlPoint1: leftCtrl,
                          controlPoint2: leftCtrl))
        case .positiveLinear:
        cmds.append(.addLine(to: CGPoint(x: 0, y: breakY * (1.0 + leftDepth))))
      }
    
      // draw right curve
      cmds.append(.move(to: CGPoint(x: breakX, y: breakY)))
      let rightCtrl = CGPoint(x: breakX + 0.75 * (1 - breakX), y: breakY)
      switch rightCurve {
        case .negativeLinear:
          cmds.append(.addLine(to: CGPoint(x: 1, y: breakY * (1.0 - rightDepth))))
        case .negativeExponential:
          cmds.append(.addCurve(to: CGPoint(x: 1, y: breakY * (1.0 - rightDepth)),
                          controlPoint1: rightCtrl,
                          controlPoint2: rightCtrl))
        case .positiveExponential:
          cmds.append(.addCurve(to: CGPoint(x: 1, y: breakY * (1.0 + rightDepth)),
                          controlPoint1: rightCtrl,
                          controlPoint2: rightCtrl))
        case .positiveLinear:
          cmds.append(.addLine(to: CGPoint(x: 1, y: breakY * (1.0 + rightDepth))))
      }
      
      return cmds
    }))
    
    return .flex(layers)
  }
}
