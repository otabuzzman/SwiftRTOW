import SwiftUI

enum FsmState: Int {
    case CAM, DIR, LOD, POS, VSC
}
let FsmStateName = ["CAM", "DIR", "LOD", "POS", "VSC"]

enum FsmEvent: Int {
    case CAM, CTL, DIR, LOD, MAG, MOV, POS, RET, ROT
}
let FsmEventName = ["CAM", "CTL", "DIR", "LOD", "MAG", "MOV", "POS", "RET", "ROT"]

typealias FsmAction = () throws -> Void

class Fsm: ObservableObject {
    @Published private(set) var hState = FsmHState()
    @Published private(set) var hEvent = FsmHEvent()
    private var eaTable: [[FsmAction]] = [[]]
    private var eaParam = EaParam()
    
    var isCam: Bool { get { hState.peek() as? FsmState == FsmState.CAM } }
    var isDir: Bool { get { hState.peek() as? FsmState == FsmState.DIR } }
    var isLod: Bool { get { hState.peek() as? FsmState == FsmState.LOD } }
    var isPos: Bool { get { hState.peek() as? FsmState == FsmState.POS } }
    var isVsc: Bool { get { hState.peek() as? FsmState == FsmState.VSC } }
    
    init(startWithState state: FsmState = FsmState.VSC) {
        self.hState.push(state)
        self.eaTable = [
            /* S/E     CAM       CTL       DIR       LOD       MAG       MOV       POS       RET       ROT     */
            /* CAM */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaCamRet, eaReject],
            /* DIR */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaDirRet, eaReject],
            /* LOD */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaLodRet, eaReject],
            /* POS */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaPosRet, eaReject],
            /* VSC */ [eaReject, eaVscCtl, eaReject, eaVscLod, eaReject, eaReject, eaReject, eaReject, eaReject]
        ]
    }
    
    func push(parameter: Any) { eaParam.push(parameter) }
    func pop() { _ = eaParam.pop() }
    
    func transition(event: FsmEvent) throws {
        let s = (hState.peek() as! FsmState).rawValue
        let e = event.rawValue
        
        print("state \(FsmStateName[s]) received event \(FsmEventName[e]) : ", terminator: "")
        
        self.hEvent.push(event)
        try eaTable[s][e]()
    }
    
    private func eaPosRet() {
        _ = hState.pop()
        _ = hEvent.pop()
        let nextState = FsmState.VSC
        hState.push(nextState)
        
        print("new state \(FsmStateName[nextState.rawValue])")
    }
    
    private func eaDirRet() {
        _ = hState.pop()
        _ = hEvent.pop()
        let nextState = FsmState.VSC
        hState.push(nextState)
        
        print("new state \(FsmStateName[nextState.rawValue])")
    }
    
    private func eaCamRet() {
        _ = hState.pop()
        _ = hEvent.pop()
        let nextState = FsmState.VSC
        hState.push(nextState)
        
        print("new state \(FsmStateName[nextState.rawValue])")
    }
    
    private func eaVscCtl() {
        let pressedSideButton = eaParam.pop() as! ButtonType
        
        let autoReturnTask = Task {
            try? await Task.sleep(nanoseconds: 3*1_000_000_000)
            
            _ = eaParam.pop() // autoReturnTask
            try transition(event: FsmEvent.RET)
        }
        eaParam.push(autoReturnTask)
        
        _ = hState.pop()
        _ = hEvent.pop()
        
        let nextState: FsmState
        switch pressedSideButton {
        case .Viewer:
            nextState = FsmState.POS
        case .Camera:
            nextState = FsmState.DIR
        case .Optics:
            nextState = FsmState.CAM
        default:
            nextState = FsmState.CAM
        }
        hState.push(nextState)
        
        print("new state \(FsmStateName[nextState.rawValue])")
    }
    
    private func eaVscLod() {
        let raycer = eaParam.pop() as! Rtow
        let things = eaParam.pop() as! Things
        
        Task {
            let numRowsAtOnce = ProcessInfo.processInfo.processorCount/2*3
            await raycer.render(numRowsAtOnce: numRowsAtOnce, things: things)
            
            try transition(event: FsmEvent.RET)
        }
        
        // keep H state
        // _ = hState.pop()
        _ = hEvent.pop()
        let nextState = FsmState.LOD
        hState.push(nextState)
        
        print("new state \(FsmStateName[nextState.rawValue])")
    }
    
    private func eaLodRet() {
        _ = hState.pop()
        _ = hEvent.pop()
        let nextState = hState.peek()!
        
        print("new state \(FsmStateName[(nextState as! FsmState).rawValue])")
    }
    
    private func eaReject() throws {
        let currState = hState.peek()!
        _ = hState.pop()
        _ = hEvent.pop()
        let nextState = currState
        hState.push(nextState)
        
        print("rejected (keep state \(FsmStateName[(nextState as! FsmState).rawValue]))")
        throw FsmError.unexpectedEvent
    }
}
