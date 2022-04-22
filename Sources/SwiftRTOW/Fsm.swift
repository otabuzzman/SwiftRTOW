import SwiftUI

enum FsmState: Int {
    case CAM, LOD, MOV, OPT, SAV, TRN, VSC, VWR, ZOM
}
let FsmStateName = ["CAM", "LOD", "MOV", "OPT", "SAV", "TRN", "VSC", "VWR", "ZOM"]

enum FsmEvent: Int {
    case CAM, CTL, LOD, MOV, OPT, RET, SAV, TRN, VWR, ZOM
}
let FsmEventName = ["CAM", "CTL", "LOD", "MOV", "OPT", "RET", "SAV", "TRN", "VWR", "ZOM"]

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

typealias CamMovRotate = (amount: CGFloat, axis: (CGFloat, CGFloat, CGFloat))

class Fsm: ObservableObject {
    @Published private(set) var hState = FsmHState()
    @Published private(set) var hEvent = FsmHEvent()
    
    // viewer controls
    @Published private(set) var vwrMovAmount = CGSize.zero
    private var vwrMovRecall = CGSize.zero
    private var startJumpVwrMov = CGSize.zero
    @Published private(set) var vwrZomAmount = 1.0
    private var vwrZomRecall = 1.0
    private var startJumpVwrZom = CGFloat.zero
    // camera controls
    private var camMovAmount = CGSize.zero
    private var camMovRecall = CGSize.zero
    private var startJumpCamMov = CGSize.zero
    @Published private(set) var camMovRotate: CamMovRotate = (amount: .zero, axis: (x: .zero, y: .zero, z: .zero))
    @Published private(set) var camTrnAmount = CGFloat.zero
    private var camTrnRecall = CGFloat.zero
    private var startJumpCamTrn = CGFloat.zero
    // optics controls
    @Published private(set) var optMovAmount = CGFloat.zero
    private var optMovRecall = CGFloat.zero
    private var startJumpOptMov = CGFloat.zero
    @Published private(set) var optTrnAmount = CGFloat.zero
    private var optTrnRecall = CGFloat.zero
    private var startJumpOptTrn = CGFloat.zero
    @Published private(set) var optZomAmount = 1.0
    private var optZomRecall = 1.0
    private var startJumpOptZom = CGFloat.zero
    
