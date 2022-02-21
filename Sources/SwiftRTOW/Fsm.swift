import SwiftUI

class Stack<T> {
    var stack: [T] = []
    
    func peek() -> T? {
        guard let last = stack.last else {
            return nil
        }
        return last
    }
    
    func push(_ element: T) {
        stack.append(element)
    }
    
    func pop() -> T {
        return stack.removeLast()
    }
}

enum FsmState: Int {
    case CAM, DIR, LOD, POS, VSC
}
let FsmStateName = ["CAM", "DIR", "LOD", "POS", "VSC"]

enum FsmEvent: Int {
    case BAL, CAM, CTL, DIR, LOD, POS, RET, ROL, VOL, ZOM
}
let FsmEventName = ["BAL", "CAM", "CTL", "DIR", "LOD", "POS", "RET", "ROL", "VOL", "ZOM"]

typealias FsmHState = Stack<FsmState>
typealias FsmHEvent = Stack<FsmEvent>
typealias FsmAction = () throws -> Void

class Fsm: ObservableObject {
    private var hState = FsmHState()
    private var hEvent = FsmHEvent()
    private var eaTable: [[FsmAction]] = [[]]
    private var eaParam = Stack<Any>()
    
    var isCam: Bool { get { hState.peek() == FsmState.CAM } }
    var isDir: Bool { get { hState.peek() == FsmState.DIR } }
    var isLod: Bool { get { hState.peek() == FsmState.LOD } }
    var isPos: Bool { get { hState.peek() == FsmState.POS } }
    var isVsc: Bool { get { hState.peek() == FsmState.VSC } }
    
    init(startWithState state: FsmState = FsmState.VSC) {
        self.hState.push(state)
        self.eaTable = [
            /* S/E     BAL       CAM       CTL       DIR       LOD       POS       RET       ROL       VOL       ZOM     */
            /* CAM */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaCamRet, eaReject, eaReject, eaReject],
            /* DIR */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaDirRet, eaReject, eaReject, eaReject],
            /* LOD */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaLodRet, eaReject, eaReject, eaReject],
            /* POS */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaPosRet, eaReject, eaReject, eaReject],
            /* VSC */ [eaReject, eaReject, eaVscCtl, eaReject, eaVscLod, eaReject, eaReject, eaReject, eaReject, eaReject]
        ]
    }
    
    func push(parameter: Any) { eaParam.push(parameter) }
    func pop() { _ = eaParam.pop() }
    
    func transition(event: FsmEvent) throws {
        let s = hState.peek()!.rawValue
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
            try? await Task.sleep(nanoseconds: 1*1_000_000_000)
            
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
        
        print("new state \(FsmStateName[nextState.rawValue])")
    }
    
    private func eaReject() throws {
        let currState = hState.peek()!
        _ = hState.pop()
        _ = hEvent.pop()
        let nextState = currState
        hState.push(nextState)
        
        print("rejected (keep state \(FsmStateName[nextState.rawValue]))")
        throw FsmError.unexpectedEvent
    }
}
