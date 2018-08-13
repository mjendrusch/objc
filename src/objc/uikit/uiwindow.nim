import objc
import objc / [foundation, coregraphics]
import uiclasses

UIWindow.importProperties:
  rootViewController is UIViewController
  windowLevel is UIWindowLevel
  screen is UIScreen
  (keyWindow is Boolean)[readonly = true, getName = "isKeyWindow"]

proc alloc*(self: typedesc[UIWindow]): UIWindow {. importMethod: "alloc" .}
proc init*(self: UIWindow; args: CGRect): UIWindow {. importMethod: "initWithFrame:" .}
proc makeKeyAndVisible*(self: UIWindow): void {. importMethod: "makeKeyAndVisible" .}
proc makeKeyWindow*(self: UIWindow): void {. importMethod: "makeKeyWindow" .}

# TODO: rest