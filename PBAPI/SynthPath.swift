
public typealias SynthPath = Array<SynthPathItem>

public extension SynthPath {

  var layoutKey: String {
    return "_" + (map {
      switch $0 {
      case .i(let i):
        return i < 0 ? "_\(-i)" : "\(i)"
      default:
        return "\($0)"
      }
    }).joined(separator: "_")
  }
  
  /// Return new SynthPath of items from "from" to path end
  @available(*, deprecated, message: "Try to use ArraySlices instead")
  func subpath(from index: Int) -> SynthPath {
    return SynthPath(self[index..<count])
  }

  func prefixed(by: SynthPath?) -> SynthPath { by == nil ? self : by! + self }
  
  @available(*, deprecated, message: "Try to use ArraySlices instead")
  /// Return new SynthPath of items from beginning through "to"
  func prefix(to index: Int) -> SynthPath {
    return SynthPath(self[0...index])
  }
  
  func pathPlusEndex() -> (path: SynthPath, endex: Int) {
    (prefix(to: count - 2), endex)
  }
  
  func subDict<Value:Any>(using closure: (inout [SynthPath:Value]) -> Void) -> [SynthPath:Value] {
    var dict = [SynthPath:Value]()
    closure(&dict)
    return dict.prefixed(self)
  }
  
  func i(_ index: Int) -> Int? {
    guard index >= 0 && index < count,
      case .i(let part) = self[index] else { return nil }
    return part
  }

  /// Single-item paths have endex = 0, otherwise, should be in last element.
  var endex: Int {
    return count < 2 ? 0 : i(count-1) ?? 0
  }

}

public extension Dictionary where Key == SynthPath {
  
  func filtered(forPrefix prefix: Key?) -> [Key:Value] {
    guard let prefix = prefix else { return self }
    var result = [Key:Value]()
    forEach {
      guard $0.key.starts(with: prefix) else { return }
      result[$0.key.subpath(from: prefix.count)] = $0.value
    }
    return result
  }
  
  func prefixed(_ prefix: Key?) -> [Key:Value] {
    guard let prefix = prefix else { return self }
    var result = [Key:Value]()
    forEach { result[prefix + $0.key] = $0.value }
    return result
  }
  
  subscript(paths: [Key]) -> [Value] {
    return paths.compactMap { self[$0] }
  }
  
  mutating func merge(new: [Key:Value]) {
    merge(new) { $1 }
  }
  
}

public extension Array where Element == SynthPath {

  func prefixed(_ prefix: Element?) -> [Element] {
    guard let prefix = prefix else { return self }
    return self.map { prefix + $0 }
  }

}


public enum SynthPathItem: Hashable, Codable {
  
  enum CodableError: Error {
    case encodeError(String)
    case decodeError(String)
  }

