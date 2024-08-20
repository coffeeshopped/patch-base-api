
public indirect enum PatchController {
  
  case patch(prefix: Prefix? = nil, color: Int? = nil, border: Int? = nil, _ builders: [Builder], effects: [Effect] = [], layout: [Constraint] = [])
  
  case paged(prefix: Prefix? = nil, color: Int? = nil, border: Int? = nil, _ builders: [Builder], effects: [Effect] = [], layout: [Constraint] = [], pages: PageSetup)
  
  case fm(_ algos: [DXAlgorithm], opCtrlr: (Int) throws -> PatchController, algoPath: SynthPath = [.algo], reverse: Bool = false, selectable: Bool = false)
  
  case data(_ dataCount: Int, _ range: ClosedRange<Int>, _ pathFn: (Int) -> SynthPath, effects: [Effect] = [])
    
  public enum Control {
    case knob
    case checkbox
    case switsch
    case select
    case spacer(_ gridWidth: CGFloat)
    case label(_ align: PBTextAlignment, size: CGFloat = 13, bold: Bool = true)
    case fullSlider
    case button
    case imgSelect(w: CGFloat, h: CGFloat, spacing: CGFloat? = nil, images: [String]? = nil)
    case value
    case grid(cols: Int)
  }
    
  public enum Prefix {
    case fixed(SynthPath)
    case index(_ prefix: SynthPath)
    case indexFn(_ fn: (Int) -> SynthPath)
    case select([SynthPath])
  }
  
  public enum Builder {
    
    case grid(prefix: SynthPath? = nil, color: Int? = nil, clearBG: Bool = false, items: [([PanelItem], h: CGFloat)])
    case panel(_ name: String, prefix: SynthPath = [], color: Int? = nil, clearBG: Bool = false, items: [([PanelItem], h: CGFloat)])
    // for adding controls directly to the controller and laying them out without panels
    case items(color: Int? = nil, clearBG: Bool = false, _ items: [(PanelItem, String)])
    case child(_ child: PatchController, _ panel: String, color: Int? = nil, clearBG: Bool = false)
    case children(_ count: Int, _ panelPrefix: String, color: Int? = nil, clearBG: Bool = false, _ child: PatchController, indexFn: ((_ parentIndex: Int, _ offset: Int) -> Int)? = nil)
  }
  
  public typealias ControlChangeFn = (_ state: PatchControllerState, _ locals: PatchControllerLocals) throws -> [AttrChange]

  public typealias PasteTransformFn = (_ values: SynthPathInts, _ state: PatchControllerState, _ locals: PatchControllerLocals) -> SynthPathInts
  public enum Effect {
    
    case change(_ fn: ControlChangeFn)
    
    case indexChange(_ fn: (Int) throws -> [AttrChange])
    
    case controlChange(_ id: SynthPath, fn: ControlChangeFn)
    case controlCommand(_ id: SynthPath, latestValues: [SynthPath], _ fn: (_ value: Int, _ latestValues: SynthPathInts, _ index: Int) -> [AttrChange])
    
    // nil paths == controlledPaths
    case editMenu(_ id: SynthPath?, pathsFn: ((Int) -> [SynthPath])?, type: String, init: ((Int) -> [Int])?, rand: ((Int) -> [Int])?, pasteTransform: PasteTransformFn? = nil, items: [MenuItem] = [])
    
    case setup(_ changes: [AttrChange])
    
    case click(_ id: SynthPath?, _ fn: ControlChangeFn)
    case listen(_ id: SynthPath, _ fn: ControlChangeFn)
  }
  
  public typealias MenuItemCustomFn = (_ values: SynthPathInts, _ state: PatchControllerState, _ locals: PatchControllerLocals) -> [AttrChange]
  public enum MenuItem {
    case filePopover(_ label: String, _ path: SynthPath)
    case custom(_ label: String, _ fn: MenuItemCustomFn)
  }
  
  public enum PanelItem {
    case basic(Control, String?, SynthPath?, id: SynthPath?, width: CGFloat? = nil)
    case switcher(label: String? = nil, _ labels: [String], id: SynthPath? = nil, width: CGFloat? = nil, cols: Int? = nil)
    case display(_ display: Display, _ label: String?, _ maps: [DisplayMap], id: SynthPath?, width: CGFloat? = nil)
    case name(_ label: String?, SynthPath, id: SynthPath? = nil, width: CGFloat? = nil)
    case nav(_ label: String?, _ nav: SynthPath, id: SynthPath? = nil, width: CGFloat? = nil)

    public var id: SynthPath? {
      switch self {
      case .basic(_, _, _, let id, _),
          .switcher(_, _, let id, _, _),
          .display(_, _, _, let id, _),
          .name(_, _, let id, _),
          .nav(_, _, let id, _):
        return id
      }
    }
    
    /// Make a copy, replacing the mapping path (used by TX81Z)
    public func pathTransform(_ path: (SynthPath) -> SynthPath) -> Self {
      switch self {
      case .basic(let ctrl, let label, let p, let id, let width):
        guard let p = p else { return self }
        return .basic(ctrl, label, path(p), id: id, width: width)
      default:
        return self
      }
    }
    
    /// an ID for use by the ViewController for control tracking.
    var controlId: SynthPath? {
      if case .basic(_, _, let path, _, _) = self,
        let path = path {
        return path
      }
      else {
        return id
      }
    }
  }
  
  public enum Display {
    case env(_ pathFn: DisplayPathFn)
    case flex(_ layers: [DisplayLayer])
  }
  
  public enum DisplayColor {
    case value
    case label
  }

  
  public typealias DisplayPathFn = (_ values: [SynthPath:CGFloat]) throws -> [PBBezier.PathCommand]
  
  public enum DisplayLayer {
    case l(_ path: SynthPath, stroke: DisplayColor, lineWidth: CGFloat = 1.0, dashPattern: [CGFloat]? = nil, _ pathFn: DisplayPathFn)
  }
  
  public enum DisplayMap {
    case src(_ src: SynthPath, dest: SynthPath? = nil, (CGFloat) throws -> CGFloat)
    
    public var srcPath: SynthPath {
      switch self {
      case .src(let s, _, _):
        return s
      }
    }
    
    public var destPath: SynthPath {
      switch self {
      case .src(let s, let d, _):
        return d ?? s
      }
    }
    
    public func map(_ v: CGFloat) throws -> CGFloat {
      switch self {
      case .src(_, _, let m):
        return try m(v)
      }
    }
  }
  
  public enum AttrChange {
    case dimItem(_ dim: Bool, _ id: SynthPath, dimAlpha: CGFloat? = nil)
    // nil id = dim the whole controller
    case dimPanel(_ dim: Bool, _ id: String?, dimAlpha: CGFloat? = nil)
    case setCtrlLabel(_ id: SynthPath, _ label: String?)
    /// Set a local value. If id matches a Labeled Control, will also update that control's value
    case setValue(_ id: SynthPath, _ value: Int)
    case configCtrl(_ id: SynthPath, _ param: ConfigParam)
    // nil id = the controller itself (instead of child)
    case setIndex(_ id: String?, _ index: Int)
    // set the nav path of a nav button
    case setNavPath(id: SynthPath? = nil, _ nav: SynthPath)
    
    case paramsChange(_ values: SynthPathInts)
    case unprefixedParamsChange(_ values: SynthPathInts)

//    case patchChange(NuPatchChange)
//    case unprefixedPatchChange(NuPatchChange)
    
    case midiNote(chan: Int, note: Int, velo: Int, len: Int)
    
    case event(_ id: SynthPath, _ state: PatchControllerState, _ locals: [SynthPath:Int])
    
    case colorItem(_ id: SynthPath, level: Int = 1, clearBG: Bool = false)
    case colorPanel(_ id: String?, level: Int = 1, clearBG: Bool = false)
  }
  
  public enum Constraint {
    public typealias Item = (String, CGFloat)
    case grid(_ items: [(row: [Item], height: CGFloat)])
    case row(_ items: [Item], opts: [PBLayoutConstraint.FormatOption] = [.alignAllTop, .alignAllBottom], spacing: CGFloat? = nil)
    case col(_ items: [Item], opts: [PBLayoutConstraint.FormatOption] = [.alignAllLeading], spacing: CGFloat? = nil)
    case colFixed(_ items: [String], fixed: String, height: CGFloat, opts: [PBLayoutConstraint.FormatOption] = [.alignAllLeading], spacing: CGFloat? = nil)
    case rowPart(_ items: [Item], opts: [PBLayoutConstraint.FormatOption] = [.alignAllTop, .alignAllBottom], spacing: CGFloat? = nil)
    case colPart(_ items: [Item], opts: [PBLayoutConstraint.FormatOption] = [.alignAllLeading], spacing: CGFloat? = nil)
    case eq(_ ids: [String], _ attribute: PBLayoutConstraint.Attribute)
    
  }
    
  public enum PageSetup {
    case controllers([PatchController])
    case map(_ paths: [SynthPath], _ dict: [SynthPath:PatchController])
  }
}

