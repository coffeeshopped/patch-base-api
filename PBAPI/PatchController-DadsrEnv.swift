
public extension PatchController.Display {
  
  static func dadsrEnv() -> Self {
    let pathFn: PatchController.DisplayPathFn = { values in
      var cmds = [PBBezier.PathCommand]()

      let delay = CGFloat(values[[.delay]] ?? 0)
      let attack = CGFloat(values[[.attack]] ?? 0)
      let decay = CGFloat(values[[.decay]] ?? 0)
      let sustain = CGFloat(values[[.sustain]] ?? 0)
      let rrelease = CGFloat(values[[.release]] ?? 0)
      
      let segWidth = 0.2
      var x: CGFloat = 0
      
      cmds.append(.move(to: CGPoint(x: 0, y: 0)))
      
      // delay
      x += delay*segWidth
      cmds.append(.addLine(to: CGPoint(x: x, y: 0)))
      
      // attack
      x += attack*segWidth
      cmds.append(.addLine(to: CGPoint(x: x, y: 1)))
      
      // decay
      x += decay * segWidth
      cmds.append(.addLine(to: CGPoint(x: x, y: sustain)))
      
      // sustain
      x += segWidth
      cmds.append(.addLine(to: CGPoint(x: x, y: sustain)))
      
      // release
      x += rrelease * segWidth
      cmds.append(.addLine(to: CGPoint(x: x, y: 0)))
      
      return cmds
    }
    return .env(pathFn)
  }
}
