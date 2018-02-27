import objc
import unittest
import macros

objectiveProtocol InitAble:
    proc init*(self: InitAble): type(self)

importClass NSObject:
  isa: Class

objectiveClass AClass of NSObject

proc init*(self: NSObject): NSObject {. importMethodAuto .}
proc init*(self: AClass): AClass {. importMethodAuto .}
proc test(self: InitAble): Id = self.id

suite "protocol macro":
  setup:
    var
      nso {. used .} = newNSObject()
      acl {. used .} = newAClass()
  test "simple protocol":
    let
      initable = nso.toInitAble
    check nso is AbstractInitAble
    check acl is AbstractInitAble
    check initable.id == nso.id
    check test(nso.toInitAble) == nso.id
    check test(acl.toInitAble) == acl.id
  test "generic protocol":
    ## Not yet implemented.
    discard
  test "conversion":
    ## No converters used at this time, due to Nim issue #7270.
    discard
  test "generic class with protocol constraint":
    ## Not yet implemented
    discard
