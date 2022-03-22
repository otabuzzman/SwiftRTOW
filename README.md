# SwiftRTOW
A SwiftUI version of Peter Shirley's ray tracer from his mini-book [Ray Tracing in One Weekend](https://github.com/RayTracing/raytracing.github.io/) (RTOW).

### Concept
Development happened in *Swift Playgrounds 4* on iPad except transcription of RTOW from C++ to Swift with help of *Swift on Windows*. As a side effect transcription yielded a command-line Swift version of RTOW. Switch to `swindows` branch for hints on build and usage. The `main` branch (this) contains the code of the app eventually uploaded to the App Store using SP4. 

### Tools
Apps used on iPad
- [Swift Playgrounds 4](https://apps.apple.com/de/app/swift-playgrounds/id908519492) (SP4)
- [Working Copy](https://workingcopyapp.com/)
- [Textastic](https://www.textasticapp.com/) (can handle files in *Swift Playgrounds* and *Working Copy* folders)
- [GitHub](https://apps.apple.com/us/app/github/id1477376905)

### Build
- Ceate new app[^1] in SP4
- Delete predefined `*.swift` files in app
- Copy&paste Swift files from repository to app

  - Get repository on iPad (Working Copy)
  - Copy files from WC to SP4 folder (Textastic)

- Add PNG files with SP4 as resources to app

[^1]: Running the code in a Playground crashes SP4.

### Which file for what
|File|Comment|
|:---|:------|
|`CpuRTOW`<br>(folder)|A Swift implementation of RTOW. Supports Swift concurrency (multi-threading) on CPU cores and iterative ray tracing.|
|`SwiftRTOW.swift`|The application main view.|
|`ButtonStyle.swift`|Base and side button style configurations and code.|
|`Fsm.swift`|The UI finite state machine.|
|`Finder.swift`|Finder views for viewer, camera and optics controls.|
|`Paddle.swift`|An abstraction of a trackball control device.|
|`Exception.swift`|Error exceptions.|
|`Extension.swift`|SwiftUI classes and protocols extensions.|
|`Stack.swift`|A stack implementation.|
