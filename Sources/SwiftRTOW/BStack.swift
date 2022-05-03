import SwiftUI

struct BStack<Content>: View where Content: View {
    let upright: Bool
    let content: () -> Content
    
    init(upright: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.upright = upright
        self.content = content
    }
    
    var body: some View {
        Group {
            if upright {
                VStack(content: content)
            } else {
                HStack(content: content)
            }
        }
    }
}
