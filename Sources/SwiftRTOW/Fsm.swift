import SwiftUI

struct Stack<T> {
    var stack: [T] = []
    
    func peek() -> T? {
        guard let last = stack.last else {
            return nil
        }
        return last
    }
    
    mutating func push(_ element: T) {
        stack.append(element)
    }
    
    mutating func pop() -> T {
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
typealias FsmAction = () -> Void

class Fsm: ObservableObject {
    var hState = FsmHState()
    var hEvent = FsmHEvent()
    var eaTable: [[FsmAction]] = [[]]
    var eaParam = Stack<Any>()
    
    init(startWithState state: FsmState = FsmState.VSC) {
        self.hState.push(state)
        self.eaTable = [
            /* S/E     BAL       CAM       CTL       DIR       LOD       POS       RET       ROL       VOL       ZOM     */
            /* CAM */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* DIR */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* LOD */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaLodRet, eaReject, eaReject, eaReject],
            /* POS */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* VSC */ [eaReject, eaReject, eaReject, eaReject, eaVscLod, eaReject, eaReject, eaReject, eaReject, eaReject]
        ]
    }
    
    func transition(event: FsmEvent) {
        let s = hState.peek()!.rawValue
        let e = event.rawValue
        
        print("state \(FsmStateName[s]) received event \(FsmEventName[e]) : ", terminator: "")
        
        self.hEvent.push(event)
        eaTable[s][e]()
    }
    
    var isCam: Bool { get { hState.peek() == FsmState.CAM } }
    var isDir: Bool { get { hState.peek() == FsmState.DIR } }
    var isLod: Bool { get { hState.peek() == FsmState.LOD } }
    var isPos: Bool { get { hState.peek() == FsmState.POS } }
    var isVsc: Bool { get { hState.peek() == FsmState.VSC } }
    
    private func eaVscLod() {
        let raycer = eaParam.pop() as! Rtow
        let things = eaParam.pop() as! Things
        
        Task {
            let numRowsAtOnce = ProcessInfo.processInfo.processorCount/2*3
            await raycer.render(numRowsAtOnce: numRowsAtOnce, things: things)
            
            transition(event: FsmEvent.RET)
        }
        
        // _ = hState.pop()
        _ = hEvent.pop()
        let nextState = FsmState.LOD
        hState.push(nextState)
        
        print("new state \(FsmStateName[nextState.rawValue])")
    }
    
    private func eaLodRet() {
        
        _ = hState.pop()
        _ = hEvent.pop()
        let nextState = hState.pop()
        hState.push(nextState)
        
        print("new state \(FsmStateName[nextState.rawValue])")
    }
    
    private func eaReject() {
        print("rejected")
        
        // let currState = hState.peek()!
        // _ = hState.pop()
        // _ = hEvent.pop()
        // let nextState = currState
        // hState.push(nextState)
        
        // print("new state \(FsmStateName[nextState.rawValue])")
    }
}
