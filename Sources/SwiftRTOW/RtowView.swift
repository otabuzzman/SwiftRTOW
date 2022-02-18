import SwiftUI

struct RtowView: UIViewRepresentable {
    @EnvironmentObject var raycer: Rtow
    
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
        if !raycer.rowRenderFinished {
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
    @EnvironmentObject var appFsm: Fsm
    
    @State private var pressedButton = ButtonType.None
    
    var body: some View {
        ZStack {
            Color.purple
                .opacity(0.2)
                .ignoresSafeArea()
                
            VStack {
                ZStack(alignment: .bottomLeading) {
                    RtowView()
                    .task {
                        raycer.imageWidth = 320
                        raycer.imageHeight = 240
                        raycer.samplesPerPixel = 1
                        raycer.camera.set(aspratio: 320.0/240.0)
                        
                        appFsm.eaParam.push(raycer)
                        
                        let things = Ch10()
                        things.load()
                        appFsm.eaParam.push(things)
                        appFsm.transition(event: FsmEvent.LOD)
                    }
                    .aspectRatio(contentMode: .fill)
                    if appFsm.isLod {
                        ProgressView(value: Float(raycer.rowRenderProgress), total: Float(raycer.imageHeight))
                            .accentColor(.purple.opacity(0.8))
                            .background(.purple.opacity(0.2))
                            .scaleEffect(y: 2, anchor: .bottom)
                    }
                }
                
                HStack {
                    Button("Chapter 8") {
                        let things = Ch8()
                        things.load()
                        appFsm.eaParam.push(things)
                        appFsm.transition(event: FsmEvent.LOD)
                        pressedButton = ButtonType.Ch8
                    }.buttonStyle(LoadButton(pretendButton: ButtonType.Ch8, pressedButton: pressedButton, image: "rtow-ch8-btn"))
                    Button("Chapter 10") {
                        let things = Ch10()
                        things.load()
                        appFsm.eaParam.push(things)
                        appFsm.transition(event: FsmEvent.LOD)
                        pressedButton = ButtonType.Ch10
                    }.buttonStyle(LoadButton(pretendButton: ButtonType.Ch10, pressedButton: pressedButton, image: "rtow-ch10-btn"))
                    Button("Chapter 13") {
                        let things = Ch13()
                        things.load()
                        appFsm.eaParam.push(things)
                        appFsm.transition(event: FsmEvent.LOD)
                        pressedButton = ButtonType.Ch13
                    }.buttonStyle(LoadButton(pretendButton: ButtonType.Ch13, pressedButton: pressedButton, image: "rtow-ch13-btn"))
                }.disabled(appFsm.isLod)
                Spacer()
            }
        }
    }
}

@main
struct MyApp: App {
    @StateObject var appFsm = Fsm()
    @StateObject var raycer = Rtow()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appFsm)
                .environmentObject(raycer)
        }
    }
}
