class Ch8: @unchecked Sendable, Things {
    var things: [Thing]! = []
    
    func load() {
        things.append(Sphere(center: P(x: 0, y: -100.0, z: -1.0), radius: 100.0, optics: Diffuse(albedo: C(x: 0.5, y: 0.5, z: 0.5))))
        
        things.append(Sphere(center: P(x: 0, y: 1.0, z: 0), radius: 1.0, optics: Diffuse(albedo: C(x: 0.5, y: 0.5, z: 0.5))))
    }
}
