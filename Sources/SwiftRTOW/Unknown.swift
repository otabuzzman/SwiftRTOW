// not defined in Swift on Winos

#if os(Windows)

struct float3 {
	var x: Float
	var y: Float
	var z: Float
}

func tan(_ rad: Float) -> Float {
	return 0.176
}

#endif
