class Ch10: @unchecked Sendable, Things {
    var things: [Thing]! = []
    
    func load() {
        things.append(Sphere(center: P(x: 0, y: -100.5, z: -1), radius: 100, optics: Diffuse(albedo: C(x: 0.8, y: 0.8, z: 0)))
        
        things.append(Sphere(center: P(x: 0, y: 0, z: -1), radius: 0.5, optics: Diffuse(albedo: C(x: 0.1, y: 0.2, z: 0.5)))
        
        things.append(Sphere(center: P(x: -1, y: 0, z: -1), radius: 0.5, optics: Refract(index: 1.5)))
        things.append(Sphere(center: P(x: -1, y: 0, z: -1), radius: -0.4, optics: Refract(index: 1.5)))
        
        things.append(Sphere(center: P(x: 1, y: 0, z: -1), radius: 0.5, optics: Reflect(albedo: C(x: 0.8, y: 0.6, z: 0.2), fuzz: 0)))
    }
}
