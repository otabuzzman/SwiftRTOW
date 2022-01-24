struct Binding {
	var t: Float = 0
	var p = P()
	var normal = V()
	var facing = false
	var optics: Optics? = nil
}

protocol Thing {
	var center: P { get set }
	var optics: Optics? { get set }

	func hit(ray: Ray, tmin: Float, tmax: Float, binding: inout Binding) -> Bool
}
