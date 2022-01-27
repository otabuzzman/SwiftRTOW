import SwiftUI

extension UIImage {
	convenience init?(imageData: [Rtow.RGBA8], imageWidth: Int, imageHeight: Int) {
		guard imageWidth>0 && imageHeight>0, imageData.count == imageWidth*imageHeight else {
			return nil
		}

		guard let dataProvider = (imageData.withUnsafeBytes { (dataPointee: UnsafeRawBufferPointer) -> CGDataProvider? in
			return CGDataProvider(data: Data(bytes: dataPointee.baseAddress!, count: imageData.count*MemoryLayout<Rtow.RGBA8>.size)
		}) else {
			return nil
		}

		guard let image = CGImage( width: imageWidth, height: imageHeight, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: imageWidth*MemoryLayout<Rtow.RGBA8>.size, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
			return nil
		}

		self.init(cgImage: image)
	}
}
