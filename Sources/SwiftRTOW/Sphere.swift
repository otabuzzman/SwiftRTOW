class Sphere: Thing {
	var center: P
	var optics: Optics?
	private var radius: Float

	init(center: P, radius: Float, optics: Optics) {
		self.radius = radius ;
		self.center = center ;
		self.optics = optics ;
	}

	func hit(ray: Ray, tmin: Float, tmax: Float, binding: inout Binding) -> Bool {
		let o = ray.ori-center
		let a = ray.dir.dot()
		let b = dot(a: ray.dir, b: o)
		let c = o.dot()-radius*radius
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

		binding.t = t
		binding.p = ray.at(t: binding.t)
		let outward = (binding.p-center)/radius
		binding.facing = 0>dot(a: ray.dir, b: outward)
		binding.normal = binding.facing ? outward : -outward
		binding.optics = optics

		return true
	}
}
