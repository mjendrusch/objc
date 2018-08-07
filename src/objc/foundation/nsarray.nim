import objc
import nsobject
import objc/utils/varargsObjectToIdPointer
# import nsindexset

importClass NSArray[T] of NSObject
importClass NSMutableArray[T] of NSArray[T]

# NSArray methods:
proc make*(self: typedesc[NSArrayAny]): NSArrayAny {. importMethod: "array" .}
proc make*(self: typedesc[NSArrayAny]; os: pointer; count: cuint): NSArrayAny {. importMethod: "arrayWithObjects:count:" .}
proc init*(self: NSArrayAny): NSArrayAny {. importMethod: "init" .}
proc init*(self: NSArrayAny; ar: NSArrayAny): NSArrayAny {. importMethod: "initWithArray:" .}
proc init*(self: NSArrayAny; ar: NSArrayAny; copy: bool): NSArrayAny {. importMethod: "initWithArray:copyItems:" .}
proc init*(self: NSArrayAny; o1: NSObject): NSArrayAny {. importMethod: "initWithObjects:" .}
proc contains*(self: NSArrayAny; obj: Object): bool {. importMethod: "containsObject:" .}
proc len*(self: NSArrayAny): int {. importMethod: "count" .}
proc first*(self: NSArrayAny): Object {. importMethod: "firstObject" .}
proc last*(self: NSArrayAny): Object {. importMethod: "lastObject" .}
proc `[]`*(self: NSArrayAny; index: culong): Object {. importMethod: "objectAtIndex:" .}
# proc `[]`*(self: NSArrayAny; index: NSIndexSet): NSArrayAny {. importMethod: "objectsAtIndexes:" .}
proc index*(self: NSArrayAny; obj: Object): uint {. importMethod: "indexOfObject:" .}
proc map*(self: NSArrayAny; sel: Selector): Object {. importMethod: "makeObjectsPerformSelector:" .}
proc `==`*(self: NSArrayAny; other: NSArrayAny): bool {. importMethod: "isEqualToArray:" .}

proc make*[T](self: typedesc[NSArray[T]]): NSArray[T] {. genericMethod .}
proc init*[T](self: NSArray[T]): NSArray[T] {. genericMethod .}
proc init*[T](self: NSArray[T]; ar: NSArray[T]): NSArray[T] {. genericMethod .}
proc init*[T](self: NSArray[T]; ar: NSArray[T]; copy: bool): NSArray[T] {. genericMethod .}
proc contains*[T](self: NSArray[T]; obj: T): bool {. genericMethod .}
proc len*[T](self: NSArray[T]): int {. genericMethod .}
proc first*[T](self: NSArray[T]): T {. genericMethod .}
proc last*[T](self: NSArray[T]): T {. genericMethod .}
proc `[]`*[T](self: NSArray[T]; index: culong): T {. genericMethod .}
# proc `[]`*[T](self: NSArray[T]; index: NSIndexSet): NSArray[T] {. genericMethod .}
proc index*[T](self: NSArray[T]; obj: T): uint {. genericMethod .}
proc map*[T](self: NSArray[T]; sel: Selector): void {. genericMethod .}
proc `==`*[T](self: NSArray[T]; other: NSArray[T]): bool {. genericMethod .}

# objc-module functionality:

proc make*[T](self: typedesc[NSArray[T]]; os: varargs[T]): NSArray[T] =
  ## Varargs utility function.
  let
    (p, l) = toIdPointer os
  newNSArray[NSObject](self.make(p, l).id)

proc nsarray*[T](os: varargs[T]): NSArray[T] =
  ## Varargs utility function.
  NSArray[NSObject].make(os)
