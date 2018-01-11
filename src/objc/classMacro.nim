import objc.base, objc.hli
import macros

proc makeClassNames(nameExpr: NimNode): tuple[class, super: NimNode] =
  ## Gets identifiers for super class and new class from a
  ## class name expression.
  if nameExpr.kind == nnkInfix:
    return (nameExpr[1], nameExpr[2])
  else:
    return (nameExpr, nil)

proc makeClassTypeDecl(class, super: NimNode): NimNode =
  ## Creates type declarations for classes based on their
  ## name and the name of their superclass, if any.
  if super.isNil:
    result = quote do:
      type
        `class`* = object {. inheritable .}
          id: Id
  else:
    result = quote do:
      type
        `class`* = object of `super`

proc makeClassVariable(class, super: NimNode): NimNode =
  ## Creates an Objective-C runtime Class variable, tied
  ## to a Nim type of name `class`.
  let
    className = class.toStrLit
    superName =
      if super.toStrLit.strVal == "nil":
        nil
      else:
        super.toStrLit
    procName = ident"class"
    converterName = ident"dyn"
    classType = bindsym"Class"
  result = quote do:
    block:
      var theClass = newClass(`superName`, class(`className`), 0) # FIXME
      theClass.register
    template `procName`*(clsType: typedesc[`class`]): `classType` =
      class(`className`)
    template `converterName`*(cls: `class`): Id = cast[Id](cls)

macro objectiveClass*(nameExpr: untyped, decls: untyped): untyped =
  ## Creates types, variables and procedures for an Objective-C
  ## class from a declarative DSL:
  ##
  ## .. code-block :: nim
  ##    objectiveClass <ident / ident of ident>:
  ##      <ident defs>
  #echo nameexpr.treeRepr
  #echo decls.treeRepr
  let
    (className, superName) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName)
    classVariable = makeClassVariable(className, superName)
  echo typeDecl.toStrLit
  echo classVariable.toStrLit
  return newTree(nnkStmtList)

macro objectiveProtocol*(nameExpr: untyped, decls: untyped): untyped =
  ## Creates concepts, variables and procedures for an Objective-C
  ## protocol.
  discard

macro objectiveProperty*(nameExpr: untyped, procedure: untyped): untyped =
  ## Creates an Objective-C property for an Objective-C class,
  ## given a procedure implementing that property.
  discard

converter toProtocol*[T: AbstractProtocol](x: T): int =
  ## Converts a concrete Objective-C class type to a protocol type
  ## it conforms to. TODO in macro.
  discard

objectiveClass Test of NSObject:
  a: int
objectiveClass TestRoot:
  c: float
