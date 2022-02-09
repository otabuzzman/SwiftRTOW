protocol Things: Sendable {
    var things: [Thing]! { get set }
    
    func load()
}

extension Things {
    subscript(index: Int) -> Thing {
        get {
            things[index]
        }
    }
    
    func hit(ray: Ray, tmin: Float, tmax: Float, rayload: inout Rayload) -> Bool {
        var buffer = Rayload()
        var tact = tmax
        var shot = false

        for thing in things! {
            if thing.hit(ray: ray, tmin: tmin, tmax: tact, rayload: &buffer) {
                rayload = buffer
                tact = buffer.t
                shot = true
            }
        }

        return shot
    }
}
