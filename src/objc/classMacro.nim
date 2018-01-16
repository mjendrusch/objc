import objc.base, objc.hli, objc.typeEncoding, objc.macroCommons, objc.methodCallMacro, objc.methodMacro
import macros

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
    classObject = ident($class.ident & "Obj")
    metaClassName = ident($class.ident & "MetaClass")
  if super.isNil:
    result = quote do:
      type
        `metaClassName`* = object of MetaClassType
        `className`* = object of ClassType
        `classObject`* = object of Object
        `class`* = ref `classObject`
      template classType*(typ: typedesc[`class`]): untyped = `className`
      template metaClassType*(typ: typedesc[`class`]): untyped = `metaClassName`
      template classType*(typ: `class`): untyped = `className`
      template metaClassType*(typ: `class`): untyped = `metaClassName`
  else:
    let
      superClassName = ident($super.ident & "Class")
      superMetaClassName = ident($super.ident & "MetaClass")
    result = quote do:
      type
        `metaClassName`* = object of `superMetaClassName`
        `className`* = object of `superClassName`
        `class`* = ref object of `super`
      template superClassType*(typ: typedesc[`class`]): untyped = `superClassName`
      template classType*(typ: typedesc[`class`]): untyped = `className`
      template metaClassType*(typ: typedesc[`class`]): untyped = `metaClassName`
      template superClassType*(typ: `class`): untyped = `superClassName`
      template classType*(typ: `class`): untyped = `className`
      template metaClassType*(typ: `class`): untyped = `metaClassName`
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

proc makeClassUtils*(className, superName: NimNode): NimNode =
  ## Creates utility templates, procedures and converters for a given class.
  let
    classProcName = ident"class"
    superProcName = ident"super"
    converterName = ident"dyn"
    classType = bindsym"Class"
    classString = className.toStrLit
    newClass = ident("new" & $className.ident)
  result = quote do:
    template `classProcName`*(cls: `className`): `classType` =
      class(`classString`)
    template `classProcName`*(clsType: typedesc[`className`]): `classType` =
      class(`classString`)
    template `superProcName`*(cls: `className`): `classType` =
      class(`classString`).super
    template `superProcName`*(clsType: typedesc[`className`]): `classType` =
      class(`classString`).super
    template `converterName`*(cls: `className`): Id = cls.id
    proc standardDispose(cls: `className`) =
      when defined(objcDebugAlloc):
        echo "RELEASED ", repr(cast[pointer](cls.id))
      discard objcMsgSend(cls.id, $$"release")
    proc `newClass`*: `className` =
      var res: `className`
      new res, standardDispose
      res.id = objcMsgSend(
        objcMsgSend(`className`.class.Id,
                    $$"alloc"),
        $$"init")
      when defined(objcDebugAlloc):
        echo "ALLOCATED ", `classString`, ": ", repr(cast[pointer](res.id))
      res
    proc `newClass`*(id: Id): `className` =
      var res: `className`
      new res, standardDispose
      res.id = id
      when defined(objcDebugAlloc):
        echo "RETAINED ", `classString`, ": ", repr(cast[pointer](res.id))
      discard objcMsgSend(id, $$"retain")
      res

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
    classUtilities = makeClassUtils(className, superName)
  result = newTree(nnkStmtList, typeDecl, classVariable, classUtilities)

macro objectiveClass*(nameExpr: untyped): untyped =
  ## Creates types, variables and procedures for an Objective-C
  ## class without member fields.
  let
    (className, superName) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, newEmptyNode())
    classVariable = makeClassVariable(className, superName, newEmptyNode())
    classUtilities = makeClassUtils(className, superName)
  result = newTree(nnkStmtList, typeDecl, classVariable, classUtilities)

macro importClass*(nameExpr: untyped, decls: untyped): untyped =
  ## Imports an existing Objective-C class and generates types for it.
  let
    (className, superName) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, decls)
    classUtilities = makeClassUtils(className, superName)
  result = newTree(nnkStmtList, typeDecl, classUtilities)

macro importClass*(nameExpr: untyped): untyped =
  ## Imports an existing Objective-C class and generates types for it.
  let
    (className, superName) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, newEmptyNode())
    classUtilities = makeClassUtils(className, superName)
  result = newTree(nnkStmtList, typeDecl, classUtilities)

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
