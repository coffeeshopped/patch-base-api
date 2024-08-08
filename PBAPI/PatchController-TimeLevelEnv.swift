
public extension PatchController.Display {
  
  static func timeLevelEnv(pointCount: Int, sustain: Int = 1000, bipolar: Bool = false) -> Self {
    let pathFn: PatchController.DisplayPathFn = { values in
      var cmds = [PBBezier.PathCommand]()

      let gain = CGFloat(values[[.gain]] ?? 1)
      let startLevel = CGFloat(values[[.start, .level]] ?? 0)
      
      let segWidth = (sustain >= pointCount ? 1 / CGFloat(pointCount) : 1 / CGFloat(pointCount+1) )
      let yScale: CGFloat = gain
      let offscreenDelta: CGFloat = 0.05
      
      var x: CGFloat
      var y: CGFloat

      cmds.append(.move(to: CGPoint(x: -offscreenDelta, y: -offscreenDelta)))

      x = 0
      y = startLevel * yScale
      cmds.append(.addLine(to: CGPoint(x: x, y: y)))
      
      for index in 0..<pointCount {
        x += (values[[.time, .i(index)]] ?? 0) * segWidth
        y = (values[[.level, .i(index)]] ?? 0) * yScale
        cmds.append(.addLine(to: CGPoint(x: x, y: y)))
        if sustain == index {
          x += segWidth
          cmds.append(.addLine(to: CGPoint(x: x, y: y)))
        }
      }
      
      cmds.append(.addLine(to: CGPoint(x: 1, y: y)))
      cmds.append(.addLine(to: CGPoint(x: 1 + offscreenDelta, y: -offscreenDelta)))
      
      if bipolar {
        let t = CGAffineTransform.identity
          .scaledBy(x: 1, y: 0.5)
          .translatedBy(x: 0, y: 1)
        cmds.append(.apply(t))
      }
      
      return cmds
    }
    return .env(pathFn)
  }
}
