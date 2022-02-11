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
    case CAM = 0
    case DIR
    case LOD
    case POS
    case VSC
}

enum FsmEvent: Int {
    case BAL = 0
    case CAM
    case CTL
    case DIR
    case LOD
    case POS
    case RET
    case ROL
    case VOL
    case ZOM
}

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
        
        self.hEvent.push(event)
        eaTable[s][e]()
    }
    
    private func eaReject() {
        print("event \(hEvent.peek()!.rawValue) rejected in state \(hState.peek()!.rawValue)")
        
        // let currState = hState.peek()!
        // hState.pop()
        // hEvent.pop()
        // let nextState = currState
        // hState.push(nextState)
    }
}
