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

struct FsmHState: Stack {
    var stack: Array<Any>! = []
}

struct FsmHEvent: Stack {
    var stack: Array<Any>! = []
}

class EaParam: Stack {
    var stack: Array<Any>! = []
}

class Fsm: ObservableObject {
    @Published private(set) var hState = FsmHState()
    @Published private(set) var hEvent = FsmHEvent()
    
    @Published private(set) var vwrMovAmount = CGSize.zero
    private var vwrMovRecall = CGSize.zero
    private var startJumpVwrMov = CGSize.zero
    @Published private(set) var vwrZomAmount = 1.0
    private var vwrZomRecall = 1.0
    private var startJumpVwrZom = CGFloat.zero
    
    private var camMovAmount = CGSize.zero
    private var camMovRecall = CGSize.zero
    private var startJumpCamMov = CGSize.zero
    @Published private(set) var camMovAngle: CameraDirection = (
        rotationAngle: .zero,
        rotationAxis: (x: .zero, y: .zero, z: .zero))
    private let camMovCoeff = 0.31415
    @Published private(set) var camTrnAmount = CGFloat.zero
    private var camTrnRecall = CGFloat.zero
    private var startJumpCamTrn = CGFloat.zero
    
    private var optMovAmount = CGSize.zero
    private var optMovRecall = CGSize.zero
    private var startJumpOptMov = CGSize.zero
    @Published private(set) var optMovAngle = CGFloat.zero
    private let optMovCoeff = 0.31415
    @Published private(set) var optTrnAmount = CGFloat.zero
    private var optTrnRecall = CGFloat.zero
    private var startJumpOptTrn = CGFloat.zero
    @Published private(set) var optZomAmount = 1.0
    private var optZomRecall = 1.0
    private var startJumpOptZom = CGFloat.zero
    
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
            /* CAM */ [eaCamCam, eaReject, eaReject, eaCamMov, eaCamOpt, eaCamRet, eaCamTrn, eaCamVwr, eaReject],
            /* LOD */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaLodRet, eaReject, eaReject, eaReject],
            /* MOV */ [eaReject, eaReject, eaReject, eaMovMov, eaReject, eaMovRet, eaReject, eaReject, eaReject],
            /* OPT */ [eaOptCam, eaReject, eaReject, eaOptMov, eaOptOpt, eaOptRet, eaOptTrn, eaOptVwr, eaOptZom],
            /* TRN */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaTrnRet, eaTrnTrn, eaReject, eaReject],
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
    
    private func eaVwrRet() { eaParam.pop() ; update(withState: .VSC) }
    private func eaCamRet() { eaParam.pop() ; update(withState: .VSC) }
    private func eaOptRet() { eaParam.pop() ; update(withState: .VSC) }
    
    private func eaMovRet() {
        timeoutTask = runOnTimeout(seconds: 3) {
            do {
                try self.transition(event: .RET)
            } catch {}
        }
        
        let hState = self.hState.peek(.lastButOne) as! FsmState
        
        switch hState {
        case .VWR:
            vwrMovRecall = vwrMovAmount
            startJumpVwrMov = .zero
        case .CAM:
            camMovRecall = camMovAmount
            startJumpCamMov = .zero
        case .OPT:
            optMovRecall = optMovAmount
            startJumpOptMov = .zero
        default:
            break
        }
        
        self.hState.pop()
        hEvent.pop()
        
        update(withState: self.hState.peek() as! FsmState)
    }
    
    private func eaMovMov() {
        let movAmount = eaParam.pop() as! CGSize
        let finderSize = eaParam.peek() as! CGSize
        let hState = self.hState.peek(.lastButOne) as! FsmState
        
        switch hState {
        case .VWR:
            vwrMovAmount = (startJumpVwrMov+vwrMovRecall+movAmount)
                .clamped(
                    to: -finderSize.width/2...finderSize.width/2,
                    and: -finderSize.height/2...finderSize.height/2)
        case .CAM:
            camMovAmount = (startJumpCamMov+camMovRecall+movAmount)
                .clamped(
                    to: -finderSize.width/2...finderSize.width/2,
                    and: -finderSize.height/2...finderSize.height/2)
            camMovAngle.0 = (
                camMovAmount.width*camMovAmount.width+camMovAmount.height*camMovAmount.height
            ).squareRoot()*camMovCoeff
            camMovAngle.1 = (x: -movAmount.height, y: movAmount.width, z: 0)
        case .OPT:
            optMovAmount = (startJumpOptMov+optMovRecall+movAmount)
                .clamped(
                    to: -finderSize.width/2...0,
                    and: -finderSize.height/2...0)
            optMovAngle = (
                optMovAmount.width*optMovAmount.width+optMovAmount.height*optMovAmount.height
            ).squareRoot()*optMovCoeff
        default:
            break
        }
        
        update(withState: .MOV)
    }
    
    private func eaTrnRet() {
        timeoutTask = runOnTimeout(seconds: 3) {
            do {
                try self.transition(event: .RET)
            } catch {}
        }
        
        let hState = self.hState.peek(.lastButOne) as! FsmState
        
        switch hState {
        case .CAM:
            camTrnRecall = camTrnAmount
            startJumpCamTrn = .zero
        case .OPT:
            optTrnRecall = optTrnAmount
            startJumpOptTrn = .zero
        default:
            break
        }
        
        self.hState.pop()
        hEvent.pop()
        
        update(withState: self.hState.peek() as! FsmState)
    }
    
    private func eaTrnTrn() {
        let trnAmount = eaParam.pop() as! CGFloat
        let hState = self.hState.peek(.lastButOne) as! FsmState
        
        switch hState {
        case .CAM:
            camTrnAmount = (startJumpCamTrn+camTrnRecall+trnAmount)
                .clamped(to: -63.0...63.0)
        case .OPT:
            optTrnAmount = (startJumpOptTrn+optTrnRecall+trnAmount)
                .clamped(to: -63.0...63.0)
        default:
            break
        }
        
        update(withState: .TRN)
    }
    
    private func eaZomRet() {
        timeoutTask = runOnTimeout(seconds: 3) {
            do {
                try self.transition(event: .RET)
            } catch {}
        }
        
        let hState = self.hState.peek(.lastButOne) as! FsmState
        
        switch hState {
        case .VWR:
            vwrZomRecall = vwrZomAmount
            startJumpVwrZom = 0
        case .OPT:
            optZomRecall = optZomAmount
            startJumpOptZom = 0
        default:
            break
        }
        
        self.hState.pop()
        hEvent.pop()
        
        update(withState: self.hState.peek() as! FsmState)
    }
    
    private func eaZomZom() {
        let zomAmount = eaParam.pop() as! CGFloat
        let hState = self.hState.peek(.lastButOne) as! FsmState
        
        switch hState {
        case .VWR:
            vwrZomAmount = (startJumpVwrZom+vwrZomRecall+zomAmount)
                .clamped(to: 0.31416...2.7182)
        case .OPT:
            optZomAmount = (startJumpOptZom+optZomRecall+zomAmount)
                .clamped(to: 0.31415...2.7182)
        default:
            break
        }
        
        update(withState: .ZOM)
    }
    
    private func eaVwrMov() {
        timeoutTask.cancel()
        
        let movAmount = eaParam.pop() as! CGSize
        startJumpVwrMov = -movAmount
        
        update(withState: .MOV, noHistory: false)
    }
    
    private func eaVwrZom() {
        timeoutTask.cancel()
        
        let zomAmount = eaParam.pop() as! CGFloat
        startJumpVwrZom = -zomAmount
        
        update(withState: .ZOM, noHistory: false)
    }
    
    private func eaCamMov() {
        timeoutTask.cancel()
        
        let movAmount = eaParam.pop() as! CGSize
        startJumpCamMov = -movAmount
        
        update(withState: .MOV, noHistory: false)
    }
    
    private func eaCamTrn() {
        timeoutTask.cancel()
        
        let trnAmount = eaParam.pop() as! CGFloat
        startJumpCamTrn = -trnAmount
        
        update(withState: .TRN, noHistory: false)
    }
    
    private func eaOptMov() {
        timeoutTask.cancel()
        
        let movAmount = eaParam.pop() as! CGSize
        startJumpOptMov = -movAmount
        
        update(withState: .MOV, noHistory: false)
    }
    
    private func eaOptTrn() {
        timeoutTask.cancel()
        
        let trnAmount = eaParam.pop() as! CGFloat
        startJumpOptTrn = -trnAmount
        
        update(withState: .TRN, noHistory: false)
    }
    
    private func eaOptZom() {
        timeoutTask.cancel()
        
        let zomAmount = eaParam.pop() as! CGFloat
        startJumpOptZom = -zomAmount
        
        update(withState: .ZOM, noHistory: false)
    }
    
    private func eaVscCtl() {
        timeoutTask = runOnTimeout(seconds: 3) {
            do {
                try self.transition(event: .RET)
            } catch {}
        }
        
        vwrMovAmount = .zero
        vwrMovRecall = .zero
        startJumpVwrMov = .zero
        vwrZomAmount = 1.0
        vwrZomRecall = 1.0
        startJumpVwrZom = .zero
        
        camMovAmount = .zero
        camMovRecall = .zero
        startJumpCamMov = .zero
        camMovAngle = (
            rotationAngle: .zero,
            rotationAxis: (x: .zero, y: .zero, z: .zero))
        camTrnAmount = .zero
        camTrnRecall = .zero
        startJumpCamTrn = .zero
        
        optMovAmount = .zero
        optMovRecall = .zero
        startJumpOptMov = .zero
        optMovAngle = .zero
        optTrnAmount = .zero
        optTrnRecall = .zero
        startJumpOptTrn = .zero
        optZomAmount = 1.0
        optZomRecall = 1.0
        startJumpOptZom = .zero
        
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
            nextState = .CAM
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
        
        print("new state \(FsmStateName[state.rawValue]) (S/E history \(hState.count)/\(hEvent.count), parameter \(eaParam.count))")
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
