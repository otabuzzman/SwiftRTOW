import Photos
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appFsm: Fsm
    @EnvironmentObject var raycer: Rtow
    @EnvironmentObject var camera: Camera
    
    @State private var things: Things = Ch10().load()
    
    @State private var pressedBaseButton = ButtonType.None
    @State private var pressedSideButton = ButtonType.Camera
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @State var isPortait = UIScreen.main.bounds.size.height>UIScreen.main.bounds.size.width

    var body: some View {
        let screen = UIScreen()
        let finderWidth = screen.minDim*0.63
        let finderHeight = screen.minDim*0.63
        
        ZStack {
            Color.primaryPale
                .ignoresSafeArea()
            
            BStack(vertical: isPortait) {
                ZStack { // gestures view
                    ZStack(alignment: .bottomLeading) { // render view
                        RtowView()
                            .task {
                                raycer.set(samplesPerPixel: 1)
                                appFsm.push(parameter: things)
                                appFsm.push(parameter: camera)
                                appFsm.push(parameter: raycer)
                                try? appFsm.transition(event: .LOD)
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                maxWidth: isPortait ? screen.width : screen.width-screen.maxDim*0.12,
                                maxHeight: isPortait ? screen.height-screen.maxDim*0.12 : screen.height)
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
                        let isPortraitSmall = !(isPortait && horizontalSizeClass == .compact)
                        
                        ZStack(alignment: isPortraitSmall ? .leading : .bottom) { // controls view
                            BStack(vertical: isPortraitSmall) { // side buttons
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
                            }.padding(isPortraitSmall ? .leading : .bottom)
                            
                            Group { // finder view
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
                                }.frame(width: finderWidth, height: finderHeight)
                            }
                            // force controls ZStack to span available space
                            .frame(
                                minWidth: 0, maxWidth: .infinity,
                                minHeight: 0, maxHeight: .infinity)
                        }
                        .zIndex(1) // SO #57730074
                        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.63)))
                    }
                }
                .simultaneousGesture(
                    TapGesture()
                        .onEnded({
                            do {
                                appFsm.push(parameter: things)
                                appFsm.push(parameter: camera)
                                appFsm.push(parameter: raycer)
                                appFsm.push(parameter: finderWidth)
                                appFsm.push(parameter: finderHeight)
                                appFsm.push(parameter: pressedSideButton)
                                try appFsm.transition(event: .CTL)
                            } catch {
                                appFsm.pop()
                                appFsm.pop()
                                appFsm.pop()
                                appFsm.pop()
                                appFsm.pop()
                                appFsm.pop()
                            }
                        }))
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 2)
                        .onEnded({ _ in
                            let doFsmTransition = {
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
                                    appFsm.pop()
                                }
                            }
                    
                            guard
                                PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized
                            else {
                                doFsmTransition()
                                return
                            }
                            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                                if status == .authorized {
                                    doFsmTransition()
                                }
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
                
                BStack(vertical: !isPortait) { // base buttons
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
                }
                .disabled(!appFsm.isState(.VSC))
                .padding(isPortait ? .bottom : .trailing)
            }
        }.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            if UIDevice.current.orientation.isValidInterfaceOrientation {
                isPortait = UIDevice.current.orientation.isPortrait
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
        WindowGroup {
            ContentView()
                .environmentObject(appFsm)
                .environmentObject(raycer)
                .environmentObject(camera)
        }
    }
}
