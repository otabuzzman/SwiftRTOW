class Ch10: @unchecked Sendable, Things {
    var things: [Thing]! = []
    
    func load() {
        things.append(Sphere(center: P(x: 0, y: -100.0, z: -1.0), radius: 100.0, optics: Diffuse(albedo: C(x: 0.8, y: 0.8, z: 0))))
        
        things.append(Sphere(center: P(x: 0, y: 1.0, z: 0), radius: 1.0, optics: Diffuse(albedo: C(x: 0.1, y: 0.2, z: 0.5))))
        
        things.append(Sphere(center: P(x: -4, y: 1.0, z: 0), radius: 1.0, optics: Refract(index: 1.5)))
        things.append(Sphere(center: P(x: -4, y: 1.0, z: 0), radius: -0.8, optics: Refract(index: 1.5)))
        
        things.append(Sphere(center: P(x: 4.0, y: 1.0, z: 0), radius: 1.0, optics: Reflect(albedo: C(x: 0.8, y: 0.6, z: 0.2), fuzz: 0)))
    }
}
