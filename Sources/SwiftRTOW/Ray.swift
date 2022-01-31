 public struct Ray {
    var ori = P(x: 0,y: 0, z: 0)
    var dir = V(x: 0,y: 0, z: 0)
    
    public func at(t: Float) -> P {
        return ori+t*dir
    }
}