public extension PatchController.PanelItem {
  
  static func knob(_ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.knob, nil, path, id: id, width: width)
  }

  static func knob(_ label: String?, _ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.knob, label, path, id: id, width: width)
  }

  static func checkbox(_ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.checkbox, nil, path, id: id, width: width)
  }

  static func checkbox(_ label: String?, _ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.checkbox, label, path, id: id, width: width)
  }

  static func switsch(_ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.switsch, nil, path, id: id, width: width)
  }

  static func switsch(_ label: String?, _ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.switsch, label, path, id: id, width: width)
  }

  static func select(_ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.select, nil, path, id: id, width: width)
  }

  static func select(_ label: String?, _ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.select, label, path, id: id, width: width)
  }

  static func fullSlider(_ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.fullSlider, nil, path, id: id, width: width)
  }

  static func fullSlider(_ label: String?, _ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.fullSlider, label, path, id: id, width: width)
  }

  static func spacer(_ width: CGFloat) -> Self {
    .basic(.spacer(width), nil, nil, id: nil, width: width)
  }
  
  static func label(_ label: String, align: PBTextAlignment = .center, size: CGFloat = 13, bold: Bool = true, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.label(align, size: size, bold: bold), label, nil, id: id, width: width)
  }
  
  static func button(_ label: String, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.button, label, nil, id: id, width: width)
  }
  
  static func imgSelect(_ label: String?, _ path: SynthPath?, w: CGFloat, h: CGFloat, images: [String]? = nil, spacing: CGFloat? = nil, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.imgSelect(w: w, h: h, spacing: spacing, images: images), label, path, id: id, width: width)
  }

  static func value(_ label: String?, _ path: SynthPath?, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.value, label, path, id: id, width: width)
  }

  static func grid(_ label: String?, _ path: SynthPath?, cols: Int, id: SynthPath? = nil, width: CGFloat? = nil) -> Self {
    .basic(.grid(cols: cols), label, path, id: id, width: width)
  }

    
}

