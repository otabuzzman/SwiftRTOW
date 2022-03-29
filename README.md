# SwiftRTOW
A SwiftUI version of Peter Shirley's ray tracer from his mini-book [Ray Tracing in One Weekend](https://github.com/RayTracing/raytracing.github.io/) (RTOW).

Development happened in *Swift Playgrounds 4* on iPad except transcription of RTOW from C++ to Swift with help of *Swift on Windows*. As a side effect transcription yielded a command-line Swift version of RTOW. It's in the `swindows` branch with hints on build and usage. SwiftRTOW extends Peter's version with multi-threading and some UI controls to change render parameters using common iOS gestures.

### Concept
After starting SwiftRTOW renders the scene from chapter 10 on all available CPU cores and displays the result. Below the render view is a button bar that allows loading scenes from chapters 8, 10 and 13. The latter is the image from the book's cover.

A single tap on the render view displays more buttons and a finder. This control view disappears after a few seconds when no gestures occur. On disappearing it re-renders the scene if changes were applied.

The button bar in the control view is used to select viewer position, camera direction, and optics. The finder area in the control view gives a coarse indication of how the different controls will impact rendering. A small pale-colored rectangle with a bold outline represents the current image. It provides optical feedback on parameter changes using the controls.

**Change viewer position**

Tap in render view to open controls view. Press the location button to enter change viewer position mode. Apply a drag gesture to move the viewer around. The boldly outlined finder rectangle indicates the new position. Use a magnify gesture to change viewer's distance. The pale-colored finder changes its size accordingly.

**Change camera direction**

Tap in render view to open controls view. Press the camera button to enter change camera direction mode. Use drag to change  camera direction. The pale-colored finder rectangle 3D-rotates accordingly. The rotate gesture rolls the camera around its direction axis. The boldly outlined finder rectangle rotates accordingly.

**Change camera optics**

Tap in render view to open controls view. Press the lens button to enter change camera optics mode. Drag changes aperture yielding blur. The boldly outlined finder rectangle indicates the effect by gradually applying a transparent filled overlay. The magnify gesture changes the field of view. The effect is the same as changing the viewer's distance. Therefore the indication by the pale-colored finder rectangle is the same as well, that is it changes its size accordingly. Apply a rotate gesture to change depth of field (focus distance). The diameter of the thin-lined circle inside the boldly outlined rectangle reflects the set value: the smaller the diameter the farther away is the focus.

A long press on the render view yields the current image to be saved in a Photos album named SwitRTOW.

### Tools
Apps used on iPad
- [Swift Playgrounds 4](https://apps.apple.com/de/app/swift-playgrounds/id908519492) (SP4)
- [Working Copy](https://workingcopyapp.com/)
- [Textastic](https://www.textasticapp.com/) (can handle files in *Swift Playgrounds* and *Working Copy* folders)
- [GitHub](https://apps.apple.com/us/app/github/id1477376905)

### Build
- Ceate new app[^1] in SP4

  - Set app name and color
  - Add app icon
  - Add *Photo Library (Add Only)* capability

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
