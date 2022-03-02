import SwiftUI

enum FinderType {
    case current
    case preview
}

struct FinderView: View {
    @EnvironmentObject var raycer: Rtow
    @EnvironmentObject var appFsm: Fsm
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
        
        if type == .current {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(.primaryPale)
                .frame(width: width(), height: height())
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(.primaryRich, lineWidth: 4/appFsm.zomAmount)
                .frame(width: width(), height: height())
        }
    }
}
