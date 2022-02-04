class Ch13: @unchecked Sendable, Things {
    var things: [Thing]! = []
    
    func load() {
        things.append(Sphere(center: P(x: 0, y: -1000.0, z: 0), radius: 1000.0, optics: Diffuse(albedo: C(x: 0.5, y: 0.5, z: 0.5))))
        
        for a in -11..<11 {
            for b in -11..<11 {
                let select = Util.rnd()
                let center = P(x: Float(a)+0.9*Util.rnd(), y: 0.2, z: Float(b)+0.9*Util.rnd())
                if (center-P(x: 4.0, y: 0.2, z: 0)).len()>0.9 {
                    if select<0.8 {
                        let albedo = C.rnd()*C.rnd()
                        things.append(Sphere(center: center, radius: 0.2, optics: Diffuse(albedo: albedo)))
                    } else if select<0.95 {
                        let albedo = C.rnd(min: 0.5, max: 1.0)
                        let fuzz = Util.rnd(min: 0, max: 0.5)
                        things.append(Sphere(center: center, radius: 0.2, optics: Reflect(albedo: albedo, fuzz: fuzz)))
                    } else {
                        things.append(Sphere(center: center, radius: 0.2, optics: Refract(index: 1.5)))
                    }
                }
            }
        }
        
        things.append(Sphere(center: P(x: 0, y: 1.0, z: 0), radius: 1.0, optics: Refract(index: 1.5)))
        things.append(Sphere(center: P(x: -4.0, y: 1.0, z: 0), radius: 1.0, optics: Diffuse(albedo: C(x: 0.4, y: 0.2, z: 0.1))))
        things.append(Sphere(center: P(x: 4.0, y: 1.0, z: 0), radius: 1.0, optics: Reflect(albedo: C(x: 0.7, y: 0.6, z: 0.5), fuzz: 0)))
    }
}
