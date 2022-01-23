class Ray {
	var ori = P()
	var dir = V()

	init() {}
	init(ori: P, dir: V) {
		self.ori = ori
		self.dir = dir
	}

	func at(t: Float) -> P {
		return ori+t*dir
	}
}
