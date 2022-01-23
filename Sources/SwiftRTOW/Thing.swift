struct Binding {
	var t: Float
	var p: P
	var normal: V
	var facing: Bool
	var optics: Optics?
}

protocol Thing {
	var center: P { get set }
	var optics: Optics? { get set }

	func hit(ray: Ray, tmin: Float, tmax: Float, binding: inout Binding) -> Bool
}
