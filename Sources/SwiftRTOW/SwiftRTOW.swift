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
    @EnvironmentObject var appFsm: Fsm
    @EnvironmentObject var raycer: Rtow
    @EnvironmentObject var camera: Camera
    
    @State private var things: Things = Ch10().load()
    
    @State private var pressedBaseButton = ButtonType.None
    @State private var pressedSideButton = ButtonType.Camera
    
    private let finderSize = CGSize(
        width: min(UIScreen.width, UIScreen.width)*0.63,
        height: min(UIScreen.width, UIScreen.width)*0.63)
    
    var body: some View {
        ZStack {
            Color.primaryPale
                .ignoresSafeArea()
                
            VStack {
                ZStack {
                    ZStack(alignment: .bottomLeading) {
                        RtowView()
                            .task {
                                appFsm.push(parameter: things)
                                appFsm.push(parameter: camera)
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
                                    pressedSideButton = .Viewer
                                    try? appFsm.transition(event: .VWR)
                                }.buttonStyle(SideButton(
                                    pretendButton: .Viewer,
                                    pressedButton: pressedSideButton,
                                    image: "location.fill.viewfinder"))
                                
                                Button("Set camera direction") {
                                    pressedSideButton = .Camera
                                    try? appFsm.transition(event: .CAM)
                                }.buttonStyle(SideButton(
                                    pretendButton: .Camera,
                                    pressedButton: pressedSideButton,
                                    image: "camera.viewfinder"))
                        
                                Button("Adjust camera optics") {
                                    pressedSideButton = .Optics
                                    try? appFsm.transition(event: .OPT)
                                }.buttonStyle(SideButton(
                                    pretendButton: .Optics,
                                    pressedButton: pressedSideButton,
                                    image: "camera.aperture"))
                            }.padding(.leading)
                            
                            Group {
                                Group {
                                    FinderBorder()
                                    
                                    FinderViewer(aspectRatio: CGFloat(camera.aspratio))
                                        .applyViewerControls(
                                            fieldOfView: appFsm.optZomAmount,
                                            viewerLRUD: appFsm.vwrMovAmount,
                                            cameraLevel: appFsm.camTrnAmount)
                                
                                    FinderCamera(aspectRatio: CGFloat(camera.aspratio))
                                        .applyCameraControls(
                                            viewerDistance: appFsm.vwrZomAmount,
                                            cameraDirection: appFsm.camMovRotate)
                                
                                    FinderOptics(aspectRatio: CGFloat(camera.aspratio))
                                        .applyOpticsControls(
                                            fieldOfView: appFsm.optZomAmount,
                                            depthOfField: appFsm.optMovAmount,
                                            focusDistance: appFsm.optTrnAmount,
                                            viewerLRUD: appFsm.vwrMovAmount,
                                            cameraLevel: appFsm.camTrnAmount)
                                }.frame(width: finderSize.width, height: finderSize.height)
                            }
                            // force controls ZStack to span screen width
                            .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .zIndex(1) // SO #57730074
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.63)))
                    }
                }
                .simultaneousGesture(TapGesture().onEnded({
                    do {
                        appFsm.push(parameter: things)
                        appFsm.push(parameter: camera)
                        appFsm.push(parameter: raycer)
                        appFsm.push(parameter: finderSize)
                        appFsm.push(parameter: pressedSideButton)
                        try appFsm.transition(event: .CTL)
                    } catch {
                        appFsm.pop()
                        appFsm.pop()
                        appFsm.pop()
                        appFsm.pop()
                        appFsm.pop()
                    }
                }))
                .simultaneousGesture(LongPressGesture(minimumDuration: 2).onEnded({ _ in
                    do {
                        appFsm.push(parameter: raycer.imageWidth)
                        appFsm.push(parameter: raycer.imageHeight)
                        try raycer.imageData!.withUnsafeBufferPointer { data in
                            appFsm.push(parameter: data)
                            try appFsm.transition(event: .SAV)
                        }
                    } catch {
                        appFsm.pop()
                        appFsm.pop()
                    }
                }))
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            do {
                                appFsm.push(parameter: value.translation)
                                try appFsm.transition(event: .MOV)
                            } catch {
                                appFsm.pop()
                            }
                        }
                        .onEnded { _ in
                            if appFsm.isCad { try! appFsm.transition(event: .RET) }
                        })
                .simultaneousGesture(
                    RotationGesture()
                        .onChanged { value in
                            do {
                                appFsm.push(parameter: CGFloat(value.degrees))
                                try appFsm.transition(event: .TRN)
                            } catch {
                                appFsm.pop()
                            }
                        }
                        .onEnded { _ in
                            if appFsm.isCad { try! appFsm.transition(event: .RET) }
                        })
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            do {
                                appFsm.push(parameter: value)
                                try appFsm.transition(event: .ZOM)
                            } catch FsmError.unexpectedFsmEvent {
                                appFsm.pop()
                            } catch {
                                fatalError(error.localizedDescription)
                            }
                        }
                        .onEnded { _ in
                            if appFsm.isCad { try! appFsm.transition(event: .RET) }
                        })
                
                HStack {
                    Button("Chapter 8") {
                        things = Ch8()
                        things.load()
                        appFsm.push(parameter: things)
                        appFsm.push(parameter: camera)
                        appFsm.push(parameter: raycer)
                        try? appFsm.transition(event: .LOD)
                        pressedBaseButton = .Ch8
                    }.buttonStyle(BaseButton(
                        pretendButton: .Ch8,
                        pressedButton: pressedBaseButton,
                        image: "rtow-ch8-btn"))
                    
                    Button("Chapter 10") {
                        things = Ch10()
                        things.load()
                        appFsm.push(parameter: things)
                        appFsm.push(parameter: camera)
                        appFsm.push(parameter: raycer)
                        try? appFsm.transition(event: .LOD)
                        pressedBaseButton = .Ch10
                    }.buttonStyle(BaseButton(
                        pretendButton: .Ch10,
                        pressedButton: pressedBaseButton,
                        image: "rtow-ch10-btn"))
                    
                    Button("Chapter 13") {
                        things = Ch13()
                        things.load()
                        appFsm.push(parameter: things)
                        appFsm.push(parameter: camera)
                        appFsm.push(parameter: raycer)
                        try? appFsm.transition(event: .LOD)
                        pressedBaseButton = .Ch13
                    }.buttonStyle(BaseButton(
                        pretendButton: .Ch13,
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
    @StateObject var camera = Camera()
    
    var body: some Scene {
        if _isDebugAssertConfiguration() { // SO #24003291
            raycer.imageWidth = 320
            raycer.imageHeight = 240
            raycer.samplesPerPixel = 1
            
            camera.set(aspratio: 320.0/240.0)
        }
        
        return WindowGroup {
            ContentView()
                .environmentObject(appFsm)
                .environmentObject(raycer)
                .environmentObject(camera)
        }
    }
}
