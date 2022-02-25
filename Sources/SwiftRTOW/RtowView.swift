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
    
    @State private var pressedBaseButton = ButtonType.None
    @State private var pressedSideButton = ButtonType.Camera
    
    var body: some View {
        ZStack {
            Color.primaryPale
                .ignoresSafeArea()
                
            VStack {
                ZStack {
                    ZStack(alignment: .bottomLeading) {
                        RtowView()
                            .task {
                                raycer.imageWidth = 320
                                raycer.imageHeight = 240
                                raycer.samplesPerPixel = 1
                                raycer.camera.set(aspratio: 320.0/240.0)
                        
                                let things = Ch10()
                                things.load()
                                appFsm.push(parameter: things)
                                appFsm.push(parameter: raycer)
                                try? appFsm.transition(event: FsmEvent.LOD)
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                maxWidth: UIScreen.width,
                                maxHeight: UIScreen.height)
                            .clipped()
                    
                        ProgressView(
                            value: Float(raycer.rowRenderProgress),
                            total: Float(raycer.imageHeight))
                            .accentColor(.primaryRich)
                            .background(.primaryPale)
                            .scaleEffect(y: 2, anchor: .bottom)
                            .opacity(appFsm.isLod ? 1.0 : 0)
                    }
                    
                    if appFsm.isPos || appFsm.isDir || appFsm.isCam  {
                        ZStack(alignment: .leading) {
                            VStack {
                                Button("Set viewer position") {
                                    pressedSideButton = ButtonType.Viewer
                                }.buttonStyle(SideButton(
                                    pretendButton: ButtonType.Viewer,
                                    pressedButton: pressedSideButton,
                                    image: "location.fill.viewfinder"))
                                
                                Button("Set camera direction") {
                                    pressedSideButton = ButtonType.Camera
                                }.buttonStyle(SideButton(
                                    pretendButton: ButtonType.Camera,
                                    pressedButton: pressedSideButton,
                                    image: "camera.viewfinder"))
                        
                                Button("Adjust camera optics") {
                                    pressedSideButton = ButtonType.Optics
                                }.buttonStyle(SideButton(
                                    pretendButton: ButtonType.Optics,
                                    pressedButton: pressedSideButton,
                                    image: "camera.aperture"))
                            }.padding(.leading)
                            
                            Group {
                                FinderView(type: .current)
                                FinderView(type: .preview).offset(appFsm.movAmount)
                            }.frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .zIndex(1) // SO #57730074
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.63)))
                    }
                }
                .simultaneousGesture(TapGesture().onEnded({
                    do {
                        appFsm.push(parameter: pressedSideButton)
                        try appFsm.transition(event: FsmEvent.CTL)
                    } catch {
                        appFsm.pop()
                    }
                }))
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            appFsm.push(parameter: value.translation)
                            try? appFsm.transition(event: FsmEvent.MOV)
                        }
                        .onEnded { _ in
                        })
                
                HStack {
                    Button("Chapter 8") {
                        let things = Ch8()
                        things.load()
                        appFsm.push(parameter: things)
                        appFsm.push(parameter: raycer)
                        try? appFsm.transition(event: FsmEvent.LOD)
                        pressedBaseButton = ButtonType.Ch8
                    }.buttonStyle(BaseButton(
                        pretendButton: ButtonType.Ch8,
                        pressedButton: pressedBaseButton,
                        image: "rtow-ch8-btn"))
                    
                    Button("Chapter 10") {
                        let things = Ch10()
                        things.load()
                        appFsm.push(parameter:things)
                        appFsm.push(parameter: raycer)
                        try? appFsm.transition(event: FsmEvent.LOD)
                        pressedBaseButton = ButtonType.Ch10
                    }.buttonStyle(BaseButton(
                        pretendButton: ButtonType.Ch10, 
                        pressedButton: pressedBaseButton,
                        image: "rtow-ch10-btn"))
                    
                    Button("Chapter 13") {
                        let things = Ch13()
                        things.load()
                        appFsm.push(parameter: things)
                        appFsm.push(parameter: raycer)
                        try? appFsm.transition(event: FsmEvent.LOD)
                        pressedBaseButton = ButtonType.Ch13
                    }.buttonStyle(BaseButton(
                        pretendButton: ButtonType.Ch13,
                        pressedButton: pressedBaseButton,
                        image: "rtow-ch13-btn"))
                }.disabled(!appFsm.isVsc)
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