public extension PatchController.DisplayMap {

  static func ident(_ src: SynthPath, dest: SynthPath? = nil) -> Self {
    .src(src, dest: dest, { $0 })
  }

  static func unit(_ src: SynthPath, dest: SynthPath? = nil, max: CGFloat = 127) -> Self {
    .src(src, dest: dest, { $0 / max })
  }
  
  // add a prefix to the src path while leaving the dest path as-is.
  // useful for situations where src paths need to be prefixed at the DisplayMap level
  // instead of at the panel or controller level
  func srcPrefix(_ pre: SynthPath) -> Self {
    .src(pre + srcPath, dest: destPath, map)
  }

}

public extension PatchController.Builder {
  
  static func grid(prefix: SynthPath? = nil, color: Int? = nil, clearBG: Bool = false, _ items: [[PatchController.PanelItem]]) -> Self {
    .grid(prefix: prefix, color: color, clearBG: clearBG, items: items.map { ($0, h: 1) })
  }
  
  static func panel(_ name: String, prefix: SynthPath = [], color: Int? = nil, clearBG: Bool = false, _ items: [[PatchController.PanelItem]]) -> Self {
    .panel(name, prefix: prefix, color: color, clearBG: clearBG, items: items.map { ($0, h: 1) })
  }


  static func switcher(label: String? = nil, _ items: [String], cols: Int? = nil, color: Int? = nil) -> Self {
    .panel("switch", color: color, clearBG: true, [[.switcher(label: label, items, id: [.switcher], cols: cols)]])
  }
  
