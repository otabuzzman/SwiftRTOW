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
    private var vwrMovAmount = CGSize.zero
    private var vwrMovRecall = CGSize.zero
    private var startJumpMov: CGSize? = nil
    @Published private(set) var zomAmount = 1.0
    private var vwrZomAmount = 1.0
    private var vwrZomRecall = 1.0
    private var startJumpZom: CGFloat? = nil
    
    private var timeoutTask: Task<Void, Never>!
    private var outbackTask: Task<Void, Never>!
    
    private var eaTable: [[FsmAction]] = [[]]
    private var eaParam = EaParam()
    
    func isState(_ state: FsmState, atHistoryLevel level: StackIndex = .last) -> Bool {
        guard
            let peek = hState.peek(level) as? FsmState
        else { return false }
        return peek == state
    }
    
    var isCsl: Bool { get { isState(.VWR) || isState(.CAM) || isState(.OPT) } }
    var isCad: Bool { get { isState(.MOV) || isState(.TRN) || isState(.ZOM) } }
    
    init(startWithState state: FsmState = .VSC) {
        self.hState.push(state)
        self.eaTable = [
            /* S/E     CAM       CTL       LOD       MOV       OPT       RET       TRN       VWR       ZOM     */
            /* CAM */ [eaCamCam, eaReject, eaReject, eaReject, eaCamOpt, eaCamRet, eaReject, eaCamVwr, eaReject],
            /* LOD */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaLodRet, eaReject, eaReject, eaReject],
            /* MOV */ [eaReject, eaReject, eaReject, eaMovMov, eaReject, eaMovRet, eaReject, eaReject, eaReject],
            /* OPT */ [eaOptCam, eaReject, eaReject, eaReject, eaOptOpt, eaOptRet, eaReject, eaOptVwr, eaReject],
            /* TRN */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* VSC */ [eaReject, eaVscCtl, eaVscLod, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* VWR */ [eaVwrCam, eaReject, eaReject, eaVwrMov, eaVwrOpt, eaVwrRet, eaReject, eaVwrVwr, eaVwrZom],
            /* ZOM */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaZomRet, eaReject, eaReject, eaZomZom]
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
    
    private func eaVwrVwr() { update(withState: .VWR) }
    private func eaVwrCam() { update(withState: .CAM) }
    private func eaVwrOpt() { update(withState: .OPT) }
    
    private func eaCamVwr() { update(withState: .VWR) }
    private func eaCamCam() { update(withState: .CAM) }
    private func eaCamOpt() { update(withState: .OPT) }
    
    private func eaOptVwr() { update(withState: .VWR) }
    private func eaOptCam() { update(withState: .CAM) }
    private func eaOptOpt() { update(withState: .OPT) }
    
    private func eaVwrRet() { update(withState: .VSC) }
    private func eaCamRet() { update(withState: .VSC) }
    private func eaOptRet() { update(withState: .VSC) }
    
    private func eaMovRet() {
        timeoutTask = runOnTimeout(seconds: 3) {
            do {
                try self.transition(event: .RET)
            } catch {}
        }
        
        vwrMovRecall = vwrMovAmount
        startJumpMov = nil
        
        hState.pop()
        hEvent.pop()
        
        update(withState: hState.peek() as! FsmState)
    }
    
    private func eaMovMov() {
        let movAmount = eaParam.pop() as! CGSize
        
        vwrMovAmount = startJumpMov!+vwrMovRecall+movAmount
        self.movAmount = vwrMovAmount
        
        update(withState: .MOV)
    }
    
    private func eaVwrMov() {
        timeoutTask.cancel()
        
        let movAmount = eaParam.pop() as! CGSize
        
        if startJumpMov == nil {
            startJumpMov = -movAmount
        } else {
            vwrMovAmount = startJumpMov!+vwrMovRecall+movAmount
            self.movAmount = vwrMovAmount
        }
        
        update(withState: .MOV, noHistory: false)
    }
    
    private func eaZomRet() {
        timeoutTask = runOnTimeout(seconds: 3) {
            do {
                try self.transition(event: .RET)
            } catch {}
        }
        
        vwrZomRecall = vwrZomAmount
        startJumpZom = nil
        
        hState.pop()
        hEvent.pop()
        
        update(withState: hState.peek() as! FsmState)
    }
    
    private func eaZomZom() {
        let zomAmount = eaParam.pop() as! CGFloat
        
        vwrZomAmount = startJumpZom!+vwrZomRecall+zomAmount
        self.zomAmount = vwrZomAmount
        
        update(withState: .ZOM)
    }
    
    private func eaVwrZom() {
        timeoutTask.cancel()
        
        let zomAmount = eaParam.pop() as! CGFloat
        
        if startJumpZom == nil {
            startJumpZom = -zomAmount
        } else {
            vwrZomAmount = startJumpZom!+vwrZomRecall+zomAmount
            self.zomAmount = vwrZomAmount
        }
        
        update(withState: .ZOM, noHistory: false)
    }
    
    private func eaVscCtl() {
        timeoutTask = runOnTimeout(seconds: 3) {
            do {
                try self.transition(event: .RET)
            } catch {}
        }
        
        movAmount = CGSize.zero
        vwrMovAmount = CGSize.zero
        vwrMovRecall = CGSize.zero
        startJumpMov = nil
        zomAmount = 1.0
        vwrZomAmount = 1.0
        vwrZomRecall = 1.0
        startJumpZom = nil
        
        let pressedSideButton = eaParam.pop() as! ButtonType
        
        let nextState: FsmState
        switch pressedSideButton {
        case .Viewer:
            nextState = .VWR
        case .Camera:
            nextState = .CAM
        case .Optics:
            nextState = .OPT
        default:
            nextState = .OPT
        }
        
        update(withState: nextState)
    }
    
    private func eaLodRet() {
        hState.pop()
        hEvent.pop()
        
        update(withState: hState.peek(.last) as! FsmState)
    }
    
    private func eaVscLod() {
        let raycer = eaParam.pop() as! Rtow
        let things = eaParam.pop() as! Things
        
        outbackTask = runInOutback {
            let numRowsAtOnce = ProcessInfo.processInfo.processorCount/2*3
            await raycer.render(numRowsAtOnce: numRowsAtOnce, things: things)
            do {
                try self.transition(event: .RET)
            } catch {}
        }
        
        update(withState: .LOD, noHistory: false)
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
                try Task.checkCancellation()
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
