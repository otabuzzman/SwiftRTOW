import Photos
import SwiftUI

extension UIScreen {
    var width: CGFloat { get { UIScreen.main.bounds.size.width } }
    var height: CGFloat { get { UIScreen.main.bounds.size.height } }
    var minDim: CGFloat { get { min(width, height) } }
    var maxDim: CGFloat { get { max(width, height) } }
}

extension UIImage {
    convenience init?(imageData: [Pixel], imageWidth: Int, imageHeight: Int) {
        guard
            imageWidth>0 && imageHeight>0,
            imageData.count == imageWidth*imageHeight
        else {
            return nil
        }
        
        guard
            let dataProvider = (imageData.withUnsafeBytes {
                (dataPointee: UnsafeRawBufferPointer) -> CGDataProvider? in
                
                return CGDataProvider(
                    data: Data(
                        bytes: dataPointee.baseAddress!,
                        count: imageData.count*MemoryLayout<Pixel>.size) as CFData)
            })
        else {
            return nil
        }
        
        guard
            let image = CGImage( 
                width: imageWidth,
                height: imageHeight,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: imageWidth*MemoryLayout<Pixel>.size,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                provider: dataProvider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent)
        else {
            return nil
        }
        
        self.init(cgImage: image)
    }
    
    func persist(inPhotosAlbum: String?) {
        let albumTitle: String
        if inPhotosAlbum == nil {
            albumTitle = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
        } else {
            albumTitle = inPhotosAlbum!
        }
        
        let albumFetchOptions = PHFetchOptions()
        albumFetchOptions.predicate = NSPredicate(format: "title == \"\(albumTitle)\"")
        var albumFetchResults = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: albumFetchOptions)
        
        if albumFetchResults.count == 0 {
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle)
            }
            // update fetch result
            albumFetchResults = PHAssetCollection.fetchAssetCollections(
                with: .album,
                subtype: .albumRegular,
                options: albumFetchOptions)
        }
        
        let album = albumFetchResults.firstObject!
        try? PHPhotoLibrary.shared().performChangesAndWait {
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: self)
            let addAssetRequest = PHAssetCollectionChangeRequest(for: album)
            addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
        }
    }
}

extension Image {
    init(forResourcePng name: String) {
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
