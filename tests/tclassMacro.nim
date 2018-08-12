import objc
import unittest

importClass NSObject
objectiveClass RootTest of NSObject
objectiveClass InheritTest of RootTest
objectiveClass RootFieldsTest of NSObject:
  a: int
  b: cstring
objectiveClass InheritNoFieldsTest of RootFieldsTest
objectiveClass InheritFieldsTest of RootFieldsTest:
  c: float
objectiveClass GenericTest[T, U]
objectiveClass MoreGenerics[T] of GenericTest[T, T]
importClass NSArray[T] of NSObject

{. push hint[XDeclaredButNotUsed]:off .}

suite "class macro":
  setup:
    let
      nso = newNSObject()
      rt = newRootTest()
      it = newInheritTest()
      rft = newRootFieldsTest()
      inft = newInheritNoFieldsTest()
      ift = newInheritFieldsTest()
  test "class allocation":
    check pointer(nso.id) != nil
    check pointer(rt.id) != nil
    check pointer(it.id) != nil
    check pointer(rft.id) != nil
    check pointer(inft.id) != nil
    check pointer(ift.id) != nil
  test "class variables":
    check nso.class == class"NSObject"
    check rt.class == class"RootTest"
    check rt.super == class"NSObject"
    check it.class == class"InheritTest"
    check it.super == class"RootTest"
    check it.super.super == class"NSObject"
    check rft.class == class"RootFieldsTest"
    check rft.super == class"NSObject"
    check inft.class == class"InheritNoFieldsTest"
    check inft.super == class"RootFieldsTest"
    check inft.super.super == class"NSObject"
    check ift.class == class"InheritFieldsTest"
  test "class types":
    doAssert nso.classType is NSObjectClass
    doAssert rt.classType is RootTestClass
    doAssert rt.metaClassType is RootTestMetaClass
    doAssert rt.superClassType is NSObjectClass
    doAssert nso.type.classType is NSObjectClass
    doAssert rt.type.classType is RootTestClass
    doAssert rt.type.metaClassType is RootTestMetaClass
    doAssert rt.type.superClassType is NSObjectClass
  test "member fields":
    let
      nsoVars = nso.class.ivars
      rtVars = rt.class.ivars
      itVars = it.class.ivars
      rftVars = rft.class.ivars
      iftVars = ift.class.ivars
      inftVars = inft.class.ivars
    check nsoVars.len == 1
    check nsoVars[0].name == "isa"
    check nsoVars[0].typeEncoding == "#"
    check rtVars.len == 0
    check itVars.len == 0
    check rftVars.len == 2
    check rftVars[0].name == "a"
    check rftVars[1].name == "b"
    check rftVars[0].typeEncoding == "q"
    check rftVars[1].typeEncoding == "*"
    check iftVars.len == 1
    check iftVars[0].name == "c"
    check iftVars[0].typeEncoding == "d"

    rft.a = 42
    check rft.a == 42

{. pop .}
