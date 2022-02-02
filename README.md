# SwiftRTOW
Peter Shirley's ray tracer from his mini-book [Ray Tracing in one weekend](https://github.com/RayTracing/raytracing.github.io/) (RTOW).

### Tools
Apps used on iPad
- [Swift Playgrounds 4](https://apps.apple.com/de/app/swift-playgrounds/id908519492)
- [Working Copy](https://workingcopyapp.com/)
- [Textastic](https://www.textasticapp.com/) (can edit SP4 `.swiftpm` files)
- [GitHub](https://apps.apple.com/us/app/github/id1477376905)

Apps used on Winos 10
- [Swift on Windows](https://www.swift.org/blog/swift-on-windows/) 5.6[^1]
- [ImageMagick](https://imagemagick.org/script/download.php) 7

[^1]: Swift concurrency does not work in 5.5 ([post](https://forums.swift.org/t/swift-concurrency-dep-access-violation-on-task-deallocation/54224))

### Setup
- Create repository on GitHub (default settings)
- Clone repository from GitHub

  **Cygwin command prompt (bash)**
  ```
  git clone https://github.com/otabuzzman/SwiftRTOW

  cd SwiftRTOW
  ```
- Swift package initialization

  **Winos command prompt (CMD)**
  ```
  cd SwiftRTOW

  swift package init --type executable

  rem check (Hello world)
  swift run
  ```

### Usage on Windows
- Clone repository from GitHub
- Run commands in top-level directory

```
# run (background) implies build
swift run >rtow.ppm

# foreground run
.build\debug\SwiftRTOW.exe >rtow.ppm

# convert result to PNG
magick rtow.ppm rtow.png

# show result
cmd /c rtow.png
```

### Usage in Swift Playgrounds 4
- Ceate new app in SP4
- Delete predefined `*.swift` files in app
- Copy&paste Swift files from repository to app
