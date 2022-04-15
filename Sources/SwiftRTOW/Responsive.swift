import SwiftUI

struct BStack<Content>: View where Content: View {
    let vertical: Bool
    let content: () -> Content
    
    init(vertical: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.vertical = vertical
        self.content = content
    }
    
    var body: some View {
        Group {
            if vertical {
                VStack(content: content)
            } else {
                HStack(content: content)
            }
        }
    }
}
