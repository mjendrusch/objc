import objc.base
import macros

type
  ClassType* = object {. inheritable .}
  MetaClassType* = object {. inheritable .}
  Object* = ref object of RootObj
    id: Id

iterator supers*(typ: NimNode): NimNode =
  assert typ.kind == nnkObjectTy
  var
    lastInherit = typ[1]
  while lastInherit.kind == nnkOfInherit:
    yield lastInherit[0]
    lastInherit = getTypeImpl(lastInherit[0])[1]

proc isClass*(typ: NimNode): bool =
  result = false
  for super in typ.supers:
    if super.eqIdent "ClassType":
      return true
