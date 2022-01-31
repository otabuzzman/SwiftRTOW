class Things: Thing {
	var center = P(x: 0,y: 0, z: 0)
	var optics: Optics?

	private var things: [Thing] = []

	func add(thing: Thing) {
		things.append(thing)
	}

	func hit(ray: Ray, tmin: Float, tmax: Float, rayload: inout Rayload) -> Bool {
		var buffer = Rayload()
		var shot = false
		var tact = tmax

		for thing in things {
			if thing.hit(ray: ray, tmin: tmin, tmax: tact, rayload: &buffer) {
				shot = true
				tact = buffer.t
				rayload = buffer
			}
		}

		return shot
	}
}
