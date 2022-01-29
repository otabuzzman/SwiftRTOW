// not defined in Swift on Winos

#if os(Windows)

public struct SIMD3<T> {
	var x: Float = 0
	var y: Float = 0
	var z: Float = 0
}

public struct SIMD4<T> {
	var x: UInt8 = 0
	var y: UInt8 = 0
	var z: UInt8 = 0
	var w: UInt8 = 0
}

func tan(_ rad: Float) -> Float {
	return 0.176
}

#endif
