import SwiftUI

struct RtowView: UIViewRepresentable {
    var raycer: Rtow
    @Binding var update: Bool
    
    func makeUIView(context: Context) -> UIImageView {
        let w = raycer.imageWidth
        let h = raycer.imageHeight
        
        var imageData: [Pixel] = .init(repeating: .init(x: 0, y: 0, z: 0, w: 255), count: w*h)
        for i in imageData.indices {
            imageData[i].x = .random(in: 0...255)
            imageData[i].y = .random(in: 0...255)
            imageData[i].z = .random(in: 0...255)
            imageData[i].w = 255
        }
        
        let splash = UIImage(imageData: imageData, imageWidth: w, imageHeight: h)
        return UIImageView(image: splash)
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        if !update {
            return
        }
        
        uiView.image = UIImage(
            imageData: raycer.imageData!,
            imageWidth: raycer.imageWidth,
            imageHeight: raycer.imageHeight)!
    }
}

struct ContentView: View {
    @EnvironmentObject var raycer: Rtow
    @State private var update = false
    
    var body: some View {
        RtowView(raycer: raycer, update: $update)
            .task {
                raycer.imageWidth = 320
                raycer.imageHeight = 240
                raycer.samplesPerPixel = 1
                
                let camera = Camera()
                camera.set(aspratio: 320.0/240.0)
                
                let things = Ch13()
                things.load()
                await raycer.render(numRowsAtOnce: 12, camera: camera, things: things)
                update.toggle()
            }
            .aspectRatio(contentMode: .fill)
    }
}

@main
struct MyApp: App {
    @StateObject var raycer = Rtow()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(raycer)
        }
    }
}
