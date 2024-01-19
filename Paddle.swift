import simd

struct Paddle {
    private let u = V(x: 1.0, y: 0, z: 0)
    private let v = V(x: 0, y: 0, z: 1.0)
    private let w = V(x: 0, y: 1.0, z: 0)
    private var lo: Float = 0
    private var la: Float = 0
    private var x: Int = 0
    private var y: Int = 0
    private var vup: V = .zero
    private var phi: Float = 0
    
    private let deg = 180.0/Float.pi
    private let rad = Float.pi/180.0
    
    mutating func gauge(eye: P, pat: P, vup: V) {
        let d = (eye-pat).unitV()
        var x = d•u
        var y = d•v
        let z = d•w
        lo = atan2f(x, y)
        la = asinf(z)
        
        self.vup = vup.unitV()
        x = self.vup•u
        y = self.vup•w
        phi = atan2f(x, y)
    }
    
    mutating func reset(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    mutating func move(x: Int, y: Int, coeff: Float = 0.25) -> V {
        let dx = x-self.x
        let dy = y-self.y
        self.x = x
        self.y = y
        lo = fmodf((lo*deg)-coeff*Float(dx), 360.0)*rad
        la = min(89.999, max(-89.999, (la*deg)+coeff*Float(dy)))*rad
        let u = cosf(la)*sinf(lo)
        let v = cosf(la)*cosf(lo)
        let w = sinf(la)
        
        return u*self.u+v*self.v+w*self.w
    }
    
    mutating func roll(s: Int, coeff: Float = 2.0) -> V {
        phi = fmodf((phi*deg)+coeff*Float(s), 360.0)*rad
        let x = cosf(phi)
        let y = sinf(phi)
        let z = vup.z
        
        return V(x: x, y: y, z: z)
    }
}
