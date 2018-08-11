import objc
import objc / [foundation, coregraphics]
import uiclasses

UIWindow.importProperties:
  rootViewController is UIViewController
  windowLevel is UIWindowLevel
  screen is UIScreen
  (keyWindow is Boolean)[readonly = true, getName = "isKeyWindow"]

proc makeKeyAndVisible*(self: UIWindow): void {. importMethod: "makeKeyAndVisible" .}
proc makeKeyWindow*(self: UIWindow): void {. importMethod: "makeKeyWindow" .}

# TODO: rest