import SwiftUI

typealias Pixel = SIMD4<UInt8>

class Rtow: @unchecked Sendable, ObservableObject {
    var imageWidth = 1200
    var imageHeight = 800
    var samplesPerPixel = 10
    var traceDepth = 50
    
    private(set) var camera = Camera()
    private(set) var imageData: [Pixel]?
    
    @Published private(set) var rowRenderProgress = 0
    
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
    
    private func trace(ray: Ray, things: Things, traceDepth: Int) -> C {
        var rayload = Rayload()
        
        #if RECURSIVE // (original RTOW)
        
        if things.hit(ray: ray, tmin: kAcne0, tmax: kInfinity, rayload: &rayload) {
            var sprayed = Ray()
            var attened = C(x: 0,y: 0, z: 0)
            if traceDepth>0 && rayload.optics!.spray(ray: ray, rayload: rayload, attened: &attened, sprayed: &sprayed) {
                return attened*trace(ray: sprayed, things: things, traceDepth: traceDepth-1)
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
            if !things.hit(ray: sprayed, tmin: kAcne0, tmax: kInfinity, rayload: &rayload) {
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
    
    func render(things: Things) {
        imageData = .init(
            repeating: .init(x: 0, y: 0, z: 0, w: 255),
            count: imageWidth*imageHeight)
        rowRenderProgress = 0
        
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
                    color += trace(ray: ray, things: things, traceDepth: traceDepth)
                    k += 1
                }
                imageData![(-1+imageHeight-y)*imageWidth+x] = Rtow.sRGB(color: color/Float(samplesPerPixel))
                x += 1
            }
            y += 1
            rowRenderProgress = y
        }
    }
    
    #else // CONCURRENT
    
    func render(numRowsAtOnce threads: Int, things: Things) async {
        imageData = .init(
            repeating: .init(x: 0, y: 0, z: 0, w: 255),
            count: imageWidth*imageHeight)
        rowRenderProgress = 0
        
        var threadGroupSize = max(threads, 1)
        
        var y = 0
        while y<imageHeight {
            let rowsRemaining = -1+imageHeight-1
            if threadGroupSize>rowsRemaining {
                threadGroupSize = rowsRemaining
            }
            
            await withTaskGroup(of: Void.self) { [things] threadGroup in
                let baseRow = y
                for rowIndex in 0..<threadGroupSize {
                    threadGroup.addTask { [unowned self, things] in
                        let y = baseRow+rowIndex
                        var x = 0
                        while x<imageWidth {
                            var color = C(x: 0, y: 0, z: 0)
                            var k = 0
                            while k<samplesPerPixel {
                                let s = 2.0*(Float(x)+Util.rnd())/(Float(imageWidth-1))-1.0
                                let t = 2.0*(Float(y)+Util.rnd())/(Float(imageHeight-1))-1.0
                                let ray = camera.ray(s: s, t: t)
                                color += trace(ray: ray, things: things, traceDepth: traceDepth)
                                k += 1
                            }
                            imageData![(-1+imageHeight-y)*imageWidth+x] = Rtow.sRGB(color: color/Float(samplesPerPixel))
                            x += 1
                        }
                    }
                }
            }
            y += threadGroupSize
            rowRenderProgress = y
        }
    }
    
    #endif // SINGLETASK
}