  static func button(_ label: String, color: Int? = nil) -> Self {
    .panel("button", color: color, clearBG: true, [[.button(label, id: [.button])]])
  }

  static func nav(_ label: String, _ nav: SynthPath, color: Int? = nil) -> Self {
    .panel("nav", color: color, clearBG: true, [[.nav(label, nav, id: [.nav])]])
  }

}

public extension PatchController.Effect {

  static func indexChange(fn: @escaping (PatchControllerState, PatchControllerLocals) -> [PatchController.AttrChange]) -> Self {
    .change { state, locals in
      guard case .prefixChange = state.event else { return [] }
      return fn(state, locals)
    }
  }
  
  static func valueChange(fullPath: @escaping (Int) -> SynthPath, fn: @escaping (Int) -> [PatchController.AttrChange]) -> Self {
    .change { state, locals in
      let changedPaths = state.changedValuePaths()
      guard changedPaths.count > 0 else { return [] }
      let path: SynthPath = fullPath(state.index)
      guard changedPaths.contains(path) else { return [] }
      return fn(state.values[path] ?? 0)
    }
  }

  static func controlChange(_ id: SynthPath, _ fn: @escaping (_ state: PatchControllerState, _ locals: [SynthPath:Int]) -> SynthPathInts?) -> Self {
    .controlChange(id) { state, locals in
      guard let pc = fn(state, locals) else { return [] }
      return [.paramsChange(pc)]
    }
  }
  
  static func basicControlChange(_ id: SynthPath) -> Self {
    .controlChange(id) { state, locals in
      [id : locals[id] ?? 0]
    }
  }
  
  static func patchChange(_ path: SynthPath, _ fn: @escaping (Int) throws -> [PatchController.AttrChange]) -> Self {
    .patchChange(paths: [path]) { values in
      guard let v = values[path] else { return [] }
      return try fn(v)
    }
  }
  
  static func patchChange(paths: [SynthPath], _ fn: @escaping (_ values: SynthPathInts) throws -> [PatchController.AttrChange]) -> Self {
    .patchChange(paths: paths) { values, state, locals in
      try fn(values)
    }
  }

  static func patchChange(paths: [SynthPath], fn: @escaping (_ values: SynthPathInts, _ state: PatchControllerState, _ locals: PatchControllerLocals) throws -> [PatchController.AttrChange]) -> Self {
    return .change { state, locals in
      guard let values = state.updatedValues(paths: paths) else { return [] }
      return try fn(values, state, locals)
    }
  }

  
  static func basicPatchChange(_ path: SynthPath) -> Self {
    .patchChange(path, { [.setValue(path, $0)] })
  }

  static func patchChange(fullPath: SynthPath, _ fn: @escaping (Int) -> [PatchController.AttrChange]) -> Self {
    .patchChange(fullPath: fullPath, fn: { value, state, locals in
      fn(value)
    })
  }
  
  static func patchChange(fullPaths: [SynthPath], _ fn: @escaping (_ values: SynthPathInts) -> [PatchController.AttrChange]) -> Self {
    .patchChange(fullPaths: fullPaths) { values, state, locals in
      fn(values)
    }
  }

  static func patchChange(fullPath: SynthPath, fn: @escaping (_ value: Int, _ state: PatchControllerState, _ locals: PatchControllerLocals) -> [PatchController.AttrChange]) -> Self {
    .patchChange(fullPaths: [fullPath]) { values, state, locals in
      guard let v = values[fullPath] else { return [] }
      return fn(v, state, locals)
    }
  }

