class V {
	var x: Float = 0
	var y: Float = 0
	var z: Float = 0

	init(x: Float, y: Float, z: Float) {
		self.x = x
		self.y = y
		self.z = z
	}

	// V[0], V[1], V[2]
	subscript(index: Int) -> Float {
		let i = index%3

		return i == 0 ? x : i == 1 ? y : z
	}

	func len() -> Float {
		return dot().squareRoot()
	}

	func dot() -> Float {
		return x*x+y*y+z*z
	}

	func isnear0() -> Bool {
		return abs(x)<kNear0 && abs(y)<kNear0 && abs(z)<kNear0
	}

	static func rNd() -> V {
		return V(x: rnd(), y: rnd(), z: rnd())
	}

	static func rNd(min: Float, max: Float) -> V {
		return V(x: rnd(min: min, max: max), y: rnd(min: min, max: max), z: rnd(min: min, max: max))
	}
}

extension V {
	// -V
	static prefix func -(vector: V) -> V {
		return V(x: -vector.x, y: -vector.y, z: -vector.z)
	}

	// Va + Vb
	static func +(lhs: V, rhs: V) -> V {
		return V(x: lhs.x+rhs.x, y: lhs.y+rhs.y, z: lhs.x+rhs.y)
	}

	// Va - Vb
	static func -(lhs: V, rhs: V) -> V {
		return V(x: lhs.x-rhs.x, y: lhs.y-rhs.y, z: lhs.x-rhs.y)
	}

	// Va * Vb
	static func *(lhs: V, rhs: V) -> V {
		return V(x: lhs.x*rhs.x, y: lhs.y*rhs.y, z: lhs.x*rhs.y)
	}

	// x * V
	static func *(lhs: Float, rhs: V) -> V {
		return V(x: lhs*rhs.x, y: lhs*rhs.y, z: lhs*rhs.y)
	}

	// x / V
	static func /(lhs: V, rhs: Float) -> V {
		return 1.0/rhs*lhs
	}

	// Va += Vb
	static func +=(lhs: inout V, rhs: V) {
		lhs = lhs+rhs
	}

	// Va *= x
	static func *=(lhs: inout V, rhs: Float) {
		lhs = rhs*lhs
	}

	// Va /= x
	static func /=(lhs: inout V, rhs: Float) {
		lhs = lhs/rhs
	}
}

typealias P = V
typealias C = V

func dot(a: V, b: V) -> Float {
	return a.x*b.x+a.y*b.y+a.z*b.z
}

func cross(a: V, b: V) -> V {
	return V(x: a.y*b.z-a.z*b.y, y: a.z*b.x-a.x*b.z, z: a.x*b.y-a.y*b.x)
}

func unitV(v: V) -> V {
	return v/v.len()
}

func rndVin1sphere() -> V {
	while true {
		let v = V.rNd(min: -1, max: 1 )
		if (1>v.dot()) {
			return v
		}
	}
}

func rndVon1sphere() -> V {
	return unitV(v: rndVin1sphere() )
}

func rndVoppraydir(n: V) -> V {
	let v = rndVin1sphere()

	return dot(a: v, b: n)>0 ? v : -v
}

func rndVin1disk() -> V {
	while true {
	let v = V(x: rnd(min: -1, max: 1), y: rnd(min: -1, max: 1), z: 0)
		if 1>v.dot() {
			return v
		}
	}
}

func reflect(v: V, n: V) -> V {
	return v-2*dot(a: v, b: n )*n
}

func refract(v: V, n: V, ratio: Float ) -> V {
	let theta = min(dot(a: -v, b: n), 1.0)
	let perpen = ratio*(v+theta*n)
	let parall = -(abs(1.0-perpen.dot())).squareRoot()*n

	return perpen+parall
}
