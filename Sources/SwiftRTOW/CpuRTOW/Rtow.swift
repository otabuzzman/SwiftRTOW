import SwiftUI

typealias Pixel = SIMD4<UInt8>

@MainActor
class Rtow: @unchecked Sendable, ObservableObject {
    var imageWidth = 1200
    var imageHeight = 800
    var samplesPerPixel = 10
    var traceDepth = 50
    
    private(set) var imageData: [Pixel]?
    
    @Published private(set) var rowRenderProgress = 0
    @Published private(set) var rowRenderFinished = false
    
    private nonisolated static func sRGB(color: C) -> Pixel {
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
    
    private nonisolated static func trace(ray: Ray, things: Things, traceDepth: Int) -> C {
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
    
    func render(camera: camera, things: Things) {
        imageData = .init(
            repeating: .init(x: 0, y: 0, z: 0, w: 255),
            count: imageWidth*imageHeight)
        rowRenderProgress = 0
        rowRenderFinished = false
        
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
        rowRenderFinished = true
    }
    
    #else // CONCURRENT
    
    func render(numRowsAtOnce threads: Int, camera: Camera, things: Things) async {
        imageData = .init(
            repeating: .init(x: 0, y: 0, z: 0, w: 255),
            count: imageWidth*imageHeight)
        rowRenderProgress = 0
        rowRenderFinished = false
        
        var threadGroupSize = max(threads, 1)
        
        var y = 0
        while y<imageHeight {
            let rowsRemaining = imageHeight-y
            if threadGroupSize>rowsRemaining {
                threadGroupSize = rowsRemaining
            }
            
            let imageRows = await Rtow.render(numRowsAtOnce: threadGroupSize, baseRow: y, imageWidth: imageWidth, imageHeight: imageHeight, traceDepth: traceDepth, samplesPerPixel: samplesPerPixel, camera: camera, things: things)
            
            y += threadGroupSize
            
            for p in 0..<imageRows.count {
                imageData![(imageHeight-y)*imageWidth+p] = imageRows[p]
            }
            rowRenderProgress = y
        }
        rowRenderFinished = true
    }
    
    private static nonisolated func render(numRowsAtOnce: Int, baseRow: Int, imageWidth: Int, imageHeight: Int, traceDepth: Int, samplesPerPixel: Int, camera: Camera, things: Things) async -> [Pixel] {
            var imageData: [Pixel] = .init(
                repeating: .init(x: 0, y: 0, z: 0, w: 255),
                count: numRowsAtOnce*imageWidth)
                
            await withTaskGroup(of: (Int, [Pixel]).self) { threadGroup in
                for rowIndex in 0..<numRowsAtOnce {
                    threadGroup.addTask {
                        var imageRow: [Pixel] = .init(
                            repeating: .init(x: 0, y: 0, z: 0, w: 255),
                            count: imageWidth)
                            
                        let y = baseRow+rowIndex
                        var x = 0
                        while x<imageWidth {
                            var color = C(x: 0, y: 0, z: 0)
                            var k = 0
                            while k<samplesPerPixel {
                                let s = 2.0*(Float(x)+Util.rnd())/(Float(imageWidth-1))-1.0
                                let t = 2.0*(Float(y)+Util.rnd())/(Float(imageHeight-1))-1.0
                                let ray = camera.ray(s: s, t: t)
                                color += Rtow.trace(ray: ray, things: things, traceDepth: traceDepth)
                                k += 1
                            }
                            imageRow[x] = Rtow.sRGB(color: color/Float(samplesPerPixel))
                            x += 1
                        }
                        
                        return (rowIndex, imageRow)
                    }
                }
                
                for await (rowIndex, imageRow) in threadGroup {
                    for p in 0..<imageRow.count {
                        imageData[(-1+numRowsAtOnce-rowIndex)*imageWidth+p] = imageRow[p]
                    }
                }
            }
            
        return imageData
    }
    
    #endif // SINGLETASK
}
