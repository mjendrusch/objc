import objc
import macros

type
  CFType* = ref object {. pure, inheritable .}
    data: pointer
  CFTypeId* = distinct uint
  CFOptionFlags* = uint
  CFHashCode* = uint
  CFIndex* = int
  CFRange* = object
    location*: CFIndex
    length*: CFIndex

proc newCoreFoundationObject*[T](x: pointer): T =
  T(data: x)

proc release(x: pointer) {. importc: "CFRelease" .}
proc retain(x: pointer) {. importc: "CFRetain" .}

proc finalize*(x: CFType) = release(x.data)

proc genCoreFoundationType(typ: NimNode): NimNode =
  ## Generates a wrapped CoreFoundation type, without
  ## an explicit supertype.
  let
    newName = ident("new" & $typ)
  result = quote do:
    type
      `typ`* = ref object of CFType
    proc finalize*(x: `typ`) = release(x.data)
    proc `newName`*(x: pointer): `typ` = newCoreFoundationObject[`typ`](x)

proc genCoreFoundationType(typ, super: NimNode): NimNode =
  ## Generates a wrapped CoreFoundation type, with an
  ## explicit supertype.
  let
    newName = ident("new" & $typ)
  result = quote do:
    type
      `typ`* = ref object of `super`
    proc finalize*(x: `typ`) = release(x.data)
    proc `newName`*(x: pointer): `typ` =
      `typ`(data: x)

macro importCoreFoundationType(nameExpr: untyped): untyped =
  if nameExpr.kind == nnkInfix and nameExpr[0].eqIdent("of"):
    let
      typ = nameExpr[1]
      super = nameExpr[2]
    result = genCoreFoundationType(typ, super)
  else:
    result = genCoreFoundationType(nameExpr)

importCoreFOundationType CFPropertyList
importCoreFoundationType CFString of CFPropertyList
importCoreFoundationType CFMutableString of CFString
importCoreFoundationType CFAllocator