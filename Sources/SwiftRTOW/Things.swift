class Things: @unchecked Sendable {
	private var things: [Thing] = []

	func add(thing: Thing) {
		things.append(thing)
	}

	func hit(ray: Ray, tmin: Float, tmax: Float, rayload: inout Rayload) -> Bool {
		var buffer = Rayload()
		var tact = tmax
		var shot = false

		for thing in things {
			if thing.hit(ray: ray, tmin: tmin, tmax: tact, rayload: &buffer) {
				rayload = buffer
				tact = buffer.t
				shot = true
			}
		}

		return shot
	}
}
