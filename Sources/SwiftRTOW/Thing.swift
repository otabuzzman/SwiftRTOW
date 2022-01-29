struct Rayload {
	var t: Float = 0
	var p = P()
	var normal = V()
	var facing = false
	var optics: Optics?
}

protocol Thing {
	var center: P { get set }
	var optics: Optics? { get set }

	func hit(ray: Ray, tmin: Float, tmax: Float, rayload: inout Rayload) -> Bool
}
