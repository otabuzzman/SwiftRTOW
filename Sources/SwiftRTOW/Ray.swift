struct Ray {
	var ori = P()
	var dir = V()

	func at(t: Float) -> P {
		return ori+t*dir
	}
}
