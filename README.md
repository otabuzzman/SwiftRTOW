# SwiftRTOW
A SwiftUI version of Peter Shirley's ray tracer from his mini-book [Ray Tracing in One Weekend](https://github.com/RayTracing/raytracing.github.io/) (RTOW).

### Tools
Apps used on iPad
- [Swift Playgrounds 4](https://apps.apple.com/de/app/swift-playgrounds/id908519492) (SP4)
- [Working Copy](https://workingcopyapp.com/)
- [Textastic](https://www.textasticapp.com/) (can handle files in *Swift Playgrounds* and *Working Copy* folders)
- [GitHub](https://apps.apple.com/us/app/github/id1477376905)

### Usage
- Ceate new app[^1] in SP4
- Delete predefined `*.swift` files in app
- Copy&paste Swift files from repository to app

  - Get repository on iPad (Working Copy)
  - Copy files from WC to SP4 folder (Textastic)

- Add PNG files with SP4 as resources to app

[^1]: Running the code in a Playground crashes.

### Which file for what
|File|Comment|
|:---|:------|
|`CpuRTOW`<br>(folder)|A Swift implementation of RTOW. Supports Swift concurrency (multi-threading) on CPU cores and iterative ray tracing.|
|`RtowView.swift`|The application main view.|
|`Fsm.swift`|The UI finite state machine.|
|`ButtonStyle.swift`|Base (load) button style configuration data and code.|
|`FinderViews.swift`|Finder views for viewer, camera and optics controls.|
|`Extension.swift`|Extensions to SwiftUI classes and protocols.|
|`Error.swift`|Error exceptions enum.|
|`Stack.swift`|Stack implementation.|
