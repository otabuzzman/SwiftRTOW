class Camera {
	private var eye = P(x: 0, y: 0, z: 0)
	private var aperture: Float = 0

	var u = V(x: 0, y: 0, z: 0)
	var v = V(x: 0, y: 0, z: 0)
	var w = V(x: 0, y: 0, z: 0)
	var hvec = V(x: 0, y: 0, z: 0)
	var wvec = V(x: 0, y: 0, z: 0)
	var dvec = V(x: 0, y: 0, z: 0)

	func set(eye: P, pat: P, vup: V, fov: Float, aspratio: Float, aperture: Float, fostance: Float) {
		self.eye = eye
		self.aperture = aperture

		w = unitV(v: eye-pat )
		u = unitV(v: cross(a: vup, b: w))
		v = cross(a: w, b: u)

		let h = 2.0*tan(0.5*fov*kPi/180.0)
		let W = h*aspratio
		hvec = fostance*h/2.0*v
		wvec = fostance*W/2.0*u
		dvec = fostance*w
	}

	func ray(s: Float, t: Float) -> Ray {
		let r = aperture/2.0*rndVin1disk()
		let o = r.x*u+r.y*v

		return Ray(ori: eye+o, dir: s*wvec+t*hvec-dvec-o )
	}
}
