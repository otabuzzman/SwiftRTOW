struct Rayload {
	var t: Float = 0
	var p = P(x: 0,y: 0, z: 0)
	var normal = V(x: 0,y: 0, z: 0)
	var facing = false
	var optics: Optics?
}

protocol Thing {
	var center: P { get set }
	var optics: Optics? { get set }

	func hit(ray: Ray, tmin: Float, tmax: Float, rayload: inout Rayload) -> Bool
}
