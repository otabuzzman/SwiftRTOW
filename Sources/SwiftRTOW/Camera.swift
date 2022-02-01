#if !os(Windows)
import Foundation
#endif

public class Camera {
	private(set) var eye: P
	private(set) var pat: P
	private(set) var vup: V
	private(set) var fov: Float
	private(set) var aspratio: Float
	private(set) var aperture: Float
	private(set) var fostance: Float

	private var u = V(x: 0, y: 0, z: 0)
	private var v = V(x: 0, y: 0, z: 0)
	private var w = V(x: 0, y: 0, z: 0)
	private var hvec = V(x: 0, y: 0, z: 0)
	private var wvec = V(x: 0, y: 0, z: 0)
	private var dvec = V(x: 0, y: 0, z: 0)

	public init() {
		// RTOW default values
		eye = P(x: 13.0, y: 2.0, z: 3.0)
		pat = P(x: 0, y: 0, z: 0)
		vup = V(x: 0, y: 1.0, z: 0)
		fov = 20.0
		aspratio = 16.0/9.0
		aperture = 0.1
		fostance = 10.0

		set()
	}

	public func set(eye: P? = nil, pat: P? = nil, vup: V? = nil, fov: Float? = nil, aspratio: Float? = nil, aperture: Float? = nil, fostance: Float? = nil) {
		if eye != nil {
			self.eye = eye!
		}
		if pat != nil {
			self.pat = pat!
		}
		if vup != nil {
			self.vup = vup!
		}
		if fov != nil {
			self.fov = fov!
		}
		if aspratio != nil {
			self.aspratio = aspratio!
		}
		if aperture != nil {
			self.aperture = aperture!
		}
		if fostance != nil {
			self.fostance = fostance!
		}

		w = (self.eye-self.pat).unitV()
		u = (self.vup×w).unitV()
		v = w×u

		let fovHeight = 2.0*tan(0.5*self.fov*Util.kPi/180.0)
		let fovWidth = fovHeight*self.aspratio
		hvec = self.fostance*fovHeight/2.0*v
		wvec = self.fostance*fovWidth/2.0*u
		dvec = self.fostance*w
	}

	public func ray(s: Float, t: Float) -> Ray {
		let r = aperture/2.0*rndVin1disk()
		let o = r.x*u+r.y*v

		return Ray(ori: eye+o, dir: s*wvec+t*hvec-dvec-o )
	}
}
