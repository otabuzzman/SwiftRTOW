protocol Stack {
    var stack: Array<Any>! { get set }
    
    func peek(_ element: StackIndex) -> Any?
    mutating func push(_ element: Any)
    mutating func pop() -> Any
}

extension Stack {
    var count: Int { stack.count }
    
    func peek(_ element: StackIndex = .last) -> Any? {
        let index = -1+count+element.rawValue
        if (0..<count).contains(index) {
            return stack[index]
        }
        return nil
    }
    
    mutating public func push(_ element: Any) {
        stack.append(element)
    }
    
    @discardableResult mutating public func pop() -> Any {
        return stack.removeLast()
    }
}

enum StackIndex: Int {
    case lastButTwo = -2
    case lastButOne
    case last
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
