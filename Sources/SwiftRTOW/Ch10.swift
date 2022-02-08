class Ch8: @unchecked Sendable, Things {
    var things: [Thing]! = []
    
    func load() {
        things.append(Sphere(center: P(x: 0, y: -100.5, z: -1), radius: 100, optics: Diffuse(albedo: C(x: 0.8, y: 0.8, z: 0)))
        
        things.append(Sphere(center: P(x: 0, y: 0, z: -1), radius: 0.5, optics: Diffuse(albedo: C(x: 0, y: 0, z: 0)))
    }
}
