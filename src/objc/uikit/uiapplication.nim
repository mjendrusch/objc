import objc
import objc.foundation

importClass UIApplication of NSObject

# FIXME
importClass UIApplicationDelegate of NSObject

proc sharedApplicationImpl*: Id {. importc: "sharedApplication" .}
proc sharedApplication*: UIApplication =
  newUIApplication(sharedApplicationImpl())

proc `delegate=`*(self: UIApplication; del: UIApplicationDelegate): void {.
  importMethod: "setDelegate:"
.}