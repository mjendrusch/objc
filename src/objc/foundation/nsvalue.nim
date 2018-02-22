import objc
import nsobject

importClass NSValue of NSObject

proc encoding*(self: NSValue): cstring {. importMethod: "objCType" .}
proc newValueWithEncoding*(self: typedesc[NSValue]; val: pointer; encoding: cstring): NSValue
  {. importMethod: "value:withObjCType:" .}
proc getValue*(self: NSValue; value: pointer; size: culong): void {. importMethodAuto .}

## Additional Nim-only functionality:
template newValue*[T](obj: var T): NSValue =
  ## Creates a new NSValue using a Nim object
  NSValue.newValueWithEncoding(obj.addr, encode T)
template to*[T](self: NSValue; typ: typedesc[T]): T =
  ## Unboxes a ``NSValue`` to a Nim value.
  var res: T
  self.getValue(res.addr, sizeof typ)
  res
