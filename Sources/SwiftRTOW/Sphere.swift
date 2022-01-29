class Sphere: Thing {
	var center: P
	var optics: Optics?

	private var radius: Float

	init(center: P, radius: Float, optics: Optics) {
		self.radius = radius ;
		self.center = center ;
		self.optics = optics ;
	}

	func hit(ray: Ray, tmin: Float, tmax: Float, rayload: inout Rayload) -> Bool {
		let o = ray.ori-center
		let a = ray.dir•ray.dir
		let b = ray.dir•o
		let c = o•o-radius*radius
		let discriminant = b*b-a*c

		if 0>discriminant {
			return false
		}

		let x = discriminant.squareRoot()

		var t = (-b-x)/a
		if tmin>t || t>tmax {
			t = (-b+x)/a
			if tmin>t || t>tmax {
				return false
			}
		}

		rayload.t = t
		rayload.p = ray.at(t: rayload.t)
		let outward = (rayload.p-center)/radius
		rayload.facing = 0>ray.dir•outward
		rayload.normal = rayload.facing ? outward : -outward
		rayload.optics = optics

		return true
	}
}
