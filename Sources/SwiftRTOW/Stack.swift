protocol Stack {
    var stack: Array<Any>! { get set }
    
    func peek() -> Any?
    mutating func push(_ element: Any)
    mutating func pop() -> Any
}

extension Stack {
    func peek() -> Any? {
        guard let last = stack.last else {
            return nil
        }
        return last
    }
    
    mutating public func push(_ element: Any) {
        stack.append(element)
    }
    
    mutating public func pop() -> Any {
        return stack.removeLast()
    }
}

struct FsmHState: Stack {
    var stack: Array<Any>! = []
}

struct FsmHEvent: Stack {
    var stack: Array<Any>! = []
}

class EaParam: Stack {
    var stack: Array<Any>! = []
}
