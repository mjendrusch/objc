import objc.base, objc.hli
import macros

type
  ClassType* = object {. inheritable .}
    class*: Class
  MetaClassType* = object {. inheritable .}
  Object* = ref object of RootObj
    id*: Id
  SharedObject* = ref object of Object
  UnsafeObject* = object of Object

  AbstractObject* = concept obj
    obj is Object
    obj isnot typedesc
  AbstractObjectType* = concept obj
    obj is typedesc[Object]

iterator supers*(typ: NimNode): NimNode =
  ## Iterates over all super types of a given object type
  ## represented by a NimNode.
  assert typ.kind in {nnkObjectTy, nnkRefTy}
  var
    previousInherit = newEmptyNode()
    lastInherit =
      if typ.kind == nnkRefTy:
        typ[0].getTypeImpl[1]
      else:
        typ[1]
  while lastInherit.kind == nnkOfInherit:
    yield lastInherit[0]
    if lastInherit[0].eqIdent "RootObj":
      break
    let
      typeImpl = getTypeImpl(lastInherit[0])
    if typeImpl.kind == nnkSym:
      lastInherit = getTypeImpl(lastInherit[0])[1]
    elif typeImpl.kind == nnkRefTy:
      lastInherit = getTypeImpl(lastInherit[0])[0].getTypeImpl[1]
    if previousInherit == lastInherit[0]:
      break
    previousInherit = lastInherit[0]

proc isClass*(typ: NimNode): bool =
  ## Checks, whether an object type represents an Objective-C class.
  result = false
  if typ.kind notin {nnkObjectTy, nnkRefTy}:
    return false
  for super in typ.supers:
    if super.eqIdent "ClassType":
      return true

proc isObject*(typ: NimNode): bool =
  ## Checks, whether an object type represents an Objective-C object.
  result = false
  if typ.kind notin {nnkObjectTy, nnkRefTy}:
    return false
  if typ[0].eqIdent "Object:ObjectType":
    return true
  for super in typ.supers:
    if super.eqIdent "Object":
      return true

proc objectDispose*(obj: Object) =
  ## Disposes a Object, by releasing its Id.
  when defined(objcDebugAlloc):
    echo "RELEASED (Object): ", repr(cast[pointer](obj.id))
  discard objcMsgSend(obj.id, $$"release")

proc newObject*(id: Id): Object =
  ## Creates a new Object from an Id by retaining that Id.
  new result, objectDispose
  result.id = id
  when defined(objcDebugAlloc):
    echo "RETAINED (Object): ", repr(cast[pointer](id))
  discard objcMsgSend(result.id, $$"retain")
