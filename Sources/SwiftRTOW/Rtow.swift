typealias Pixel = SIMD4<UInt8>

class Rtow: @unchecked Sendable {
    var imageWidth = 1200
    var imageHeight = 800
    var samplesPerPixel = 10
    var traceDepth = 50
    
    private(set) var camera = Camera()
    private(set) var imageData: [Pixel]?
    
    init() {}
    
    private static func sRGB(color: C) -> Pixel {
        var r = color.x
        var g = color.y
        var b = color.z
        
        r = r.squareRoot()
        g = g.squareRoot()
        b = b.squareRoot()
        
        r = Util.clamp(x: r, min: 0, max: 0.999)
        g = Util.clamp(x: g, min: 0, max: 0.999)
        b = Util.clamp(x: b, min: 0, max: 0.999)
        
        let r8 = UInt8(256*Util.clamp(x: r, min: 0, max: 0.999))
        let g8 = UInt8(256*Util.clamp(x: g, min: 0, max: 0.999))
        let b8 = UInt8(256*Util.clamp(x: b, min: 0, max: 0.999))
        
        return Pixel(x: r8, y: g8, z: b8, w: 255)
    }
    
    private func trace(ray: Ray, scene: Things, traceDepth: Int) -> C {
        var rayload = Rayload()
        
        #if RECURSIVE // (original RTOW)
        
        if scene.hit(ray: ray, tmin: kAcne0, tmax: kInfinity, rayload: &rayload) {
            var sprayed = Ray()
            var attened = C(x: 0,y: 0, z: 0)
            if traceDepth>0 && rayload.optics!.spray(ray: ray, rayload: rayload, attened: &attened, sprayed: &sprayed) {
                return attened*trace(ray: sprayed, scene: scene, traceDepth: traceDepth-1)
            }
            
            return C(x: 0, y: 0, z: 0)
        }
        
        let unit = ray.dir.unitV()
        let t = 0.5*(unit.y+1.0)
        
        return (1.0-t)*C(x: 1.0, y: 1.0, z: 1.0)+t*C(x: 0.5, y: 0.7, z: 1.0)
        
        #else // ITERATIVE
        
        var sprayed = ray
        var attened = C(x: 1.0, y: 1.0, z: 1.0)
        var d = 0
        while d<traceDepth {
            if !scene.hit(ray: sprayed, tmin: kAcne0, tmax: kInfinity, rayload: &rayload) {
                let unit = sprayed.dir.unitV()
                let t = 0.5*(unit.y+1.0)
                
                return attened*((1.0-t)*C(x: 1.0, y: 1.0, z: 1.0)+t*C(x: 0.5, y: 0.7, z: 1.0))
            }
            var c = C(x: 0, y: 0, z: 0)
            if !rayload.optics!.spray(ray: sprayed, rayload: rayload, attened: &c, sprayed: &sprayed) {
                return C(x: 0, y: 0, z: 0)
            }
            attened *= c
            d += 1
        }
        
        return attened
        
        #endif // RECURSIVE
    }
    
    #if SINGLETASK // (original RTOW)
    
    func render(things: Stage) {
        imageData = .init(
            repeating: .init(x: 0, y: 0, z: 0, w: 255),
            count: imageWidth*imageHeight)
        
        var y = 0
        while y<imageHeight {
            var x = 0
            while x<imageWidth {
                var color = C(x: 0, y: 0, z: 0)
                var k = 0
                while k<samplesPerPixel {
                    let s = 2.0*(Float(x)+Util.rnd())/(Float(imageWidth-1))-1.0
                    let t = 2.0*(Float(y)+Util.rnd())/(Float(imageHeight-1))-1.0
                    let ray = camera.ray(s: s, t: t)
                    color += trace(ray: ray, scene: things, traceDepth: traceDepth)
                    k += 1
                }
                imageData![(-1+imageHeight-y)*imageWidth+x] = Rtow.sRGB(color: color/Float(samplesPerPixel))
                x += 1
            }
            y += 1
        }
    }
    
    #else // CONCURRENT
    
    func render(numRowsAtOnce threads: Int, things: Stage) async {
        imageData = .init(
            repeating: .init(x: 0, y: 0, z: 0, w: 255),
            count: imageWidth*imageHeight)
        
        var threadGroupSize = max(threads, 1)
        
        var y = 0
        while y<imageHeight {
            let rowsRemaining = -1+imageHeight-1
            if threadGroupSize>rowsRemaining {
                threadGroupSize = rowsRemaining
            }
            
            await withTaskGroup(of: Void.self) { [unowned things] threadGroup in
                let baseRow = y
                for rowIndex in 0..<threadGroupSize {
                    threadGroup.addTask { [unowned self, unowned things] in
                        let y = baseRow+rowIndex
                        var x = 0
                        while x<imageWidth {
                            var color = C(x: 0, y: 0, z: 0)
                            var k = 0
                            while k<samplesPerPixel {
                                let s = 2.0*(Float(x)+Util.rnd())/(Float(imageWidth-1))-1.0
                                let t = 2.0*(Float(y)+Util.rnd())/(Float(imageHeight-1))-1.0
                                let ray = camera.ray(s: s, t: t)
                                color += trace(ray: ray, scene: things, traceDepth: traceDepth)
                                k += 1
                            }
                            imageData![(-1+imageHeight-y)*imageWidth+x] = Rtow.sRGB(color: color/Float(samplesPerPixel))
                            x += 1
                        }
                    }
                }
            }
            y += threadGroupSize
        }
    }
    
    #endif // SINGLETASK
}



#if os(Windows)

@main // https://github.com/apple/swift-package-manager/blob/main/Documentation/PackageDescription.md#target
extension Rtow {
    // https://www.swift.org/blog/argument-parser/
    static func main() async {
        let w = 320
        let h = 240
        
        let rtow = Rtow()
        rtow.imageWidth = w
        rtow.imageHeight = h
        rtow.samplesPerPixel = 1
        rtow.camera.set(aspratio: Float(w)/Float(h))
        
        let things = Stage()
        things.load()
        
        #if SINGLETASK
        rtow.render(things: things)
        #else
        await rtow.render(numRowsAtOnce: 4, things: things)
        #endif
        
        print("P3")
        print("\(w) \(h)\n255")
        var p = 0
        while p<rtow.imageData!.count {
            let pixel = rtow.imageData![p]
            print("\(pixel.x) \(pixel.y) \(pixel.z)")
            p += 1
        }
    }
}

#endif
