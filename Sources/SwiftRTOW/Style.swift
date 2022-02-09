import SwiftUI

struct LoadButton: ButtonStyle {
    var image: String
    
    func makeBody(configuration: Configuration) -> some View {
        Image(forPngResource: image)
        .resizable()
        .aspectRatio(contentMode: .fit)
    }
}
