import SwiftUI

enum FsmState: Int {
    case CAM, LOD, MOV, OPT, TRN, VSC, VWR, ZOM
}
let FsmStateName = ["CAM", "LOD", "MOV", "OPT", "TRN", "VSC", "VWR", "ZOM"]

enum FsmEvent: Int {
    case CAM, CTL, LOD, MOV, OPT, RET, TRN, VWR, ZOM
}
let FsmEventName = ["CAM", "CTL", "LOD", "MOV", "OPT", "RET", "TRN", "VWR", "ZOM"]

typealias FsmAction = () throws -> Void

class Fsm: ObservableObject {
    @Published private(set) var hState = FsmHState()
    @Published private(set) var hEvent = FsmHEvent()
    
    @Published private(set) var movAmount = CGSize.zero
    private var camMovAmount = CGSize.zero
    private var camMovRecall = CGSize.zero
    private var startJumpMov: CGSize? = nil
    
    private var eaTable: [[FsmAction]] = [[]]
    private var eaParam = EaParam()
    
    var isCam: Bool { get { hState.peek() as? FsmState == FsmState.CAM } }
    var isLod: Bool { get { hState.peek() as? FsmState == FsmState.LOD } }
    var isMov: Bool { get { hState.peek() as? FsmState == FsmState.MOV } }
    var isOpt: Bool { get { hState.peek() as? FsmState == FsmState.OPT } }
    var isTrn: Bool { get { hState.peek() as? FsmState == FsmState.TRN } }
    var isVwr: Bool { get { hState.peek() as? FsmState == FsmState.VWR } }
    var isVsc: Bool { get { hState.peek() as? FsmState == FsmState.VSC } }
    var isZom: Bool { get { hState.peek() as? FsmState == FsmState.ZOM } }
    
    var isCsl: Bool { get { isVwr || isCam || isOpt } }
    var isCad: Bool { get { isMov || isTrn || isZom } }
    
    init(startWithState state: FsmState = FsmState.VSC) {
        self.hState.push(state)
        self.eaTable = [
            /* S/E     CAM       CTL       LOD       MOV       OPT       RET       TRN       VWR       ZOM     */
            /* CAM */ [eaReject, eaReject, eaReject, eaCamMov, eaReject, eaCamRet, eaReject, eaReject, eaReject],
            /* LOD */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaLodRet, eaReject, eaReject, eaReject],
            /* MOV */ [eaReject, eaReject, eaReject, eaMovMov, eaReject, eaMovRet, eaReject, eaReject, eaReject],
            /* OPT */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaOptRet, eaReject, eaReject, eaReject],
            /* TRN */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* VSC */ [eaReject, eaVscCtl, eaVscLod, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* VWR */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaVwrRet, eaReject, eaReject, eaReject],
            /* ZOM */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject]
            ]
    }
    
    func push(parameter: Any) { eaParam.push(parameter) }
    @discardableResult func pop() -> Any { eaParam.pop() }
    
    func transition(event: FsmEvent) throws {
        let s = (hState.peek() as! FsmState).rawValue
        let e = event.rawValue
        
        print("state \(FsmStateName[s]) received event \(FsmEventName[e]) : ", terminator: "")
        
        self.hEvent.push(event)
        try eaTable[s][e]()
    }
    
    private func eaMovRet() {
        timeoutTask = runOnTimeout(seconds: 3) {
            do {
                try self.transition(event: FsmEvent.RET)
            } catch {}
        }
        
        camMovRecall = camMovAmount
        startJumpMov = nil
        
        hState.pop()
        hEvent.pop()
        
        update(withState: hState.peek() as! FsmState)
    }
    
    private func eaMovMov() {
        let movAmount = eaParam.pop() as! CGSize
        camMovAmount = startJumpMov!+camMovRecall+movAmount
        self.movAmount = camMovAmount
        
        update(withState: FsmState.MOV)
    }
    
    private func eaCamMov() {
        timeoutTask.cancel()
        
        let movAmount = eaParam.pop() as! CGSize
        
        if startJumpMov == nil {
            startJumpMov = -movAmount
        } else {
            camMovAmount = startJumpMov!+camMovRecall+movAmount
            self.movAmount = camMovAmount
        }
        
        update(withState: FsmState.MOV, noHistory: false)
    }
    
    private func eaVwrRet() {
        update(withState: FsmState.VSC)
    }
    
    private func eaCamRet() {
        update(withState: FsmState.VSC)
    }
    
    private func eaOptRet() {
        update(withState: FsmState.VSC)
    }
    
    let timeoutTask: Task<Void, Never>!
    private func eaVscCtl() {
        timeoutTask = runOnTimeout(seconds: 3) {
            do {
                try self.transition(event: FsmEvent.RET)
            } catch {}
        }
        
        movAmount = CGSize.zero
        camMovAmount = CGSize.zero
        camMovRecall = CGSize.zero
        startJumpMov = nil
        
        let pressedSideButton = eaParam.pop() as! ButtonType
        
        let nextState: FsmState
        switch pressedSideButton {
        case .Viewer:
            nextState = FsmState.VWR
        case .Camera:
            nextState = FsmState.CAM
        case .Optics:
            nextState = FsmState.OPT
        default:
            nextState = FsmState.OPT
        }
        
        update(withState: nextState)
    }
    
    let outbackTask: Task<Void, Never>!
    private func eaVscLod() {
        let raycer = eaParam.pop() as! Rtow
        let things = eaParam.pop() as! Things
        
        outbackTask = runInOutback {
            let numRowsAtOnce = ProcessInfo.processInfo.processorCount/2*3
            await raycer.render(numRowsAtOnce: numRowsAtOnce, things: things)
            do {
                try self.transition(event: FsmEvent.RET)
            } catch {}
        }
        
        update(withState: FsmState.LOD, noHistory: false)
    }
    
    private func eaLodRet() {
        hState.pop()
        hEvent.pop()
        
        update(withState: hState.peek(.elementOnTop) as! FsmState)
    }
    
    private func eaReject() throws {
        print("rejected : ", terminator: "")
        
        update(withState: hState.peek() as! FsmState)
        throw FsmError.unexpectedEvent
    }
    
    private func update(withState state: FsmState, noHistory: Bool = true) {
        if noHistory {
            hState.pop()
            hEvent.pop()
        }
        hState.push(state)
        
        print("new state \(FsmStateName[state.rawValue]) (S/E history \(hState.count)/\(hEvent.count))")
    }
    
    private func runOnTimeout(seconds: Int, closure: @escaping () -> Void) -> Task<Void, Never> {
        Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(seconds*1_000_000_000))
                closure()
            } catch {}
        }
    }
    
    private func runInOutback(closure: @escaping () async -> Void) -> Task<Void, Never> {
        Task {
            await closure()
        }
    }
}
