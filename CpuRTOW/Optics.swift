protocol Optics {
	func spray(ray: Ray, rayload: Rayload, attened: inout C, sprayed: inout Ray) -> Bool
}

class Diffuse: Optics {
	private var albedo: C

	init(albedo: C) {
		self.albedo = albedo
	}

	func spray(ray: Ray, rayload: Rayload, attened: inout C, sprayed: inout Ray) -> Bool {
		var dir = rayload.normal+rndVon1sphere()
		if dir.isnear0() {
			dir = rayload.normal
		}

		sprayed = Ray(ori: rayload.p, dir: dir) ;
		attened = albedo ;

		return true ;
	}
}

class Reflect: Optics {
	private var albedo: C
	private var fuzz: Float

	init(albedo: C, fuzz: Float) {
		self.albedo = albedo
		self.fuzz = fuzz
	}
	func spray(ray: Ray, rayload: Rayload, attened: inout C, sprayed: inout Ray) -> Bool {
		let r = reflect(v: ray.dir.unitV(), n: rayload.normal)

		sprayed = Ray(ori: rayload.p, dir: r+fuzz*rndVin1sphere())
		attened = albedo ;

		return sprayed.dir•rayload.normal>0
	}
}

class Refract: Optics {
	private var index: Float

	init(index: Float) {
		self.index = index
	}

	func spray(ray: Ray, rayload: Rayload, attened: inout C, sprayed: inout Ray) -> Bool {
		let d1V = ray.dir.unitV()
		let cos_theta = min(-d1V•rayload.normal, 1.0)
		let sin_theta = (1.0-cos_theta*cos_theta).squareRoot()

		let ratio = rayload.facing ? 1.0/index : index
		let cannot = ratio*sin_theta>1.0

		var dir: V
		if cannot || Refract.schlick(theta: cos_theta, ratio: ratio)>Util.rnd() {
			dir = reflect(v: d1V, n: rayload.normal)
		} else {
			dir = refract(v: d1V, n: rayload.normal, ratio: ratio)
		}

		sprayed = Ray(ori: rayload.p, dir: dir)
		attened = C(x: 1.0, y: 1.0, z: 1.1)

		return true
	}

	private static func schlick(theta: Float, ratio: Float) -> Float {
		var r0 = (1.0-ratio)/(1.0+ratio)
		r0 = r0*r0

		return r0+(1.0-r0)*(1.0-theta)*(1.0-theta)*(1.0-theta)*(1.0-theta)*(1.0-theta)
	}
}
