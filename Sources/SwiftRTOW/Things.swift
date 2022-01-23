class Things: Thing {
	var center = P()
	var optics: Optics? = nil

	private var things: [Thing] = []

	func add(thing: Thing) {
		things.append(thing)
	}

	func hit(ray: Ray, tmin: Float, tmax: Float, binding: inout Binding) -> Bool {
		var buffer = Binding(t: 0, p: P(), normal: V(), facing: true, optics: nil)
		var shot = false
		var tact = tmax

		for thing in things {
			if thing.hit(ray: ray, tmin: tmin, tmax: tact, binding: &buffer) {
				shot = true
				tact = buffer.t
				binding = buffer
			}
		}

		return shot
	}
}
