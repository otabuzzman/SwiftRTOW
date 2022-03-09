import SwiftUI

protocol FinderElement {
    var aspectRatio: CGFloat { get set }
    
    var width: CGFloat { get }
    var height: CGFloat { get }
}

extension FinderElement {
    var width: CGFloat {
        let scaleFactor = 0.31415
        
        return (UIScreen.aspectRatio>aspectRatio ?
                UIScreen.height*aspectRatio : UIScreen.width)*scaleFactor
    }
    
    var height: CGFloat {
        let scaleFactor = 0.31415
        
        return (UIScreen.aspectRatio>aspectRatio ?
                UIScreen.height : UIScreen.width)*scaleFactor/aspectRatio
    }
}

struct FinderViewer: View {
    var aspectRatio: CGFloat
    
    var body: some View {
        EmptyView()
    }
}

struct ViewerControls: FinderElement, ViewModifier {
    var aspectRatio: CGFloat
    var fieldOfView: CGFloat
    var viewerLRUD: CGSize
    var cameraLevel: CGFloat
    
    func body(content: Content) -> some View {
        let cornerRadius = min(width, height)*0.075
        
        RoundedRectangle(cornerRadius: cornerRadius)
        // shape
            .strokeBorder(.primaryRich, lineWidth: 4/fieldOfView)
            .frame(width: width, height: height)
        // view
            .scaleEffect(fieldOfView)
            .rotationEffect(.degrees(cameraLevel))
            .offset(viewerLRUD)
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

typealias RotationAxis = (x: CGFloat, y: CGFloat, z: CGFloat)
typealias CameraDirection = (rotationAngle: CGFloat, rotationAxis: RotationAxis)

struct CameraControls: FinderElement, ViewModifier {
    var aspectRatio: CGFloat
    var viewerDistance: CGFloat
    var cameraDirection: CameraDirection
    
    func body(content: Content) -> some View {
        let cornerRadius = min(width, height)*0.075
        
        RoundedRectangle(cornerRadius: cornerRadius)
        // shape
            .foregroundColor(.primaryPale)
            .frame(width: width, height: height)
        // view
            .scaleEffect(viewerDistance)
            .rotation3DEffect(.degrees(cameraDirection.0), axis: cameraDirection.1)
    }
}

extension FinderCamera {
    func applyCameraControls(viewerDistance: CGFloat, cameraDirection: CameraDirection) -> some View {
        modifier(CameraControls(aspectRatio: aspectRatio, viewerDistance: viewerDistance, cameraDirection: cameraDirection))
    }
}

struct FinderOptics: View {
    var aspectRatio: CGFloat
    
    var body: some View {
        EmptyView()
    }
}

struct OpticsControls: FinderElement, ViewModifier {
    var aspectRatio: CGFloat
    var fieldOfView: CGFloat
    var depthOfField: CGFloat
    var focusDistance: CGFloat
    var viewerLRUD: CGSize
    var cameraLevel: CGFloat
    
    func body(content: Content) -> some View {
        let cornerRadius = min(width, height)*0.075
        let scaleFactor = 1.0/1.618034*(1.0-focusDistance/180.0)
        
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
            // shape
                .fill(RadialGradient(
                    gradient: Gradient(
                        colors: [.crystal, .primaryHint, .primaryPale]),
                    center: .center,
                    startRadius: min(width, height)/2.0-depthOfField,
                    endRadius: min(width, height)-depthOfField))
            Circle()
            // shape
                .strokeBorder(.primarySoft, lineWidth: 4/(scaleFactor*fieldOfView))
                .scaleEffect(scaleFactor)
        }
        .frame(width: width, height: height)
        .scaleEffect(fieldOfView)
        .rotationEffect(.degrees(cameraLevel))
        .offset(viewerLRUD)
    }
}

extension FinderOptics {
    func applyOpticsControls(fieldOfView: CGFloat, depthOfField: CGFloat, focusDistance: CGFloat, viewerLRUD: CGSize, cameraLevel: CGFloat) -> some View {
        modifier(OpticsControls(aspectRatio: aspectRatio, fieldOfView: fieldOfView, depthOfField: depthOfField, focusDistance: focusDistance, viewerLRUD: viewerLRUD, cameraLevel: cameraLevel))
    }
}
