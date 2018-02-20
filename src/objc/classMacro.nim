import objc.base, objc.hli, objc.typeEncoding, objc.macroCommons, objc.methodCallMacro, objc.methodMacro
import macros

proc makeClassNames(nameExpr: NimNode): tuple[class, super, classArgs, superArgs: NimNode] =
  ## Gets identifiers for super class and new class from a
  ## class name expression.
  result.classArgs = newNimNode(nnkArgList)
  result.superArgs = newNimNode(nnkArgList)
  case nameExpr.kind
  of nnkInfix:
    let
      classExpr = nameExpr[1]
      superExpr = nameExpr[2]
    case classExpr.kind
    of nnkBracketExpr:
      result.class = classExpr[0]
      for idx in 1 ..< classExpr.len:
        result.classArgs.add classExpr[idx]
    of nnkIdent:
      result.class = classExpr
    else:
      error("Invalid objective-C class declaration. Class name is not identifier or bracket expression!")
    case superExpr.kind
    of nnkBracketExpr:
      result.super = superExpr[0]
      for idx in 1 ..< superExpr.len:
        result.superArgs.add superExpr[idx]
    of nnkIdent:
      result.super = superExpr
    else:
      error("Invalid Objective-C class declaration. Super class name is not identifier or bracket expression!")
  of nnkIdent:
    result.class = nameExpr
  of nnkBracketExpr:
    result.class = nameExpr[0]
    for idx in 1 ..< nameExpr.len:
      result.classArgs.add nameExpr[idx]
  else:
    error("Invalid Objective-C class declaration. Class is not identifier, bracket expression or infix expression!")

proc removeTypeQualifiers(arglist: NimNode): NimNode =
  ## Removes all type qualifier-like expressions from an arglist.
  proc recurse(node: NimNode): NimNode =
    if node.kind == nnkExprColonExpr:
      return node[0]
    result = node.copyNimNode
    for child in node.children:
      result.add recurse(child)
  result = recurse arglist

proc makeExplicitClassTypeDecl(class, super, decls: NimNode): NimNode =
  ## Generates type declarations for non-generic classes based on their
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

proc makeGenericClassTypeDecl(class, super,
                              classArgs, superArgs,
                              decls: NimNode): NimNode =
  ## Generates type declarations for generic classes.
  let
    rhsClassArgs = removeTypeQualifiers(classArgs)
    className = ident($class.ident & "Class")
    classGenericName = ident($class.ident & "Generic")
    classGenericClassName = ident($class.ident & "GenericClass")
    classGenericObjectName = ident($class.ident & "GenericObj")
    classObject = ident($class.ident & "Obj")
    metaClassName = ident($class.ident & "MetaClass")
  if super.isNil:
    result = quote do:
      type
        `metaClassName`* = object of MetaClassType
        `classGenericClassName`* = object of ClassType
        `className`*[`classArgs`] = object of `classGenericClassName`
        `classGenericObjectName`* = object of Object
        `classObject`*[`classArgs`] = object of `classGenericObjectName`
        `classGenericName`* = ref `classGenericObjectName`
        `class`*[`classArgs`] = ref `classObject`[`rhsClassArgs`]
      template classType*(typ: typedesc[`class`]): untyped = `classGenericName`
      template metaClassType*(typ: typedesc[`class`]): untyped = `metaClassName`
      template classType*(typ: `class`): untyped = `classGenericName`
      template metaClassType*(typ: `class`): untyped = `metaClassName`
  else:
    let
      rhsSuperArgs = removeTypeQualifiers(superArgs)
      superClassName = ident($super.ident & "Class")
      superGenericName = ident($super.ident & "Generic")
      superGenericClassName = ident($super.ident & "GenericClass")
      superMetaClassName = ident($super.ident & "MetaClass")
    result = quote do:
      type
        `metaClassName`* = object of `superMetaClassName`
        `classGenericClassName`* = object of `superGenericClassName`
        `className`*[`classArgs`] = object of `superClassName`[`rhsSuperArgs`]
        `classGenericName`* = ref object of `superGenericName`
        `class`*[`classArgs`] = ref object of `super`[`rhsSuperArgs`]
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

proc makeClassTypeDecl(class, super,
                       classArgs, superArgs,
                       decls: NimNode): NimNode =
  ## Creates type declarations for classes based on their
  ## name and the name of their superclass, if any.
  if classArgs.len == 0 and superArgs.len == 0:
    result = makeExplicitClassTypeDecl(class, super, decls)
  else:
    result = makeGenericClassTypeDecl(class, super, classArgs, superArgs, decls)

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
    template id*(cls: typedesc[`className`]): Id = Id(cls.class)
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
    (className, superName, classArgs, superArgs) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, classArgs, superArgs, decls)
    classVariable = makeClassVariable(className, superName, decls)
    classUtilities = makeClassUtils(className, superName)
  result = newTree(nnkStmtList, typeDecl, classVariable, classUtilities)

macro objectiveClass*(nameExpr: untyped): untyped =
  ## Creates types, variables and procedures for an Objective-C
  ## class without member fields.
  let
    (className, superName, classArgs, superArgs) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, classArgs, superArgs, newEmptyNode())
    classVariable = makeClassVariable(className, superName, newEmptyNode())
    classUtilities = makeClassUtils(className, superName)
  result = newTree(nnkStmtList, typeDecl, classVariable, classUtilities)

macro importClass*(nameExpr: untyped, decls: untyped): untyped =
  ## Imports an existing Objective-C class and generates types for it.
  let
    (className, superName, classArgs, superArgs) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, classArgs, superArgs, decls)
    classUtilities = makeClassUtils(className, superName)
  result = newTree(nnkStmtList, typeDecl, classUtilities)

macro importClass*(nameExpr: untyped): untyped =
  ## Imports an existing Objective-C class and generates types for it.
  let
    (className, superName, classArgs, superArgs) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, classArgs, superArgs, newEmptyNode())
    classUtilities = makeClassUtils(className, superName)
  result = newTree(nnkStmtList, typeDecl, classUtilities)