    private var cadPaddle = Paddle()
    private var cadUpdate = false
    
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
            /* S/E     CAM       CTL       LOD       MOV       OPT       RET       SAV       TRN       VWR       ZOM     */
            /* CAM */ [eaCamCam, eaReject, eaReject, eaCamMov, eaCamOpt, eaCamRet, eaReject, eaCamTrn, eaCamVwr, eaReject],
            /* LOD */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaLodRet, eaReject, eaReject, eaReject, eaReject],
            /* MOV */ [eaReject, eaReject, eaReject, eaMovMov, eaReject, eaMovRet, eaReject, eaReject, eaReject, eaReject],
            /* OPT */ [eaOptCam, eaReject, eaReject, eaOptMov, eaOptOpt, eaOptRet, eaReject, eaOptTrn, eaOptVwr, eaOptZom],
            /* SAV */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject, eaReject],
            /* TRN */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaTrnRet, eaReject, eaTrnTrn, eaReject, eaReject],
            /* VSC */ [eaReject, eaVscCtl, eaVscLod, eaReject, eaReject, eaReject, eaVscSav, eaReject, eaReject, eaReject],
            /* VWR */ [eaVwrCam, eaReject, eaReject, eaVwrMov, eaVwrOpt, eaVwrRet, eaReject, eaReject, eaVwrVwr, eaVwrZom],
            /* ZOM */ [eaReject, eaReject, eaReject, eaReject, eaReject, eaZomRet, eaReject, eaReject, eaReject, eaZomZom]
            ]
    }
    
    func push(parameter: Any) { eaParam.push(parameter) }
    @discardableResult func pop() -> Any { eaParam.pop() }
    
    func transition(event: FsmEvent) throws {
        let s = (hState.peek() as! FsmState).rawValue
        let e = event.rawValue
        
        if _isDebugAssertConfiguration() && trace {
            print("state \(FsmStateName[s]) received event \(FsmEventName[e]) : ", terminator: "")
        }
        
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
    
    private func eaCslRet() {
        eaParam.pop() // finderHeight
        eaParam.pop() // finderWidth
        
        if cadUpdate {
            let raycer = eaParam.pop() as! Rtow
            let camera = eaParam.pop() as! Camera
            let things = eaParam.pop() as! Things
        
            outbackTask = runInOutback {
                let numRowsAtOnce = ProcessInfo.processInfo.processorCount/2*3
                await raycer.render(numRowsAtOnce: numRowsAtOnce, camera: camera, things: things)
            
                try? self.transition(event: .RET)
            }
            
            update(withState: .LOD)
        } else {
            eaParam.pop() // raycer
            eaParam.pop() // camera
            eaParam.pop() // things
            
            update(withState: .VSC)
        }
    }
    private func eaVwrRet() { eaCslRet() }
    private func eaCamRet() { eaCslRet() }
    private func eaOptRet() { eaCslRet() }
    
    private func eaMovRet() throws {
        timeoutTask = runOnTimeout(seconds: 3) {
            try? self.transition(event: .RET)
        }
        
        let hState = self.hState.peek(.lastButOne) as! FsmState
        let camera = eaParam.peek(.thirdToLast) as! Camera
        
        switch hState {
        case .VWR:
            vwrMovRecall = vwrMovAmount
            startJumpVwrMov = .zero
            
            let pat = camera.pat
            let len = (camera.eye-pat).len()
            let x = Int(vwrMovAmount.width)
            let y = Int(vwrMovAmount.height)
            let eye = pat+len*cadPaddle.move(x: -x, y: -y)
            camera.set(eye: eye)
        case .CAM:
            camMovRecall = camMovAmount
            startJumpCamMov = .zero
            
            let eye = camera.eye
            let len = (eye-camera.pat).len()
            let x = Int(camMovAmount.width)
            let y = Int(camMovAmount.height)
            let pat = eye-len*cadPaddle.move(x: x, y: y)
            camera.set(pat: pat)
        case .OPT:
            optMovRecall = optMovAmount
            startJumpOptMov = .zero
            
            let adj = powf(1.25, Float(-optMovAmount)/10.0)
            camera.set(aperture: adj*camera.aperture)
        default:
            throw FsmError.unexpectedFsmState
        }
        
        cadUpdate = true
        
        self.hState.pop()
        hEvent.pop()
        
        update(withState: self.hState.peek() as! FsmState)
    }
    
    private func eaMovMov() throws {
        let movAmount = eaParam.pop() as! CGSize
        let finderHeight = eaParam.peek() as! CGFloat
        let finderWidth = eaParam.peek(.lastButOne) as! CGFloat
        let hState = self.hState.peek(.lastButOne) as! FsmState
        
        switch hState {
        case .VWR:
            vwrMovAmount = (startJumpVwrMov+vwrMovRecall+movAmount)
                .clamped(
                    to: -finderWidth/3...finderWidth/3,
                    and: -finderHeight/3...finderHeight/3)
        case .CAM:
            camMovAmount = (startJumpCamMov+camMovRecall+movAmount)
                .clamped(
                    to: -finderWidth/3...finderWidth/3,
                    and: -finderHeight/3...finderHeight/3)
            camMovRotate.0 = (
                camMovAmount.width*camMovAmount.width+camMovAmount.height*camMovAmount.height
            ).squareRoot()
            camMovRotate.1 = (x: -movAmount.height, y: movAmount.width, z: 0)
        case .OPT:
            optMovAmount = startJumpOptMov+optMovRecall+movAmount.height
                .clamped(to: -finderHeight/2...finderHeight/2)
        default:
            throw FsmError.unexpectedFsmState
        }
        
        update(withState: .MOV)
    }
    
    private func eaTrnRet() throws {
        timeoutTask = runOnTimeout(seconds: 3) {
            try? self.transition(event: .RET)
        }
        
        let hState = self.hState.peek(.lastButOne) as! FsmState
        let camera = eaParam.peek(.thirdToLast) as! Camera
        
        switch hState {
        case .CAM:
            camTrnRecall = camTrnAmount
            startJumpCamTrn = .zero
            
            let rad = Float.pi/180.0
            let sina = sinf(Float(-camTrnAmount)*rad)
            let cosa = cosf(Float(-camTrnAmount)*rad)
            let x = camera.vup.x
            let y = camera.vup.y
            let vup = V(x: x*cosa-y*sina, y: x*sina+y*cosa, z: 0)
            camera.set(vup: vup)
        case .OPT:
            optTrnRecall = optTrnAmount
            startJumpOptTrn = .zero
            
            let adj = powf(1.25, Float(-optTrnAmount)/6.3)
            camera.set(fostance: adj*camera.fostance)
        default:
            throw FsmError.unexpectedFsmState
        }
        
        cadUpdate = true
        
        self.hState.pop()
        hEvent.pop()
        
        update(withState: self.hState.peek() as! FsmState)
    }
    
    private func eaTrnTrn() throws {
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
            throw FsmError.unexpectedFsmState
        }
        
        update(withState: .TRN)
    }
    
    private func eaZomRet() throws {
        timeoutTask = runOnTimeout(seconds: 3) {
            try? self.transition(event: .RET)
        }
        
        let hState = self.hState.peek(.lastButOne) as! FsmState
        let camera = eaParam.peek(.thirdToLast) as! Camera
        
        switch hState {
        case .VWR:
            vwrZomRecall = vwrZomAmount
            startJumpVwrZom = 0
            
            let pat = camera.pat
            let adj = Float(vwrZomAmount)
            camera.set(eye: pat+adj*(camera.eye-pat))
        case .OPT:
            optZomRecall = optZomAmount
            startJumpOptZom = 0
            
            let adj = Float(optZomAmount)
            camera.set(fov: adj*camera.fov)
        default:
            throw FsmError.unexpectedFsmState
        }
        
        cadUpdate = true
        
        self.hState.pop()
        hEvent.pop()
        
        update(withState: self.hState.peek() as! FsmState)
    }
    
    private func eaZomZom() throws {
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
            throw FsmError.unexpectedFsmState
        }
        
        update(withState: .ZOM)
    }
    
    private func eaVwrMov() {
        timeoutTask.cancel()
        
        let movAmount = eaParam.pop() as! CGSize
        startJumpVwrMov = -movAmount
        
        cadPaddle.reset(x: 0, y: 0)
        
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
        
        cadPaddle.reset(x: 0, y: 0)
        
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
        startJumpOptMov = -movAmount.height
        
        cadPaddle.reset(x: 0, y: 0)
        
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
    
    private func eaVscCtl() throws {
        timeoutTask = runOnTimeout(seconds: 3) {
            try? self.transition(event: .RET)
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
        camMovRotate = (amount: .zero, axis: (x: .zero, y: .zero, z: .zero))
        camTrnAmount = .zero
        camTrnRecall = .zero
        startJumpCamTrn = .zero
        
        optMovAmount = .zero
        optMovRecall = .zero
        startJumpOptMov = .zero
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
            throw FsmError.unexpectedError
        }
        
        let camera = eaParam.peek(.thirdToLast) as! Camera
        cadPaddle.gauge(eye: camera.eye, pat: camera.pat, vup: camera.vup)
        cadUpdate = false
        
        update(withState: nextState)
    }
    
    private func eaLodRet() {
        update(withState: .VSC)
    }
    
    private func eaVscLod() {
        let raycer = eaParam.pop() as! Rtow
        let camera = eaParam.pop() as! Camera
        let things = eaParam.pop() as! Things
        
        outbackTask = runInOutback {
            let numRowsAtOnce = ProcessInfo.processInfo.processorCount/2*3
            await raycer.render(numRowsAtOnce: numRowsAtOnce, camera: camera, things: things)
            
            try? self.transition(event: .RET)
        }
        
        update(withState: .LOD)
    }
    
    private func eaVscSav() {
        let imageData = eaParam.pop() as! UnsafeBufferPointer<Pixel>
        let imageHeight = eaParam.pop() as! Int
        let imageWidth = eaParam.pop() as! Int
        let image = UIImage(
            imageData: Array(imageData),
            imageWidth: imageWidth,
            imageHeight: imageHeight)
        image!.persist(inPhotosAlbum: nil)
        
        update(withState: .VSC)
    }
    
    private func eaReject() throws {
        if _isDebugAssertConfiguration() && trace {
            print("rejected : ", terminator: "")
        }
        
        update(withState: hState.peek() as! FsmState)
        throw FsmError.unexpectedFsmEvent
    }
    
    private func update(withState state: FsmState, noHistory: Bool = true) {
        if noHistory {
            hState.pop()
            hEvent.pop()
        }
        hState.push(state)
        
        if _isDebugAssertConfiguration() && trace {
            print("new state \(FsmStateName[state.rawValue]) (S/E history \(hState.count)/\(hEvent.count), parameter \(eaParam.count))")
        }
    }
    
    @discardableResult private func runOnTimeout(seconds: Int, closure: @escaping () -> Void) -> Task<Void, Never> {
        Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(seconds*1_000_000_000))
                try Task.checkCancellation()
                
                closure()
            } catch {}
        }
    }
    
    @discardableResult private func runInOutback(closure: @escaping () async -> Void) -> Task<Void, Never> {
        Task {
            await closure()
        }
    }
}

private let trace = _isDebugAssertConfiguration()
