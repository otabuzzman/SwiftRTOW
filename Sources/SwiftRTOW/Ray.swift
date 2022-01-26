 public struct Ray {
    var ori = P()
    var dir = V()
    
    public func at(t: Float) -> P {
        return ori+t*dir
    }
}
