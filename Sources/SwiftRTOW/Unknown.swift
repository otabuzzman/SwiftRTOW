// not defined in Swift on Winos

#if os(Windows)

// SP4: import simd
struct SIMD3<T> {
	var x: T
	var y: T
	var z: T
}

struct SIMD4<T> {
	var x: T
	var y: T
	var z: T
	var w: T
}

// SP4: import Foundation
private let f16 = [
	1,
	1,
	2,
	6,
	24,
	120,
	720,
	5040,
	40320,
	362880,
	3628800,
	39916800,
	479001600,
	6227020800,
	87178291200,
	1307674368000
]

func pow(_ x: Float, _ e: Int) -> Float {
	var r: Float = 1.0
	if e>0 {
		for _ in 1...e {
			r *= x
		}
	}
	return r
}

func sin(_ rad: Float) -> Float {
	let twoPi = 2*Float.pi
	var x = rad
	while 0>x {
		x += twoPi
	}
	while x>twoPi {
		x -= twoPi
	}
	var s: Float = 1.0
	if x>Float.pi {
		x -= Float.pi
		s = -1.0
	}
	var r: Float = 0
	for n in 0..<f16.count/2 {
		r += pow(-1.0, n)*pow(x, 2*n+1)/Float(f16[2*n+1])
	}
	return s*r
}

func cos(_ rad: Float) -> Float {
	return (1.0-pow(sin(rad), 2)).squareRoot()
}

func tan(_ rad: Float) -> Float {
	var a = rad
	while 0>a {
		a += 2*Float.pi
	}
	let q = (Int(2.0*a/Float.pi)+1)%4
	let b = sin(a)/cos(a)
	return q == 2 || q == 4 ? -b : b
}

#endif