  static func patchChange(fullPaths: [SynthPath], fn: @escaping (_ values: SynthPathInts, _ state: PatchControllerState, _ locals: PatchControllerLocals) -> [PatchController.AttrChange]) -> Self {
    return .change { state, locals in
      guard let values = state.updatedValuesForFullPaths(fullPaths: fullPaths) else { return [] }
      return fn(values, state, locals)
    }
  }

  
  /// Note: path here is an unprefixed path, since that is the most common usage!
  static func paramChange(_ fullPath: SynthPath, _ fn: @escaping (Parm) throws -> [PatchController.AttrChange]) -> Self {
    .paramChange(fullPath, fnWithContext: { parm, state, locals in
      try fn(parm)
    })
  }

  static func paramChange(_ fullPath: SynthPath, fnWithContext fn: @escaping (Parm, PatchControllerState, PatchControllerLocals) throws -> [PatchController.AttrChange]) -> Self {
    .change { state, locals in
      switch state.event {
      case .prefixChange:
        // we react on prefixChange because we want the param on first VC subscribe
        // and this is the only way to do it.
        // ideally there would be some sort of "subscribe" or "init" event that gets passed
        // when VC first gets added to the flow
        // BUT, this would handle the situation of getting added to the flow and
        // then having the Effect added (although does that situation happen?)
        guard let parm = state.params[fullPath] else { return [] }
        return try fn(parm, state, locals)
      case .paramsChange(let paths):
        guard paths.contains(fullPath),
              let parm = state.params[fullPath] else { return [] }
        return try fn(parm, state, locals)
      default:
        return []
      }
    }
  }
  
  static func dimsOn(_ path: SynthPath, id: SynthPath, dimAlpha: CGFloat? = nil) -> Self {
    .patchChange(path) { v in
      [.dimItem(v == 0, id, dimAlpha: dimAlpha)]
    }
  }
  
  static func dimsOn(_ path: SynthPath, id: String?, dimAlpha: CGFloat? = nil, dimWhen: ((Int) -> Bool)? = nil) -> Self {
    let dimWhen = dimWhen ?? { $0 == 0 }
    return .patchChange(path) { v in
      [.dimPanel(dimWhen(v), id, dimAlpha: dimAlpha)]
    }
  }

  /// dims if all values == 0
  static func dimsOn(_ paths: [SynthPath], id: String?, dimAlpha: CGFloat? = nil) -> Self {
    .patchChange(paths: paths) { values in
      [.dimPanel(values.values.reduce(0, +) == 0, id, dimAlpha: dimAlpha)]
    }
  }
  
  static func dimsOn(fullPath: @escaping (Int) -> SynthPath, id: String?, dimAlpha: CGFloat? = nil, dimWhen: ((Int) -> Bool)? = nil) -> Self {
    .valueChange(fullPath: fullPath) {
      [.dimPanel($0 == 0, id)]
    }
  }

  
  // nil paths == vc.controlledPaths
  static func editMenu(_ id: SynthPath?, paths: [SynthPath]?, type: String, init innit: [Int]?, rand: (() -> [Int])?, items: [PatchController.MenuItem] = []) -> Self {
    var pathsFn: ((Int) -> [SynthPath])? = nil
    if let paths = paths { pathsFn = { _ in paths } }

    var initFn: ((Int) -> [Int])? = nil
    if let innit = innit { initFn = { _ in innit } }

    var randFn: ((Int) -> [Int])? = nil
    if let rand = rand { randFn = { _ in rand() } }

    return .editMenu(id, pathsFn: pathsFn, type: type, init: initFn, rand: randFn, items: items)
  }
  
}


public extension PatchController.Constraint {
  
  static func simpleGrid(_ items: [[Item]]) -> Self {
    .grid(items.map { (row: $0, height: 1) })
  }

