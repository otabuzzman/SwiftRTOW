class Util {
	static let kInfinity = Float.infinity
	static let kNear0: Float = 1.0e-8
	static let kAcne0: Float = 1.0e-3
	static let kPi = Float.pi

	static func rnd() -> Float {
		Float.random(in: 0.0..<1.0)
	}

	static func rnd(min: Float, max: Float) -> Float {
		return min + rnd() * (max-min)
	}

	static func clamp(x: Float, min: Float, max: Float) -> Float {
		return min > x ? min : x > max ? max : x
	}
}
