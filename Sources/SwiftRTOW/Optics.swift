protocol Optics {
	func spray(ray: Ray, binding: Binding, attened: C, sprayed: Ray) -> Bool
}
