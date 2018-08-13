import objc
import objc / foundation
import objc / uikit / [uiclasses, uiapplication, uicolor, uiscreen, uiview, uiviewcontroller, uiwindow]
export uiclasses, uiapplication, uicolor, uiscreen, uiview, uiviewcontroller, uiwindow
import os

{. passL: "-framework UIKit" .}

proc UIApplicationMainImpl(argc: cint; argv: cStringArray; className: Id; delegateName: Id): cint {.
  importc: "UIApplicationMain", cdecl
.}
proc UIApplicationMain*(delegate: string): cint =
  let
    argc = cint paramCount()
    argv = allocCStringArray commandLineParams()
    className = Id(nil)
    delegateName = ($!delegate).id
  return UIApplicationMainImpl(argc, argv, className, delegateName)