import SwiftUI

protocol FinderView {
    var aspectRatio: CGFloat { get set }
    
    var width: CGFloat { get }
    var height: CGFloat { get }
}

extension FinderView {
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

struct FinderViewer: FinderView, View {
    var aspectRatio: CGFloat
    var fieldOfView: CGFloat
    
    var body: some View {
        let cornerRadius = min(width, height)*0.075
        
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(.primaryRich, lineWidth: 4/fieldOfView)
                .frame(width: width, height: height)
    }
}

struct FinderCamera: FinderView, View {
    var aspectRatio: CGFloat
    
    var body: some View {
        let cornerRadius = min(width, height)*0.075
        
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(.primaryPale)
            .frame(width: width, height: height)
    }
}

struct FinderOptics: FinderView, View {
    var aspectRatio: CGFloat
    var depthOfField: CGFloat
    var focusDistance: CGFloat
    var fieldOfView: CGFloat
    
    var body: some View {
        let cornerRadius = min(width, height)*0.075
        let scaleFactor = 1.0/1.618034*(1.0+(-focusDistance/180.0))
        
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(RadialGradient(
                    gradient: Gradient(
                        colors: [.crystal, .primaryHint, .primaryPale]),
                    center: .center,
                    startRadius: min(width, height)/2.0-depthOfField,
                    endRadius: min(width, height)-depthOfField))
            Circle()
                .strokeBorder(.primarySoft, lineWidth: 4/(scaleFactor*fieldOfView))
                .scaleEffect(scaleFactor)
        }
        .frame(width: width, height: height)
        .scaleEffect(fieldOfView)
    }
}