  static func oneRowGrid(_ count: Int, _ panelPrefix: String) -> Self {
    .simpleGrid([count.map { ("\(panelPrefix)\($0)", 1) }])
  }

}

public extension Array where Element == PatchController.Effect {

  /// Map a control (PBSelect) to have its options updated either when a value at `path` is changed, or mapped params are changed
  static func patchSelector(id: SynthPath, bankValue: SynthPath, paramMap: @escaping (Int) -> PatchController.ConfigParam) -> Self {
    
    patchSelector(id: id, bankValues: [bankValue]) { paramMap($0[bankValue] ?? 0) }
    
  }

  static func patchSelector(id: SynthPath, bankValues: [SynthPath], paramMap: @escaping (SynthPathInts) -> PatchController.ConfigParam) -> Self {
    .patchSelector(id: id, bankValues: bankValues) { values, state, locals in
      paramMap(values)
    }
  }

  static func patchSelector(id: SynthPath, bankValues: [SynthPath], paramMapWithContext: @escaping (SynthPathInts, PatchControllerState, PatchControllerLocals) -> PatchController.ConfigParam) -> Self {

    let patchChange: PatchController.Effect = .patchChange(paths: bankValues, fn: { values, state, locals in
      [.configCtrl(id, paramMapWithContext(values, state, locals))]
    })

    let paramChange: PatchController.Effect = .change({ state, locals in
      guard case .paramsChange = state.event else { return [] }
      return [.configCtrl(id, paramMapWithContext(.init(bankValues.compactDict {
        guard let v = state.prefixedValue($0) else { return nil }
        return [$0 : v]
      }), state, locals))]
    })

    return [patchChange, paramChange]
  }
  
  static func ctrlBlocks(_ path: SynthPath, value: ((Int) -> Int)? = nil, cc: ((Int) -> Int)? = nil, param: PatchController.ConfigParam? = nil) -> Self {
    let value = value ?? { $0 }
    let cc = cc ?? { $0 }
    let param = param ?? .localPath(path)
    
    let paramEffect: PatchController.Effect
    let attrs: [PatchController.AttrChange] = [.configCtrl(path, param)]
    switch param {
    case .opts, .param, .span:
      paramEffect = .setup(attrs)
    case .fullPath, .localPath:
      paramEffect = .change { state, locals in
        switch state.event {
        case .paramsChange(let paths):
          guard paths.contains(state.prefixTransform(path)) else { return [] }
          return attrs
        case .prefixChange:
          return attrs
        default:
          return []
        }
      }
    }
    
    return [
      .patchChange(path, { [.setValue(path, value($0))] }),
      .controlChange(path, { state, locals in
        guard let v = locals[path] else { return nil }
        return [path : cc(v)]
      }),
      paramEffect,
    ]
  }
  
  // helper for Voice Reserve controls (Performances) where the sum of all values can't exceed some limit
  /*
   reservePaths are full paths (not local)
   ctrls are ids of (local) controls
   passed ctrls shouldn't be automapped.
   */
  static func voiceReserve(paths reservePaths: [SynthPath], total: Int, ctrls: [SynthPath]) -> Self {
    return [
      .change({ state, locals in
        let changedPaths = state.changedValuePaths()
        // check if any of the reservePaths were changed
        guard reservePaths.reduce(false, { $0 || changedPaths.contains($1) }) else {
          return []
        }
        let totalReserved = reservePaths.reduce(0, { $0 + (state.values[$1] ?? 0) })
        return ctrls.map { ctrl in
          // the sum of all reserved notes, minus this part's reserved notes value
          let myValue = state.prefixedValue(ctrl) ?? 0
          let sum = totalReserved - myValue
          let mx = Swift.max(total - sum, 0)
          return [
            .configCtrl(ctrl, .param(RangeParam(maxVal: mx))),
            .setValue(ctrl, myValue),
          ]
        }.reduce([], +)
      }),
    ] + ctrls.flatMap { [
      .basicPatchChange($0),
      .basicControlChange($0),
    ] }
  }
  
