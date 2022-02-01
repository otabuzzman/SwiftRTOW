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

[^1] Swift concurrency does not work in 5.5 ([post](https://forums.swift.org/t/swift-concurrency-dep-access-violation-on-task-deallocation/54224))

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
  The tedious approach to getting the files into the app is to manually build each file (except `Unknown.swift`) found in `Sources/SwiftaRROW` in SP4, leave them empty for now, and then copy&paste the contents file by file. For instance, one could open the repository in Safari, click on each file, copy its contents, switch to SP4, create the file and paste the clipboard into it.

  The much easier approach is to just copy the files from one folder to another. Unfortunately *hides* SP4 the project folders and launches the app when trying to open them using *Files*. Accessing the repository folder on iPad is a little hurdle as well.

  To solve these, the repository needs first to be cloned somewhere into the file system where it is accessible for the iPad (e.g. using *Working Copy*). After that, the files can be copied by using a tool that allows for *real* file access on iPad (e.g. *Textastic*).
