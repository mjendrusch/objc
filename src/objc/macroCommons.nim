import objc / [base, hli]
import macros

when defined(manualMode):
  type
    ClassType* = object {. inheritable .}
      class*: Class
    MetaClassType* = object {. inheritable .}
      class*: Class
    Object* = ptr object {. pure, inheritable .}
    AsSuper*[Obj] = object
      obj: Obj
      class: Class
    SharedObject* = ptr object of Object
    UnsafeObject* = ptr object of Object
else:
  type
    ClassType* = object {. inheritable .}
      class*: Class
    MetaClassType* = object {. inheritable .}
      class*: Class
    Object* = ref object of RootObj
      id*: Id
    AsSuper*[Obj] = object
      obj: Obj
      class: Class
    SharedObject* = ref object of Object
    UnsafeObject* = object of Object

{. hints: off .}

type
  AbstractObject* = concept obj
    obj is Object
    obj isnot typedesc
  AbstractObjectType* = concept obj
    obj is typedesc[Object]

{. hints: on .}

proc asSuper*[T: AbstractObject](x: T): AsSuper[T] {. inline .} =
  AsSuper[T](obj: x, class: x.class.super)
proc asSuper*[T: AbstractObject; U: AbstractObjectType](x: T; super: U): AsSuper[T] {. inline .} =
  AsSuper[T](obj: x, class: super.class)
template id*[T: AbstractObject](x: AsSuper[T]): ptr Super =
  var res = Super(receiver: x.obj.id, superClass: x.class)
  res.addr

iterator supers*(typ: NimNode): NimNode =
  ## Iterates over all super types of a given object type
  ## represented by a NimNode.
  expectKind typ, {nnkObjectTy, nnkRefTy, nnkPtrTy}
  if typ.kind == nnkPtrTy and typ[0].kind != nnkObjectTy and typ[0].getTypeImpl.len < 2:
    discard
  else:
    var
      previousInherit = newEmptyNode()
      lastInherit =
        if typ.kind in {nnkRefTy, nnkPtrTy}:
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
  if typ.kind notin {nnkObjectTy, nnkRefTy, nnkPtrTy}:
    return false
  for super in typ.supers:
    if super.eqIdent "ClassType":
      return true

proc isObject*(typ: NimNode): bool =
  ## Checks, whether an object type represents an Objective-C object.
  result = false
  if typ.kind == nnkBracketExpr:
    return isObject(typ[0].getTypeImpl)
  if typ.kind notin {nnkObjectTy, nnkRefTy, nnkPtrTy}:
    return false
  if typ[0].eqIdent "Object:ObjectType":
    return true
  for super in typ.supers:
    if super.eqIdent "Object":
      return true

when defined(manualMode):
  template id*(obj: Object): Id =
    ## Converts an Object into an Id.
    cast[Id](obj)
  template `id=`*[T: Object](obj: var T; id: Id) =
    ## Sets the Id of an Object.
    obj = cast[T](id)

  proc newObject*(id: Id): Object =
    ## Creates a newObject from an Id.
    cast[Object](id)
else:
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
