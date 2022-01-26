#if !os(Windows)

import SwiftUI

extension UIImage {
	convenience init?(imageData: [Rtow.RGBA8], imageWidth: Int, imageHeight: Int) {
		guard imageWidth>0 && imageHeight>0, imageData.count == imageWidth*imageHeight else {
			return nil
		}

		var imageData_ = imageData
		let dataPointee = UnsafeRawPointer(&imageData_)
		guard let dataProvider = CGDataProvider(data: Data(bytes: dataPointee, count: imageData.count*MemoryLayout<Rtow.RGBA8>.size) as CFData) else {
			return nil
		}

		guard let image = CGImage( width: imageWidth, height: imageHeight, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: imageWidth*MemoryLayout<Rtow.RGBA8>.size, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), provider: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
			return nil
		}

		self.init(cgImage: image)
	}
}

#endif

@main // https://github.com/apple/swift-package-manager/blob/main/Documentation/PackageDescription.md#target
extension Rtow {
	// https://www.swift.org/blog/argument-parser/
	static func main() {
		let w = 320
		let h = 240

		let rtow = Rtow()
		rtow.imageWidth = w
		rtow.imageHeight = h
		rtow.samplesPerPixel = 1
		rtow.traceDepth = 1
		rtow.camera.set(aspratio: Float(w)/Float(h))

		rtow.render()

		#if os(Windows)
		print("P3")
		print("\(w) \(h)\n255")
		var p = 0
		while p<rtow.imageData.count {
			let pixel = rtow.imageData[p]
			print("\(pixel.r) \(pixel.g) \(pixel.b)")
			p += 1
		}
		#else
		guard let image = UIImage(imageData: rtow.imageData, imageWidth: rtow.imageWidth, imageHeight: rtow.imageHeight) else {
			fatalError("UIImage failed")
		}
		#endif
	}
}

