import objc
import objc.foundation
import unittest

proc mk*(self: typedesc[NSArray]; o1, o2: Id): NSArray =
  let send = cast[proc(self: Id, sel: Selector; o1, o2: Id): Id {. cdecl .}](objc_MsgSend)
  newNSArray(send(self.id, $$"arrayWithObjects:", o1, o2))

proc at*(self: NSArray; index: int): Object =
  let send = cast[proc(self: Id, sel: Selector; index: culong): Id {. cdecl .}](objc_MsgSend)
  newObject(send(self.id, $$"objectAtIndex:", culong index))

suite "foundation":
  test "NSObject":
    let obj = NSObject.alloc
    let ar = NSArray.make(obj.id, obj.id)
    check ar[0].id == obj.id
    check ar[1].id == obj.id
