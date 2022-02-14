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

class Fsm {
    var hState = FsmHState()
    var hEvent = FsmHEvent()
    var eaTable: [[FsmAction]] = [[]]
    
    init() {
        self.hState.push(FsmState.VSC)
        self.eaTable = [
            /* S/E     BAL       CAM       CTL       DIR       LOD       POS       RET       ROL       VOL       ZOM     */
            /* CAM */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* DIR */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* LOD */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* POS */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* VSC */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject]
        ]
    }
    
    func transition(event: FsmEvent) {
        let s = hState.peek()!.rawValue
        let e = event.rawValue
        
        print("event \(FsmEventName[e]) received in state \(FsmStateName[s]) : ", terminator: "")
        
        self.hEvent.push(event)
        eaTable[s][e]()
    }
    
    var isCam: Bool { get { hState.peek() == FsmState.CAM } }
    var isDir: Bool { get { hState.peek() == FsmState.DIR } }
    var isLod: Bool { get { hState.peek() == FsmState.LOD } }
    var isPos: Bool { get { hState.peek() == FsmState.POS } }
    var isVsc: Bool { get { hState.peek() == FsmState.VSC } }
    
    private func eaReject() {
        print("rejected")
        
        // let currState = hState.peek()!
        // hState.pop()
        // hEvent.pop()
        // let nextState = currState
        // hState.push(nextState)
    }
}
