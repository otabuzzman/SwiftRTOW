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
        update.toggle()
    }
}

struct ContentView: View {
    @StateObject private var raycer = Rtow()
    @State private var update = false
    @State private var course = false
    
    var body: some View {
        ZStack {
            Color.purple
                .opacity(0.2)
                .ignoresSafeArea()
                
            VStack {
                ZStack(alignment: .bottomLeading) {
                    RtowView(raycer: raycer, update: $update)
                    .task {
                        raycer.imageWidth = 320
                        raycer.imageHeight = 240
                        raycer.samplesPerPixel = 1
                        raycer.camera.set(aspratio: 320.0/240.0)
                        
                        course.toggle()
                        let things = Ch10()
                        things.load()
                        let numRowsAtOnce = ProcessInfo.processInfo.processorCount/2*3
                        await raycer.render(numRowsAtOnce: numRowsAtOnce, things: things)
                        update.toggle()
                        course.toggle()
                    }
                    .aspectRatio(contentMode: .fill)
                    if course {
                        ProgressView(value: Float(raycer.rowRenderProgress), total: Float(raycer.imageHeight))
                            .accentColor(.purple.opacity(0.8))
                            .background(.purple.opacity(0.2))
                            .scaleEffect(y: 2, anchor: .bottom)
                    }
                }
                
                HStack {
                    Button("Chapter 8") {
                    }.buttonStyle(LoadButton(image: "rtow-ch8-btn"))
                    Button("Chapter 10") {
                    }.buttonStyle(LoadButton(image: "rtow-ch10-btn"))
                    Button("Chapter 13") {
                    }.buttonStyle(LoadButton(image: "rtow-ch13-btn"))
                }
                Spacer()
            }
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
