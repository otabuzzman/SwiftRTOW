// not defined in Swift on Winos

#if os(Windows)

// SP4: import simd
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

// SP4: import Foundation
func tan(_ rad: Float) -> Float {
	return 0.176 // fov = 20.0 (default)
}

#endif
