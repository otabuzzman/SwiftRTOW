let kInfinity = Float.infinity
let kNear0: Float = 1.0e-8
let kAcne0: Float = 1.0e-3
let kPi = Float.pi

func rnd() -> Float {
	Float.random(in: 0.0..<1.0)
}

func rnd(min: Float, max: Float) -> Float {
	return min + rnd() * (max-min)
}

func clamp(x: Float, min: Float, max: Float) -> Float {
	return min > x ? min : x > max ? max : x
}
