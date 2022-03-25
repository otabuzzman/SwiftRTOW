import SwiftUI

struct FinderBorder: View {
    var body: some View {
        GeometryReader { geometry in
            let borderWidth = geometry.size.width
            let borderHeight = geometry.size.height
            
            let cornerRadius = min(borderWidth, borderHeight)*0.031415
            
            RoundedRectangle(cornerRadius: cornerRadius)
            // shape
                .strokeBorder(.primaryRich, lineWidth: 2)
        }
    }
}

struct FinderViewer: View {
    var aspectRatio: CGFloat
    
    var body: some View {
        EmptyView()
    }
}

struct ViewerControls: ViewModifier {
    var aspectRatio: CGFloat
    var fieldOfView: CGFloat
    var viewerLRUD: CGSize
    var cameraLevel: CGFloat
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let borderWidth = geometry.size.width
            let borderHeight = geometry.size.height
            let borderRatio = borderWidth/borderHeight
            
            let cornerRadius = min(borderWidth, borderHeight)*0.031415
            let width = (borderRatio>aspectRatio ? borderHeight*aspectRatio : borderWidth)*0.5
            let height = (borderRatio>aspectRatio ? borderHeight : borderWidth)*0.5/aspectRatio
            
            VStack { // https://swiftui-lab.com/geometryreader-bug/ (FB7971927)
                RoundedRectangle(cornerRadius: cornerRadius)
                // shape
                    .strokeBorder(.primaryRich, lineWidth: 4/fieldOfView)
                // view
                    .frame(width: width, height: height)
                    .scaleEffect(fieldOfView)
                    .rotationEffect(.degrees(cameraLevel))
                    .offset(viewerLRUD)
            }.frame(width: borderWidth, height: borderHeight, alignment: .center)
        }
    }
}

extension FinderViewer {
    func applyViewerControls(fieldOfView: CGFloat, viewerLRUD: CGSize, cameraLevel: CGFloat) -> some View {
        modifier(ViewerControls(aspectRatio: aspectRatio, fieldOfView: fieldOfView, viewerLRUD: viewerLRUD, cameraLevel: cameraLevel))
    }
}

struct FinderCamera: View {
    var aspectRatio: CGFloat
    
    var body: some View {
        EmptyView()
    }
}

struct CameraControls: ViewModifier {
    var aspectRatio: CGFloat
    var viewerDistance: CGFloat
    var cameraDirection: CamMovRotate
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let borderWidth = geometry.size.width
            let borderHeight = geometry.size.height
            let borderRatio = borderWidth/borderHeight
            
            let cornerRadius = min(borderWidth, borderHeight)*0.031415
            let width = (borderRatio>aspectRatio ? borderHeight*aspectRatio : borderWidth)*0.5
            let height = (borderRatio>aspectRatio ? borderHeight : borderWidth)*0.5/aspectRatio
            
            VStack { // https://swiftui-lab.com/geometryreader-bug/ (FB7971927)
                RoundedRectangle(cornerRadius: cornerRadius)
                // shape
                    .foregroundColor(.primaryPale)
                // view
                    .frame(width: width, height: height)
                    .scaleEffect(viewerDistance)
                    .rotation3DEffect(.degrees(cameraDirection.0), axis: cameraDirection.1)
            }.frame(width: borderWidth, height: borderHeight, alignment: .center)
        }
    }
}

extension FinderCamera {
    func applyCameraControls(viewerDistance: CGFloat, cameraDirection: CamMovRotate) -> some View {
        modifier(CameraControls(aspectRatio: aspectRatio, viewerDistance: viewerDistance, cameraDirection: cameraDirection))
    }
}

struct FinderOptics: View {
    var aspectRatio: CGFloat
    
    var body: some View {
        EmptyView()
    }
}

struct OpticsControls: ViewModifier {
    var aspectRatio: CGFloat
    var fieldOfView: CGFloat
    var depthOfField: CGFloat
    var focusDistance: CGFloat
    var viewerLRUD: CGSize
    var cameraLevel: CGFloat
    
    func body(content: Content) -> some View {
        let scaleFactor = 1.0/1.618034*(1.0-focusDistance/180.0)
        
        GeometryReader { geometry in
            let borderWidth = geometry.size.width
            let borderHeight = geometry.size.height
            let borderRatio = borderWidth/borderHeight
            
            let cornerRadius = min(borderWidth, borderHeight)*0.031415
            let width = (borderRatio>aspectRatio ? borderHeight*aspectRatio : borderWidth)*0.5
            let height = (borderRatio>aspectRatio ? borderHeight : borderWidth)*0.5/aspectRatio
            
            VStack { // https://swiftui-lab.com/geometryreader-bug/ (FB7971927)
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                    // shape
                        .fill(RadialGradient(
                            gradient: Gradient(
                                colors: [.crystal, .primaryHint, .primaryPale]),
                            center: .center,
                            startRadius: min(width, height)/4.0+depthOfField*0.31415,
                            endRadius: min(width, height)/2.0+depthOfField*0.31415))
                    Circle()
                    // shape
                        .strokeBorder(.primarySoft, lineWidth: 2/(scaleFactor*fieldOfView))
                        .scaleEffect(scaleFactor)
                    
                }
                .frame(width: width, height: height)
                .scaleEffect(fieldOfView)
                .rotationEffect(.degrees(cameraLevel))
                .offset(viewerLRUD)
            }.frame(width: borderWidth, height: borderHeight, alignment: .center)
        }
    }
}

extension FinderOptics {
    func applyOpticsControls(fieldOfView: CGFloat, depthOfField: CGFloat, focusDistance: CGFloat, viewerLRUD: CGSize, cameraLevel: CGFloat) -> some View {
        modifier(OpticsControls(aspectRatio: aspectRatio, fieldOfView: fieldOfView, depthOfField: depthOfField, focusDistance: focusDistance, viewerLRUD: viewerLRUD, cameraLevel: cameraLevel))
    }
}
