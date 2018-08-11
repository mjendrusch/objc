import objc
import objc/foundation
import uiclasses

proc sharedApplicationImpl*: Id {. importc: "sharedApplication" .}
proc sharedApplication*: UIApplication =
  newUIApplication(sharedApplicationImpl())

proc `delegate=`*(self: UIApplication; del: UIApplicationDelegate): void {.
  importMethod: "setDelegate:"
.}