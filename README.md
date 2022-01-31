# SwiftRTOW
Peter Shirley's ray tracer from his mini-book [Ray Tracing in one weekend](https://github.com/RayTracing/raytracing.github.io/) (RTOW).

### Tools
Apps used on iPad
- [Swift Playgrounds 4](https://apps.apple.com/de/app/swift-playgrounds/id908519492)
- [Working Copy](https://workingcopyapp.com/)
- [Textastic](https://www.textasticapp.com/) (can edit SP4 `.swiftpm` files)
- [GitHub](https://apps.apple.com/us/app/github/id1477376905)

Apps used on Winos 10
- [Swift on Windows](https://www.swift.org/blog/swift-on-windows/) 5.5
- [ImageMagick](https://imagemagick.org/script/download.php) 7

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
- Setup new app in SP4
- Delete `*.swift` files
- Copy Swift files to app
- Create file `RtowView.swift` :

  ```
  import SwiftUI
  
  struct RtowView: UIViewRepresentable {
      @Binding var raycer: Rtow
      @Binding var update: Bool
      
      func makeUIView(context: Context) -> UIImageView {
          let w = raycer.imageWidth
          let h = raycer.imageHeight
          
          var imageData: [Pixel] = .init(repeating: .init(x: 0, y: 0, z: 0, w: 255), count: w*h)
          for i in imageData.indices {
              imageData[i].x = .random(in: 0...255)
              imageData[i].y = .random(in: 0...255)
              imageData[i].z = .random(in: 0...255)
              imageData[i].w = 255
          }
          
          let splash = UIImage(imageData: imageData, imageWidth: w, imageHeight: h)
          return UIImageView(image: splash)
      }
      
      func updateUIView(_ uiView: UIImageView, context: Context) {
          if !update {
              return
          }
          
          uiView.image = UIImage(
              imageData: raycer.imageData!,
              imageWidth: raycer.imageWidth,
              imageHeight: raycer.imageHeight)!
      }
  }
  
  struct ContentView: View {
      @State private var raycer = Rtow()
      @State private var update = false
      
      var body: some View {
          RtowView(raycer: $raycer, update: $update)
              .task {
                  raycer.imageWidth = 320
                  raycer.imageHeight = 240
                  raycer.samplesPerPixel = 1
                  raycer.camera.set(aspratio: 320.0/240.0)
                  
                  raycer.render()
                  update.toggle()
              }
      }
  }
  
  @main
  struct MyApp: App {
      var body: some Scene {
          WindowGroup {
              ContentView()
          }
      }
  }
  ```
