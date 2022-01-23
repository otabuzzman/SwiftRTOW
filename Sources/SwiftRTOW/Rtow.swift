@main // https://github.com/apple/swift-package-manager/blob/main/Documentation/PackageDescription.md#target
class Rtow {
	private func sRGB(color: C) -> String {
		return ""
	}

	private func trace(ray: Ray, scene: Things, depth: Int) -> C {
		return C(x: 0, y: 0, z: 0)
	}

	private func scene() -> Things {
		let s = Things()

		return s
	}

	func render() {
		print("Hello SwiftRTOW")
	}

	// https://www.swift.org/blog/argument-parser/
	static func main() {
		let rtow = Rtow()
		rtow.render()
	}
}
