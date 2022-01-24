@main // https://github.com/apple/swift-package-manager/blob/main/Documentation/PackageDescription.md#target
class Rtow {
	private static func sRGB(color: C) -> String {
		var r = color.x
		var g = color.y
		var b = color.z

		r = r.squareRoot()
		g = g.squareRoot()
		b = b.squareRoot()

		let pp3 = "\(Int(256*clamp(x: r, min: 0, max: 0.999))) \(Int(256*clamp(x: g, min: 0, max: 0.999))) \(Int(256*clamp(x: b, min: 0, max: 0.999)))"

		return pp3
	}

	private func trace(ray: Ray, scene: Things, depth: Int) -> C {
		var binding = Binding()
		if scene.hit(ray: ray, tmin: kAcne0, tmax: kInfinity, binding: &binding) {
			var sprayed = Ray()
			var attened = C()
			if depth>0 && binding.optics!.spray(ray: ray, binding: binding, attened: &attened, sprayed: &sprayed) {
				return attened*trace(ray: sprayed, scene: scene, depth: depth-1)
			}

			return C(x: 0, y: 0, z: 0)
		}

		let unit = unitV(v: ray.dir)
		let t = 0.5*(unit.y+1.0)

		return (1.0-t)*C(x: 1.0, y: 1.0, z: 1.0)+t*C(x: 0.5, y: 0.7, z: 1.0)
	}

	private static func scene() -> Things {
		let s = Things()

		s.add(thing: Sphere(center: P(x: 0, y: -1000.0, z: 0), radius: 1000.0, optics: Diffuse(albedo: C(x: 0.5, y: 0.5, z: 0.5))))

		for a in -11..<11 {
			for b in -11..<11 {
				let select = rnd()
				let center = P(x: Float(a)+0.9*rnd(), y: 0.2, z: Float(b)+0.9*rnd())
				if (center-P(x: 4.0, y: 0.2, z: 0)).len()>0.9 {
					if select<0.8 {
						let albedo = C.rNd()*C.rNd()
						s.add(thing: Sphere(center: center, radius: 0.2, optics: Diffuse(albedo: albedo)))
					} else if select<0.95 {
						let albedo = C.rNd(min: 0.5, max: 1.0)
						let fuzz = rnd(min: 0, max: 0.5)
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

	func render() {
		let things = Rtow.scene()

		let aspratio: Float = 4.0/3.0
		// let aspratio: Float = 16.0/9.0

		let eye = P(x: 13.0, y: 2.0, z: 3.0)
		let pat = P(x: 0, y: 0, z: 0)
		let vup = V(x: 0, y: 1.0, z: 0)
		let aperture: Float = 0.1
		let fostance: Float = 10.0

		let camera = Camera()
		camera.set(eye: eye, pat: pat, vup: vup, fov: 20.0, aspratio: aspratio, aperture: aperture, fostance: fostance)

		let w = 320
		// let w = 1280
		let h = Int(Float(w)/aspratio)
		let spp = 1
		let depth = 1
		// let spp = 10
		// let depth = 50

		print("P3")
		print("\(w) \(h)\n255")

		var y = h-1
		while y>=0 {
			// print("\r\(y)")
			var x = 0
			while x<w {
				var color = C(x: 0, y: 0, z: 0)
				var k = 0
				while k<spp {
					let s = 2.0*(Float(x)+rnd())/(Float(w-1))-1.0
					let t = 2.0*(Float(y)+rnd())/(Float(h-1))-1.0
					let ray = camera.ray(s: s, t: t)
					color += trace(ray: ray, scene: things, depth: depth)
					k += 1
				}
				print("\(Rtow.sRGB(color: color/Float(spp)))")
				x += 1
			}
			y -= 1
		}
	}

	// https://www.swift.org/blog/argument-parser/
	static func main() {
		let rtow = Rtow()
		rtow.render()
	}
}
