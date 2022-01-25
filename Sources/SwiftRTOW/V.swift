infix operator •: MultiplicationPrecedence
infix operator ×: MultiplicationPrecedence

typealias V = float3
typealias P = V
typealias C = V

extension V {
	init() {
		x = 0
		y = 0
		z = 0
	}

	// V[0], V[1], V[2]
	subscript(index: Int) -> Float {
		let i = index%3

		return i == 0 ? x : i == 1 ? y : z
	}

	func len() -> Float {
		return (self•self).squareRoot()
	}

	func unitV() -> V {
		return self/len()
	}

	func isnear0() -> Bool {
		return abs(x)<kNear0 && abs(y)<kNear0 && abs(z)<kNear0
	}

	// -V
	static prefix func -(vector: V) -> V {
		return V(x: -vector.x, y: -vector.y, z: -vector.z)
	}

	// Va + Vb
	static func +(lhs: V, rhs: V) -> V {
		return V(x: lhs.x+rhs.x, y: lhs.y+rhs.y, z: lhs.z+rhs.z)
	}

	// Va - Vb
	static func -(lhs: V, rhs: V) -> V {
		return V(x: lhs.x-rhs.x, y: lhs.y-rhs.y, z: lhs.z-rhs.z)
	}

	// Va * Vb
	static func *(lhs: V, rhs: V) -> V {
		return V(x: lhs.x*rhs.x, y: lhs.y*rhs.y, z: lhs.z*rhs.z)
	}

	// Va • Vb
	static func •(lhs: V, rhs: V) -> Float {
		return lhs.x*rhs.x+lhs.y*rhs.y+lhs.z*rhs.z
	}

	// Va × Vb
	static func ×(lhs: V, rhs: V) -> V {
		return V(x: lhs.y*rhs.z-lhs.z*rhs.y, y: lhs.z*rhs.x-lhs.x*rhs.z, z: lhs.x*rhs.y-lhs.y*rhs.x)
	}

	// x * V
	static func *(lhs: Float, rhs: V) -> V {
		return V(x: lhs*rhs.x, y: lhs*rhs.y, z: lhs*rhs.z)
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

	static func rnd() -> V {
		return V(x: Util.rnd(), y: Util.rnd(), z: Util.rnd())
	}

	static func rnd(min: Float, max: Float) -> V {
		return V(x: Util.rnd(min: min, max: max), y: Util.rnd(min: min, max: max), z: Util.rnd(min: min, max: max))
	}
}

func rndVin1sphere() -> V {
	while true {
		let v = V.rnd(min: -1, max: 1)
		if 1>v•v {
			return v
		}
	}
}

func rndVon1sphere() -> V {
	return rndVin1sphere().unitV()
}

func rndVoppraydir(n: V) -> V {
	let v = rndVin1sphere()

	return v•n>0 ? v : -v
}

func rndVin1disk() -> V {
	while true {
	let v = V(x: Util.rnd(min: -1, max: 1), y: Util.rnd(min: -1, max: 1), z: 0)
		if 1>v•v {
			return v
		}
	}
}

func reflect(v: V, n: V) -> V {
	return v-2*(v•n)*n
}

func refract(v: V, n: V, ratio: Float) -> V {
	let theta = min(-v•n, 1.0)
	let perpen = ratio*(v+theta*n)
	let parall = -(abs(1.0-perpen•perpen)).squareRoot()*n

	return perpen+parall
}
