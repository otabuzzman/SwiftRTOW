class Ray {
	var ori = P(x: 0, y: 0, z: 0)
	var dir = V(x: 0, y: 0, z: 0)

	init(ori: P, dir: V) {
		self.ori = ori
		self.dir = dir
	}

	func at(t: Float) -> P {
		return ori+t*dir
	}
}
