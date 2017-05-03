# File: main.nim
import nimx.window
import nimx.text_field
import nimx.system_logger # Required because of Nim bug (#4433)

proc startApp() =
    # First create a window. Window is the root of view hierarchy.
    var wnd = newWindow(newRect(40, 40, 800, 600))

    # Create a static text field and add it to view hierarchy
    let label = newLabel(newRect(20, 20, 150, 20))
    label.text = "Hello, world!"
    wnd.addSubview(label)

# Run the app
runApplication:
    startApp()
