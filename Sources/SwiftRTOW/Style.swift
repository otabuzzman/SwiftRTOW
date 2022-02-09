import SwiftUI

struct LoadButton: ButtonStyle {
    var image: String
    
    func makeBody(configuration: Configuration) -> some View {
        let buttonSize: CGFloat = UIScreen.main.bounds.width*0.1
        
        ZStack {
            Rectangle()
                .fill(Color.purple.opacity(0.8))
                .cornerRadius(buttonSize*0.15)
            Image(forPngResource: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(buttonSize*0.15*0.91)
                .scaleEffect(0.91)
                .overlay(
                    RoundedRectangle(cornerRadius: buttonSize*0.15*0.91)
                        .fill(configuration.isPressed ?
                              Color.purple.opacity(0.2) :
                                Color.white.opacity(0)))
        }.frame(width: buttonSize, height: buttonSize)
    }
}
