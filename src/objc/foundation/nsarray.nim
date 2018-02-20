import objc
import nsobject
# import nsindexset

importClass NSArray

proc make*(self: typedesc[NSArray]): NSArray {. importMethod: "array" .}
proc make*(self: typedesc[NSArray]; o1, o2: Id): NSArray {. importMethod: "arrayWithObjects:" .}
proc init*(self: NSArray): NSArray {. importMethod: "init" .}
proc init*(self: NSArray; ar: NSArray): NSArray {. importMethod: "initWithArray:" .}
proc init*(self: NSArray; ar: NSArray; copy: bool): NSArray {. importMethod: "initWithArray:copyItems:" .}
proc init*(self: NSArray; o1: NSObject): NSArray {. importMethod: "initWithObjects:" .}
proc contains*(self: NSArray; obj: Object): bool {. importMethod: "containsObject:" .}
proc len*(self: NSArray): int {. importMethod: "count" .}
proc first*(self: NSArray): Object {. importMethod: "firstObject" .}
proc last*(self: NSArray): Object {. importMethod: "lastObject" .}
proc `[]`*(self: NSArray; index: culong): Object {. importMethod: "objectAtIndex:" .}
# proc `[]`*(self: NSArray; index: NSIndexSet): NSArray {. importMethod: "objectsAtIndexes:" .}
proc index*(self: NSArray; obj: Object): uint {. importMethod: "indexOfObject:" .}
proc map*(self: NSArray; sel: Selector): Object {. importMethod: "makeObjectsPerformSelector:" .}
proc `==`*(self: NSArray; other: NSArray): bool {. importMethod: "isEqualToArray:" .}
