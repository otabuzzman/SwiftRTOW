import SwiftUI

extension UIImage {
    convenience init?(imageData: [Pixel], imageWidth: Int, imageHeight: Int) {
        guard imageWidth>0 && imageHeight>0, imageData.count == imageWidth*imageHeight else {
            return nil
        }
        
        guard let dataProvider = (imageData.withUnsafeBytes { (dataPointee: UnsafeRawBufferPointer) -> CGDataProvider? in
            return CGDataProvider(data: Data(bytes: dataPointee.baseAddress!, count: imageData.count*MemoryLayout<Pixel>.size) as CFData)
        }) else {
            return nil
        }
        
        guard let image = CGImage( width: imageWidth, height: imageHeight, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: imageWidth*MemoryLayout<Pixel>.size, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
            return nil
        }
        
        self.init(cgImage: image)
    }
}

extension Image {
    init(forPngResource name: String) {
        guard
            let path = Bundle.module.path(forResource: name, ofType: "png"),
            let image = UIImage(contentsOfFile: path)
        else {
            self.init(name)
        
            return
        }
        
        self.init(uiImage: image)
    }
}

extension Color {
    static let crystal: Color = .white.opacity(0)
    
    static let primary: Color = .purple
    static let primaryRich = primary.opacity(0.8)
    static let primarySoft = primary.opacity(0.6)
    static let primaryPale = primary.opacity(0.25)
    static let primaryHint = primary.opacity(0.1)
    
    static let progressBar = primaryRich
    static let progressFly = primaryPale
    
    static let buttonEnabled = primaryRich
    static let buttonDisabled = primarySoft
    static let buttonPressed = primaryPale
    static let buttonHinted = primaryHint
}

extension ShapeStyle where Self == Color {
    static var primaryPale: Color { .primaryPale }

    static var buttonEnabled: Color { .primaryRich }
    static var buttonDisabled: Color { .primarySoft }
    static var buttonPressed: Color { .primaryPale }
    static var buttonHinted: Color { .primaryHint }
}