  /// Map multiple items to the same control change handler.
  static func controlChange(ids: [SynthPath], _ fn: @escaping (_ state: PatchControllerState, _ locals: [SynthPath:Int]) -> SynthPathInts?) -> Self {
    ids.map { id in
      .controlChange(id) { state, locals in
        guard let pc = fn(state, locals) else { return [] }
        return [.paramsChange(pc)]
      }
    }
  }

}

public extension PatchController {
  
  enum ConfigParam {
    case fullPath(SynthPath)
    case localPath(SynthPath)
    case opts(ParamOptions)
    case param(Param)
    case span(Parm.Span)
  }
  
}

public extension PatchController {
  
  static func oneRow(_ count: Int, child: PatchController, indexMap: ((_ parentIndex: Int, _ offset: Int) -> Int)? = nil) -> Self {
    .patch([
      .children(count, "p", child, indexFn: indexMap),
    ], layout: [
      .oneRowGrid(count, "p")
    ])
  }
  
  static func index(_ prefix: SynthPath, label: SynthPath, _ labelFn: @escaping (Int) -> String, color: Int? = nil, border: Int? = nil, _ builders: [Builder], effects: [Effect] = [], layout: [Constraint] = []) -> Self {
    .patch(prefix: .index(prefix), color: color, border: border, builders, effects: effects + [
      .indexChange({ [.setCtrlLabel(label, labelFn($0))]})
    ], layout: layout)
  }

  static func fm(_ algos: [DXAlgorithm], _ opCtrlr: PatchController, algoPath: SynthPath = [.algo], reverse: Bool = false, selectable: Bool = false) -> Self {
    .fm(algos, opCtrlr: { _ in opCtrlr }, algoPath: algoPath, reverse: reverse, selectable: selectable)
  }

  static func palettes(_ pal: PatchController, _ count: Int, _ prefix: SynthPath?, _ label: String, pasteType: String, effects: [PatchController.Effect] = []) -> Self {
    let effects = effects.count > 0 ? effects : [.dimsOn([.on], id: nil)]
    let pre: PatchController.Prefix? = prefix == nil ? nil : .index(prefix!)
    let wrapped = paletteWrap(pal, pasteType: pasteType, vcHeight: 14, prefix: pre, border: 1, effects: effects) { "\(label) \($0 + 1)" }

    return .patch([
      .children(count, "pal", wrapped),
    ], effects: [], layout: [
      .simpleGrid([count.map { ("pal\($0)", 1) }])
    ])
  }
  
  private static func paletteWrap(_ subVC: PatchController, pasteType: String, vcHeight: CGFloat, prefix: PatchController.Prefix?, border: Int? = nil, effects: [PatchController.Effect] = [], passIndex: Bool = false, buttonLabelBlock: @escaping (Int) -> String) -> PatchController {
    var fx = effects
    
    // if no prefix is passed, then index should be passed to child (it is assumed that the child does its own prefixing.
    if prefix == nil {
      fx += [.indexChange({ [.setIndex("vc", $0)] })]
    }
    
    return .patch(prefix: prefix, border: border, [
      .child(subVC, "vc"),
      .button("...", color: 1)
    ], effects: [
      .indexChange({ [.setCtrlLabel([.button], buttonLabelBlock($0))] }),
      // TODO: pass nil for "controlledPaths"
      .editMenu([.button], paths: nil, type: pasteType, init: nil, rand: nil)
    ] + fx, layout: [
      .grid([
        (row: [("vc", 1)], height: vcHeight),
        (row: [("button", 1)], height: 1),
      ])
    ])
  }
}



public typealias PatchControllerChangeFn = (_ state: PatchControllerState, _ locals: PatchControllerLocals) throws -> Void

public enum PatchControllerEvent {
  case initialize
  case prefixChange
  case nameChange(_ path: SynthPath)
  case valuesChange(_ paths: [SynthPath])
  case paramsChange(_ paths: [SynthPath])
  case patchReplace
}

public typealias PatchControllerLocals = [SynthPath:Int]
