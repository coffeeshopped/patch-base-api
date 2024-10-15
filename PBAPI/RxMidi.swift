
public struct RxMidi {

  public enum Command {
    case send([Data], TimeInterval)
    case fetch([FetchCommand], SynthPath, any SysexTruss)
    case compositeFetch([(SynthPath, [FetchCommand])], SynthPath, any MultiSysexTruss)
    case sendMsg(MidiMessage)
    case sendMulti([(MidiMessage, TimeInterval)])

    public var isFetch: Bool {
      switch self {
      case .fetch, .compositeFetch:
        return true
      case .send, .sendMsg, .sendMulti:
        return false
      }
    }
    
    public var totalBytes: Int {
      switch self {
      case .send(let data, _):
        return data.reduce(0) { $0 + $1.count }
      case .fetch(let subCmds, _, _):
        // if the subCmds have fetchIntents, then sum those
        // otherwise, return the size of the sysexType
        let intentBytes: [Int] = subCmds.compactMap {
          guard case .requestMsg(_, let intent) = $0 else { return nil }
          return intent?.byteCount
        }
        if intentBytes.count == 0 {
          fatalError("All Trusses should fetch with an intent!")
        }
        return intentBytes.reduce(0, +)
      case .compositeFetch(let cmdMap, _, _):
        // if the subCmds have fetchIntents, then sum those
        // otherwise, return the size of the sysexType
        let intentBytes: [Int] = cmdMap.flatMap { $0.1 }.compactMap {
          guard case .requestMsg(_, let intent) = $0 else { return nil }
          return intent?.byteCount
        }
        if intentBytes.count == 0 {
          fatalError("All Trusses should fetch with an intent!")
        }
        return intentBytes.reduce(0, +)
      case .sendMsg(let msg):
        return msg.count
      case .sendMulti(let pairs):
        return pairs.reduce(0) { $0 + $1.0.count }
      }
    }
    
    public var totalTime: TimeInterval {
      switch self {
      case .send(let data, let interval):
        return TimeInterval(data.count) * (interval + 0.05)
      case .fetch(let subcommands, _, _):
        return TimeInterval(subcommands.count) * (0.5)
      case .compositeFetch(let cmdMap, _, _):
        return TimeInterval(cmdMap.map { $0.1.count }.reduce(0, +)) * (0.5)
      case .sendMsg:
        return 0.05
      case .sendMulti(let pairs):
        return pairs.reduce(0) { $0 + $1.1 + 0.05 }
      }
    }
  }
  
  public enum FetchCommand {
    case send(Data)
    case request(Data)
    case wait(TimeInterval)
    case sendMsg(MidiMessage)
    case requestMsg(MidiMessage, FetchIntent?)
    
    public func decompose(cmd: Command) -> [Subcommand] {
      switch self {
      case .wait(let interval):
        return [.wait(interval)]
      case .send(let data):
        return [.send(data)]
      case .sendMsg(let msg):
        return [.sendMsg(msg)]
      case .requestMsg(let msg, let intent):
        return [.sendMsg(msg), .awaitMsg(intent, cmd)]
      case .request(let data):
        return [.send(data), .await(cmd)]
      }
    }
  }
  
  public enum Status {
    case idle
    case started(Command, remaining: Int)
    case updated(Command, bytes: Int, remaining: Int)
    case finished(Command, AnySysexible?, remaining: Int)
    case failed
    case canceled
    case error(Error)
    
    public func updateRemaining(_ r: Int) -> Status {
      switch self {
      case .started(let cmd, _): return .started(cmd, remaining: r)
      case .updated(let cmd, let bytes, _): return .updated(cmd, bytes: bytes, remaining: r)
      default: return self
      }
    }
  }
  
  public enum FetchIntent {
    case eq(Int)
    case gtEq(Int) // greater than or equal
//    case range(ClosedRange<Int>)
    
    public var byteCount: Int {
      switch self {
      case .eq(let i):
        return i
      case .gtEq(let i):
        return i
      }
    }
  }

  public enum Subcommand {
    case send(Data)
    case statusChange(Status)
    case wait(TimeInterval)
    case sendMsg(MidiMessage)

    case beginFetch(Command)
    case await(Command)
    case awaitMsg(FetchIntent?, Command)
    
    public var byteCount: Int {
      switch self {
      case .send(let data):
        return data.count
      case .sendMsg(let msg):
        return msg.count
      case .await(let cmd):
        return cmd.totalBytes
      case .awaitMsg(let intent, let cmd):
        return intent?.byteCount ?? cmd.totalBytes
//        return cmd.totalBytes
      case .statusChange, .wait, .beginFetch:
        return 0
      }
    }
  }

}
