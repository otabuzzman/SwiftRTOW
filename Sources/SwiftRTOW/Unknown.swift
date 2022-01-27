// not defined in Swift on Winos

#if os(Windows)

public struct SIMD3<T> {
	var x: Float = 0
	var y: Float = 0
	var z: Float = 0
}

func tan(_ rad: Float) -> Float {
	return 0.176
}

#endif
