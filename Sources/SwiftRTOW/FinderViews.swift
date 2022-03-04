import SwiftUI

enum FinderType {
    case viewer
    case camera
}

struct FinderView: View {
    @EnvironmentObject var raycer: Rtow
    var scaleFactor = 0.31415
    var type: FinderType!
    
    init(type: FinderType) {
        self.type = type
    }
    
    func width() -> CGFloat {
        let aspectRatio = CGFloat(raycer.camera.aspratio)
        
        return UIScreen.aspectRatio>aspectRatio ?
        UIScreen.height*scaleFactor*aspectRatio :
        UIScreen.width*scaleFactor
    }
    
    func height() -> CGFloat {
        let aspectRatio = CGFloat(raycer.camera.aspratio)
        
        return UIScreen.aspectRatio>aspectRatio ?
        UIScreen.height*scaleFactor :
        UIScreen.width*scaleFactor/aspectRatio
    }
    
    var body: some View {
        let cornerRadius = min(
            CGFloat(raycer.imageWidth),
            CGFloat(raycer.imageHeight))*0.042
        
        switch type! {
        case .viewer:
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(.primaryRich, lineWidth: 4)
                .frame(width: width(), height: height())
        case .camera:
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(.primaryPale)
                .frame(width: width(), height: height())
        }
    }
}
