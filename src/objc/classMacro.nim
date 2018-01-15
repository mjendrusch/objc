import objc.base, objc.hli, objc.typeEncoding
import macros

type
  Object* = ref object of RootObj
    id: Id

proc makeClassNames(nameExpr: NimNode): tuple[class, super: NimNode] =
  ## Gets identifiers for super class and new class from a
  ## class name expression.
  if nameExpr.kind == nnkInfix:
    return (nameExpr[1], nameExpr[2])
  else:
    return (nameExpr, nil)

proc makeClassTypeDecl(class, super, decls: NimNode): NimNode =
  ## Creates type declarations for classes based on their
  ## name and the name of their superclass, if any.
  let
    className = ident($class.ident & "Class")
    metaClassName = ident($class.ident & "MetaClass")
  if super.isNil:
    result = quote do:
      type
        `metaClassName`* = object of MetaClassType
        `className`* = object of ClassType
        `class`* = ref object of Object
      template class*(typ: typedesc[`class`]): untyped = `className`
      template metaClass*(typ: typedesc[`class`]): untyped = `metaClassName`
  else:
    let
      superClassName = ident($super.ident & "Class")
      superMetaClassName = ident($super.ident & "MetaClass")
    result = quote do:
      type
        `metaClassName`* = object of `superMetaClassName`
        `className`* = object of `superClassName`
        `class`* = ref object of `super`
      template classType*(typ: typedesc[`class`]): untyped = `className`
      template metaClassType*(typ: typedesc[`class`]): untyped = `metaClassName`
  var
    typeDecl = result[0][1]
  typeDecl[^1][^1] = newNimNode(nnkRecList)
  for decl in decls:
    typeDecl[^1][^1].add newTree(nnkIdentDefs,
      decl[0], decl[1][0], newEmptyNode())

template alignment(typ: typed): untyped =
  ## Emits code to compute the alignment of a Nim type.
  var
    running = uint sizeof(typ)
    count = 0
  while running != 0:
    running = running shr 1
    inc count
  count

proc makeSingleIvar(decl: NimNode; classVariable: NimNode): NimNode =
  ## Creates an Objective-C runtime call adding an Ivar corresponding to
  ## ``decl`` to the class ``class``.
  let
    ivarName = decl[0].toStrLit
    ivarType = decl[1][0]
    alignmentProc = bindsym"alignment"
    encodeMacro = bindsym"encode"
  result = quote do:
    discard`classVariable`.addIvar(`ivarName`, sizeof(`ivarType`),
                                   `alignmentProc`(`ivarType`),
                                   $`encodeMacro`(`ivarType`))

proc makeClassIvars(decls: NimNode; classVariable: NimNode): NimNode =
  ## Creates the Objective-C runtime calls necessary to bind Ivars corresponding
  ## to the field declarations in decls to an Objective-C class object.
  result = newNimNode(nnkStmtList)
  for decl in decls:
    result.add makeSingleIvar(decl, classVariable)

proc makeClassVariable(class, super, decls: NimNode): NimNode =
  ## Creates an Objective-C runtime Class variable, tied
  ## to a Nim type of name `class`.
  let
    className = class.toStrLit
    theClass = gensym(nskVar)
    superName =
      if super.toStrLit.strVal == "nil":
        newStrLitNode("nil")
      else:
        super.toStrLit
    procName = ident"class"
    converterName = ident"dyn"
    classType = bindsym"Class"
    addAllIvars = makeClassIvars(decls, theClass)
  result = quote do:
    block:
      var `theClass` =
        when `superName` == "nil":
          newClass(Class(nil), `className`, 0)
        else:
          newClass(class(`superName`), `className`, 0) # FIXME
      `addAllIvars`
      `theClass`.register
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
  let
    (className, superName) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, decls)
    classVariable = makeClassVariable(className, superName, decls)
  return newTree(nnkStmtList, typeDecl, classVariable)

macro objectiveProtocol*(nameExpr: untyped, decls: untyped): untyped =
  ## Creates concepts, variables and procedures for an Objective-C
  ## protocol.
  discard

macro objectiveProperty*(nameExpr: untyped, procedure: untyped): untyped =
  ## Creates an Objective-C property for an Objective-C class,
  ## given a procedure implementing that property.
  discard

converter toProtocol*[T](x: T): int =
  ## Converts a concrete Objective-C class type to a protocol type
  ## it conforms to. TODO in macro.
  discard

when isMainModule:
  objectiveClass TestRoot:
    c: float
  objectiveClass Test of TestRoot:
    a: int

  echo encode(Test.classType)
