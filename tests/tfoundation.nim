import objc
import objc/foundation
import unittest

proc mk*(self: typedesc[NSArray]; o1, o2: Id): NSArray =
  let send = cast[proc(self: Id, sel: Selector; o1, o2: Id): Id {. cdecl .}](objc_MsgSend)
  newNSArray(send(self.id, $$"arrayWithObjects:", o1, o2))

proc at*(self: NSArray; index: int): Object =
  let send = cast[proc(self: Id, sel: Selector; index: culong): Id {. cdecl .}](objc_MsgSend)
  newObject(send(self.id, $$"objectAtIndex:", culong index))

suite "foundation":
  test "NSArray":
    let obj = NSObject.alloc
    let
      ar1 = nsarray(obj)
      ar2 = nsarray(obj, obj)
      ar3 = nsarray(obj, obj, obj)
      ar4 = nsarray(obj, obj, obj, obj)
    check ar1[0].id == obj.id
    check ar2[0].id == obj.id
    check ar2[1].id == obj.id
    check ar3[0].id == obj.id
    check ar3[1].id == obj.id
    check ar3[2].id == obj.id
    check ar4[0].id == obj.id
    check ar4[1].id == obj.id
    check ar4[2].id == obj.id
    check ar4[3].id == obj.id
