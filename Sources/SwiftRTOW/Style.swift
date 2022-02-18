import SwiftUI

enum ButtonType {
    case None, Ch8, Ch10, Ch13
}

struct LoadButton: ButtonStyle {
    var pretendButton: ButtonType
    var pressedButton: ButtonType
    var image: String
    
    @Environment(\.isEnabled) var enabled
    @EnvironmentObject var appFsm: Fsm
    
    func makeBody(configuration: Configuration) -> some View {
        let buttonSize: CGFloat = UIScreen.main.bounds.width*0.1
        
        ZStack {
            Rectangle()
                .fill(enabled ? .purple.opacity(0.8) : .purple.opacity(0.6))
                .cornerRadius(buttonSize*0.15)
            Image(forPngResource: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(buttonSize*0.15*0.91)
                .scaleEffect(0.91)
                .overlay(
                    RoundedRectangle(cornerRadius: buttonSize*0.15*0.91)
                        .fill((appFsm.isLod && (pretendButton == pressedButton)) ?
                              .purple.opacity(0.2) :
                                .white.opacity(0)))
        }
        .frame(width: buttonSize, height: buttonSize)
        .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
