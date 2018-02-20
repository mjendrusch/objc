import objc
# import nsmethodsignature
# import nsmethodinvocation

importClass NSObject:
  isa: Class

proc alloc*(self: typedesc[NSObject]): NSObject {. importMethod: "alloc" .}
proc init*(self: NSObject): NSObject {. importMethod: "init" .}
proc copy*(self: NSObject): NSObject {. importMethod: "copy" .}
proc mutableCopy*(self: NSObject): NSObject {. importMethod: "mutableCopy" .}
proc dealloc*(self: NSObject): NSObject {. importMethod: "dealloc" .}
proc methodForSelector*(self: NSObject; sel: Selector): Implementation {. importMethod: "methodForSelector:" .}
# proc methodSignatureForSelector*(self: NSObject; sel: Selector): NSMethodSignature {. importMethod: "methodSignatureForSelector" .}
proc forwardingTargetForSelector*(self: NSObject; sel: Selector): Object {. importMethod: "forwardingTargetForSelector:" .}
# proc forwardInvocation*(self: NSObject; inv: NSInvocation) {. importMethod: "forwardInvocation:" .}
proc methodMissing*(self: NSObject; sel: Selector): Object {. importMethod: "doesNotRecognizeSelector:" .}
