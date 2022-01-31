// not defined in Swift on Winos

#if os(Windows)

public struct SIMD3<T> {
	var x: T
	var y: T
	var z: T
}

public struct SIMD4<T> {
	var x: T
	var y: T
	var z: T
	var w: T
}

func tan(_ rad: Float) -> Float {
	return 0.176
}

#endif