  public init(from decoder: Decoder) throws {
    let s = try decoder.singleValueContainer().decode(String.self)
    if s.hasPrefix("i_") {
      let parts = s.split(separator: "_")
      self = .i(Int(String(parts[1]))!)
    }
    else if let pair = SynthPathItem.codableMap.first(where: { $0.value == s }) {
      self = pair.key
    }
    else {
      throw CodableError.decodeError("Unknown encoding string: \(s)")
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    let s: String
    if case .i(let index) = self {
      s = "i_\(index)"
    }
    else if let entry = SynthPathItem.codableMap[self] {
      s = entry
    }
    else {
      throw CodableError.encodeError("SynthPathItem case not encodable: \(self)")
    }
    try container.encode(s)
  }
  
  
  case i(Int)

  case ac
  case accent
  case active
  case adjust
  case aftertouch
  case algo
  case alt
  case am
  case amp
  case amt
  case analog
  case analogFeel
  case arp
  case assign
  case attack
  case auto
  case autoEdit
  case backup
  case balance
  case bank
  case bd
  case bell
  case bend
  case bias
  case booster
  case brass
  case breath
  case brilliance
  case brk
  case button
  case bw
  case carrier
  case cart
  case category
  case chain
  case change
  case channel
  case character
  case chase
  case chord
  case chorus
  case chromatic
  case click
  case clock
  case clocked
  case coarse
  case color
  case common
  case const
  case contrast
  case cross
  case ctrl
  case curve
  case cutoff
  case cycle
  case damp
  case data
  case decay
  case decay2
  case delay
  case depth
  case dest
  case detune
  case deviceId
  case digital
  case direct
  case direction
  case dist
  case divide
  case down
  case drive
  case dry
  case dump
  case early
  case edge
  case edit
  case edits
  case eg
  case element
  case end
  case env
  case eq
  case excite
  case expression
  case ext
  case extAudio
  case extra
  case fade
  case feedback
  case filter
  case fine
  case fixed
  case fm
  case follow
  case foot
  case form
  case formant
  case fourPole
  case freq
  case fseq
  case fx
  case fxm
  case gain
  case gate
  case gender
  case genre
  case glide
  case global
  case gm2
  case group
  case grunge
  case hack
  case harmonic
  case hfdamp
  case hi
  case hold
  case holdPeak
  case id
  case inc
  case info
  case innit
  case input
  case insert
  case instr
  case int
  case interval
  case key
  case keyAssign
  case keyTrk
  case knob
  case lag
  case last
  case latch
  case layer
  case left
  case legato
  case length
  case level
  case lfo
  case light
  case limiter
  case limitWT
  case link
  case lip
  case lo
  case load
  case local
  case location
  case lock
  case loop
  case macro
  case manual
  case memory
  case metro
  case mic
  case micro
  case mid
  case midi
  case mix
  case mod
  case modWheel
  case mode
  case modif
  case mono
  case morph
  case motif
  case motion
  case mtrx
  case multi
  case mute
  case name
  case nav
  case noise
  case normal
  case note
  case number
  case octave
  case off
  case offset
  case omni
  case on
  case oneShot
  case op
  case osc
  case out
  case pan
  case panel
  case param
  case paraphonic
  case part
  case partial
  case pass
  case patch
  case pattern
  case pcm
  case peak
  case pedal
  case perf
  case pgm
  case pgmChange
  case phase
  case pitch
  case play
  case pluck
  case polarity
  case poly
  case popup
  case porta
  case position
  case post
  case pre
  case predelay
  case preset
  case pressure
  case preview
  case priority
  case protect
  case pt
  case pulse
  case pushIt
  case pw
  case q
  case quantize
  case ramp
  case random
  case range
  case rate
  case ratio
  case rcv
  case redamper
  case reed
  case release
  case remain
  case reserve
  case reset
  case resolution
  case reson
  case retrigger
  case reverb
  case reverse
  case rhythm
  case right
  case ringMod
  case robot
  case rotate
  case routing
  case rrepeat
  case run
  case sample
  case saturation
  case saw
  case scale
  case scene
  case select
  case semitone
  case send
  case sens
  case seq
  case shape
  case shift
  case shuffle
  case skirt
  case slew
  case slider
  case slop
  case slot
  case smooth
  case solo
  case sortOrder
  case sound
  case spectral
  case speed
  case split
  case src
  case srjv
  case srx
  case start
  case step
  case string
  case stretchTune
  case structure
  case style
  case sub
  case surround
  case sustain
  case sustain2
  case swing
  case switcher
  case sync
  case synth
  case sysex
  case system
  case table
  case tap
  case tempVoice
  case tempo
  case text
  case threshold
  case thru
  case timbre
  case time
  case timing
  case timingFactor
  case tone
  case transpose
  case trigger
  case trk
  case tune
  case type
  case unison
  case unvoiced
  case up
  case usb
  case user
  case vary
  case vector
  case velo
  case vib
  case vocoder
  case voice
  case voiced
  case volume
  case wah
  case warp
  case wave
  case wifi
  case x
  case y
  case z
  case zone

  static let codableMap: [SynthPathItem:String] = [
    .patch : "patch",
    .rhythm : "rhythm",
    .bank : "bank",
    .analog : "analog",
    .voice : "voice",
    .tempVoice : "tempVoice",
    .perf : "perf",
    .timbre : "timbre",
  ]
  
  static let allCases: [Self] = [.ac, .accent, .active, .adjust, .aftertouch, .algo, .alt, .am, .amp, .amt, .analog, .analogFeel, .arp, .assign, .attack, .auto, .autoEdit, .backup, .balance, .bank, .bd, .bell, .bend, .bias, .booster, .brass, .breath, .brilliance, .brk, .button, .bw, .carrier, .cart, .category, .chain, .change, .channel, .character, .chase, .chord, .chorus, .chromatic, .click, .clock, .clocked, .coarse, .color, .common, .const, .contrast, .cross, .ctrl, .curve, .cutoff, .cycle, .damp, .data, .decay, .decay2, .delay, .depth, .dest, .detune, .deviceId, .digital, .direct, .direction, .dist, .divide, .down, .drive, .dry, .dump, .early, .edge, .edit, .edits, .eg, .element, .end, .env, .eq, .excite, .expression, .ext, .extAudio, .extra, .fade, .feedback, .filter, .fine, .fixed, .fm, .follow, .foot, .form, .formant, .fourPole, .freq, .fseq, .fx, .fxm, .gain, .gate, .gender, .genre, .glide, .global, .gm2, .group, .grunge, .hack, .harmonic, .hfdamp, .hi, .hold, .holdPeak, .id, .inc, .info, .innit, .input, .insert, .instr, .int, .interval, .key, .keyAssign, .keyTrk, .knob, .lag, .last, .latch, .layer, .left, .legato, .length, .level, .lfo, .light, .limiter, .limitWT, .link, .lip, .lo, .load, .local, .location, .lock, .loop, .macro, .manual, .memory, .metro, .mic, .micro, .mid, .midi, .mix, .mod, .modWheel, .mode, .modif, .mono, .morph, .motif, .motion, .mtrx, .multi, .mute, .name, .nav, .noise, .normal, .note, .number, .octave, .off, .offset, .omni, .on, .oneShot, .op, .osc, .out, .pan, .panel, .param, .paraphonic, .part, .partial, .pass, .patch, .pattern, .pcm, .peak, .pedal, .perf, .pgm, .pgmChange, .phase, .pitch, .play, .pluck, .polarity, .poly, .popup, .porta, .position, .post, .pre, .predelay, .preset, .pressure, .preview, .priority, .protect, .pt, .pulse, .pushIt, .pw, .q, .quantize, .ramp, .random, .range, .rate, .ratio, .rcv, .redamper, .reed, .release, .remain, .reserve, .reset, .resolution, .reson, .retrigger, .reverb, .reverse, .rhythm, .right, .ringMod, .robot, .rotate, .routing, .rrepeat, .run, .sample, .saturation, .saw, .scale, .scene, .select, .semitone, .send, .sens, .seq, .shape, .shift, .shuffle, .skirt, .slew, .slider, .slop, .slot, .smooth, .solo, .sortOrder, .sound, .spectral, .speed, .split, .src, .srjv, .srx, .start, .step, .string, .stretchTune, .structure, .style, .sub, .surround, .sustain, .sustain2, .swing, .switcher, .sync, .synth, .sysex, .system, .table, .tap, .tempVoice, .tempo, .text, .threshold, .thru, .timbre, .time, .timing, .timingFactor, .tone, .transpose, .trigger, .trk, .tune, .type, .unison, .unvoiced, .up, .usb, .user, .vary, .vector, .velo, .vib, .vocoder, .voice, .voiced, .volume, .wah, .warp, .wave, .wifi, .x, .y, .z, .zone]
  
  public static let parseMap: [String:Self] = allCases.dict { ["\($0)" : $0 ] }
}


