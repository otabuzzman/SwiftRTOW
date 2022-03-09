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
                                var things: Things
                                if _isDebugAssertConfiguration() { // SO #24003291
                                    raycer.imageWidth = 320
                                    raycer.imageHeight = 240
                                    raycer.samplesPerPixel = 1
                                    raycer.camera.set(aspratio: 320.0/240.0)
                                    
                                    things = Ch10()
                                } else {
                                    things = Ch13()
                                }
                                things.load()
                                appFsm.push(parameter: things)
                                appFsm.push(parameter: raycer)
                                try? appFsm.transition(event: .LOD)
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
                            .opacity(appFsm.isState(.LOD) ? 1.0 : 0)
                    }
                    
                    if appFsm.isCsl || appFsm.isCad {
                        ZStack(alignment: .leading) {
                            VStack {
                                Button("Set viewer position") {
                                    pressedSideButton = ButtonType.Viewer
                                    try? appFsm.transition(event: .VWR)
                                }.buttonStyle(SideButton(
                                    pretendButton: ButtonType.Viewer,
                                    pressedButton: pressedSideButton,
                                    image: "location.fill.viewfinder"))
                                
                                Button("Set camera direction") {
                                    pressedSideButton = ButtonType.Camera
                                    try? appFsm.transition(event: .CAM)
                                }.buttonStyle(SideButton(
                                    pretendButton: ButtonType.Camera,
                                    pressedButton: pressedSideButton,
                                    image: "camera.viewfinder"))
                        
                                Button("Adjust camera optics") {
                                    pressedSideButton = ButtonType.Optics
                                    try? appFsm.transition(event: .OPT)
                                }.buttonStyle(SideButton(
                                    pretendButton: ButtonType.Optics,
                                    pressedButton: pressedSideButton,
                                    image: "camera.aperture"))
                            }.padding(.leading)
                            
                            Group {
                                FinderViewer(aspectRatio: CGFloat(raycer.camera.aspratio))
                                    .applyViewerControls(
                                        fieldOfView: appFsm.optZomAmount,
                                        viewerLRUD: appFsm.vwrMovAmount,
                                        cameraLevel: appFsm.camTrnAmount)
                                FinderCamera(aspectRatio: CGFloat(raycer.camera.aspratio))
                                    .applyCameraControls(
                                        viewerDistance: appFsm.vwrZomAmount,
                                        cameraDirection: appFsm.camMovAmount)
                                FinderOptics(aspectRatio: CGFloat(raycer.camera.aspratio))
                                    .applyOpticsControls(
                                        fieldOfView: appFsm.optZomAmount,
                                        depthOfField: appFsm.optMovAmount,
                                        focusDistance: appFsm.optTrnAmount,
                                        viewerLRUD: appFsm.vwrMovAmount,
                                        cameraLevel: appFsm.camTrnAmount)
                            }.frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .zIndex(1) // SO #57730074
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.63)))
                    }
                }
                .simultaneousGesture(TapGesture().onEnded({
                    do {
                        appFsm.push(parameter: pressedSideButton)
                        try appFsm.transition(event: .CTL)
                    } catch {
                        appFsm.pop()
                    }
                }))
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            appFsm.push(parameter: value.translation)
                            try? appFsm.transition(event: .MOV)
                        }
                        .onEnded { _ in
                            if appFsm.isCad { try? appFsm.transition(event: .RET) }
                        })
                .simultaneousGesture(
                    RotationGesture()
                        .onChanged { value in
                            appFsm.push(parameter: CGFloat(value.degrees))
                            try? appFsm.transition(event: .TRN)
                        }
                        .onEnded { _ in
                            if appFsm.isCad { try? appFsm.transition(event: .RET) }
                        })
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            appFsm.push(parameter: value)
                            try? appFsm.transition(event: .ZOM)
                        }
                        .onEnded { _ in
                            if appFsm.isCad { try? appFsm.transition(event: .RET) }
                        })
                
                HStack {
                    Button("Chapter 8") {
                        let things = Ch8()
                        things.load()
                        appFsm.push(parameter: things)
                        appFsm.push(parameter: raycer)
                        try? appFsm.transition(event: .LOD)
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
                        try? appFsm.transition(event: .LOD)
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
                        try? appFsm.transition(event: .LOD)
                        pressedBaseButton = ButtonType.Ch13
                    }.buttonStyle(BaseButton(
                        pretendButton: ButtonType.Ch13,
                        pressedButton: pressedBaseButton,
                        image: "rtow-ch13-btn"))
                }.disabled(!appFsm.isState(.VSC))
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
