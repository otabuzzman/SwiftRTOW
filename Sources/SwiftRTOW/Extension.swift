import SwiftUI

extension UIScreen {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let aspectRatio = width/height
}

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
    static var primaryRich: Color { .primaryRich }
    static var primarySoft: Color { .primarySoft }
    static var primaryPale: Color { .primaryPale }

    static var buttonEnabled: Color { .primaryRich }
    static var buttonDisabled: Color { .primarySoft }
    static var buttonPressed: Color { .primaryPale }
    static var buttonHinted: Color { .primaryHint }
}

extension CGSize {
    static prefix func -(v: CGSize) -> CGSize {
        return CGSize(width: -v.width, height: -v.height)
    }
    
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width+rhs.width, height: lhs.height+rhs.height)
    }
    
    func clamped(to limitsWidth: ClosedRange<CGFloat>, and limitsHeight: ClosedRange<CGFloat>) -> CGSize {
        return CGSize(width: width.clamped(to: limitsWidth), height: height.clamped(to: limitsHeight))
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// .rotation3DEffect modifier axis touple operators
func +<T: Numeric>(lhs: (x: T, y: T, z: T), rhs: (x: T, y: T, z: T)) -> (x: T, y: T, z: T) {
    return (x: lhs.0+rhs.0, y: lhs.1+rhs.1, z: lhs.2+rhs.2)
}

func +=<T: Numeric>(lhs: inout (x: T, y: T, z: T), rhs: (x: T, y: T, z: T)) {
    lhs = lhs+rhs
}
