public class Rtow {
	public var imageWidth = 1200
	public var imageHeight = 800
	public var samplesPerPixel = 10
	public var traceDepth = 50
	public var camera = Camera()

	private(set) var imageData: [RGBA8] = []

	public struct RGBA8 {
		var r: UInt8 = 0
		var g: UInt8 = 0
		var b: UInt8 = 0
		var a: UInt8 = 1
	}

	public init() {}

	private static func sRGB(color: C) -> RGBA8 {
		var r = color.x
		var g = color.y
		var b = color.z

		r = r.squareRoot()
		g = g.squareRoot()
		b = b.squareRoot()

		r = Util.clamp(x: r, min: 0, max: 0.999)
		g = Util.clamp(x: g, min: 0, max: 0.999)
		b = Util.clamp(x: b, min: 0, max: 0.999)

		let r8 = UInt8(256*Util.clamp(x: r, min: 0, max: 0.999))
		let g8 = UInt8(256*Util.clamp(x: g, min: 0, max: 0.999))
		let b8 = UInt8(256*Util.clamp(x: b, min: 0, max: 0.999))

		return RGBA8(r: r8, g: g8, b: b8, a: 255)
	}

	private func trace(ray: Ray, scene: Things, traceDepth: Int) -> C {
		var binding = Binding()
		if scene.hit(ray: ray, tmin: Util.kAcne0, tmax: Util.kInfinity, binding: &binding) {
			var sprayed = Ray()
			var attened = C()
			if traceDepth>0 && binding.optics!.spray(ray: ray, binding: binding, attened: &attened, sprayed: &sprayed) {
				return attened*trace(ray: sprayed, scene: scene, traceDepth: traceDepth-1)
			}

			return C(x: 0, y: 0, z: 0)
		}

		let unit = ray.dir.unitV()
		let t = 0.5*(unit.y+1.0)

		return (1.0-t)*C(x: 1.0, y: 1.0, z: 1.0)+t*C(x: 0.5, y: 0.7, z: 1.0)
	}

	private static func scene() -> Things {
		let s = Things()

		s.add(thing: Sphere(center: P(x: 0, y: -1000.0, z: 0), radius: 1000.0, optics: Diffuse(albedo: C(x: 0.5, y: 0.5, z: 0.5))))

		for a in -11..<11 {
			for b in -11..<11 {
				let select = Util.rnd()
				let center = P(x: Float(a)+0.9*Util.rnd(), y: 0.2, z: Float(b)+0.9*Util.rnd())
				if (center-P(x: 4.0, y: 0.2, z: 0)).len()>0.9 {
					if select<0.8 {
						let albedo = C.rnd()*C.rnd()
						s.add(thing: Sphere(center: center, radius: 0.2, optics: Diffuse(albedo: albedo)))
					} else if select<0.95 {
						let albedo = C.rnd(min: 0.5, max: 1.0)
						let fuzz = Util.rnd(min: 0, max: 0.5)
						s.add(thing: Sphere(center: center, radius: 0.2, optics: Reflect(albedo: albedo, fuzz: fuzz)))
					} else {
						s.add(thing: Sphere(center: center, radius: 0.2, optics: Refract(index: 1.5)))
					}
				}
			}
		}

		s.add(thing: Sphere(center: P(x: 0, y: 1.0, z: 0), radius: 1.0, optics: Refract(index: 1.5)))
		s.add(thing: Sphere(center: P(x: -4.0, y: 1.0, z: 0), radius: 1.0, optics: Diffuse(albedo: C(x: 0.4, y: 0.2, z: 0.1))))
		s.add(thing: Sphere(center: P(x: 4.0, y: 1.0, z: 0), radius: 1.0, optics: Reflect(albedo: C(x: 0.7, y: 0.6, z: 0.5), fuzz: 0)))

		return s
	}

	public func render() {
		let things = Rtow.scene()

		var y = imageHeight
		while y>0 {
			y -= 1
			var x = 0
			while x<imageWidth {
				var color = C(x: 0, y: 0, z: 0)
				var k = 0
				while k<samplesPerPixel {
					let s = 2.0*(Float(x)+Util.rnd())/(Float(imageWidth-1))-1.0
					let t = 2.0*(Float(y)+Util.rnd())/(Float(imageHeight-1))-1.0
					let ray = camera.ray(s: s, t: t)
					color += trace(ray: ray, scene: things, traceDepth: traceDepth)
					k += 1
				}
				imageData.append(Rtow.sRGB(color: color/Float(samplesPerPixel)))
				x += 1
			}
		}
	}
}

#if os(Windows)

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

		print("P3")
		print("\(w) \(h)\n255")
		var p = 0
		while p<rtow.imageData.count {
			let pixel = rtow.imageData[p]
			print("\(pixel.r) \(pixel.g) \(pixel.b)")
			p += 1
		}
	}
}

#endif
