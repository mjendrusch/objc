import objc / [base, hli, typeEncoding, macroCommons, methodCallMacro, methodMacro]
import macros, strutils

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
      error("Invalid objective-C class declaration. Class name is not identifier or bracket expression!", nameExpr)
    case superExpr.kind
    of nnkBracketExpr:
      result.super = superExpr[0]
      for idx in 1 ..< superExpr.len:
        result.superArgs.add superExpr[idx]
    of nnkIdent:
      result.super = superExpr
    else:
      error("Invalid Objective-C class declaration. Super class name is not identifier or bracket expression!", nameExpr)
  of nnkIdent:
    result.class = nameExpr
  of nnkBracketExpr:
    result.class = nameExpr[0]
    for idx in 1 ..< nameExpr.len:
      result.classArgs.add nameExpr[idx]
  else:
    error("Invalid Objective-C class declaration. Class is not identifier, bracket expression or infix expression!", nameExpr)

proc removeTypeQualifiers(arglist: NimNode): NimNode =
  ## Removes all type qualifier-like expressions from an arglist.
  proc recurse(node: NimNode): NimNode =
    if node.kind == nnkExprColonExpr:
      return node[0]
    result = node.copyNimNode
    for child in node.children:
      result.add recurse(child)
  result = recurse arglist

proc manualModeRefToPtr(node: NimNode): NimNode =
  ## Replaces every occurence of nnkRefTy with nnkPtrTy,
  ## every occurence of Ident "ref" with Ident "ptr".
  if node.kind == nnkRefTy:
    return newTree(nnkPtrTy, manualModeRefToPtr(node[0]))
  if node.kind == nnkIdent and node.eqIdent("ref"):
    return ident"ptr"
  result = node.copyNimNode
  for child in node:
    result.add manualModeRefToPtr(child)

proc makeGenericClassTypeDecl(class, super,
                              classArgs, superArgs,
                              decls: NimNode): NimNode =
  ## Generates type declarations for generic classes.
  let
    rhsClassArgs = removeTypeQualifiers(classArgs)
    className = ident($class & "Class")
    classGenericName = ident($class & "Any")
    classGenericClassName = ident($class & "AnyClass")
    classGenericObjectName = ident($class & "AnyObj")
    classObject = ident($class & "Obj")
    metaClassName = ident($class & "MetaClass")

  if super.isNil:
    if classArgs.len > 0:
      result = quote do:
        type
          `metaClassName`* = object of MetaClassType
          `classGenericClassName`* = object of ClassType
          `className`*[`classArgs`] = object of `classGenericClassName`
          `classGenericObjectName`* = object of Object
          `classObject`*[`classArgs`] = object of `classGenericObjectName`
          `classGenericName`* = ref `classGenericObjectName`
          `class`*[`classArgs`] = ref `classObject`[`rhsClassArgs`]
        template genericType*(typ: typedesc[`class`]): untyped = `classGenericName`
        template genericType*(typ: `class`): untyped = `classGenericName`
        template classType*(typ: typedesc[`class`]): untyped = `classGenericClassName`
        template metaClassType*(typ: typedesc[`class`]): untyped = `metaClassName`
        template classType*(typ: `class`): untyped = `classGenericClassName`
        template metaClassType*(typ: `class`): untyped = `metaClassName`
    else:
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
      rhsSuperArgs = removeTypeQualifiers(superArgs)
      superClassName = ident($super & "Class")
      superGenericName = ident($super & "Any")
      superGenericClassName = ident($super & "AnyClass")
      superMetaClassName = ident($super & "MetaClass")
    if superArgs.len > 0 and classArgs.len > 0:
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
        template genericType*(typ: typedesc[`class`]): untyped = `classGenericName`
        template genericType*(typ: `class`): untyped = `classGenericName`
    elif superArgs.len > 0:
      result = quote do:
        type
          `metaClassName`* = object of `superMetaClassName`
          `className`* = object of `superClassName`[`rhsSuperArgs`]
          `class`* = ref object of `super`[`rhsSuperArgs`]
        template superClassType*(typ: typedesc[`class`]): untyped = `superClassName`
        template classType*(typ: typedesc[`class`]): untyped = `className`
        template metaClassType*(typ: typedesc[`class`]): untyped = `metaClassName`
        template superClassType*(typ: `class`): untyped = `superClassName`
        template classType*(typ: `class`): untyped = `className`
        template metaClassType*(typ: `class`): untyped = `metaClassName`
    elif classArgs.len > 0:
      result = quote do:
        type
          `metaClassName`* = object of `superMetaClassName`
          `classGenericClassName`* = object of `superClassName`
          `className`*[`classArgs`] = object of `classGenericClassName`
          `classGenericName`* = ref object of `super`
          `class`*[`classArgs`] = ref object of `classGenericName`
        template superClassType*(typ: typedesc[`class`]): untyped = `superClassName`
        template classType*(typ: typedesc[`class`]): untyped = `className`
        template metaClassType*(typ: typedesc[`class`]): untyped = `metaClassName`
        template superClassType*(typ: `class`): untyped = `superClassName`
        template classType*(typ: `class`): untyped = `className`
        template metaClassType*(typ: `class`): untyped = `metaClassName`
        template genericType*(typ: typedesc[`class`]): untyped = `classGenericName`
        template genericType*(typ: `class`): untyped = `classGenericName`
    else:
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
  when defined(manualMode):
    result = manualModeRefToPtr(result)
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

macro makeSingleIvarMacro(classVariable, name, typ: typed): untyped =
  let
    ivarName = name
    ivarType =
      if (typ.getImpl)[2].isObject:
        ident"Id"
      else:
        typ
    alignmentProc = bindsym"alignment"
    encodeMacro = bindsym"encode"
  result = quote do:
    discard `classVariable`.addIvar(`ivarName`, sizeof(`ivarType`),
                                    `alignmentProc`(`ivarType`),
                                    $`encodeMacro`(`typ`))

proc makeSingleIvar(decl: NimNode; classVariable: NimNode): NimNode =
  ## Creates an Objective-C runtime call adding an Ivar corresponding to
  ## ``decl`` to the class ``class``.
  let
    ivarName = decl[0].toStrLit
    ivarType = decl[1][0]
    ivarMacro = bindsym"makeSingleIvarMacro"
  result = quote do:
    `ivarMacro`(`classVariable`, `ivarName`, `ivarType`)

proc makeClassIvars(decls: NimNode; classVariable: NimNode): NimNode =
  ## Creates the Objective-C runtime calls necessary to bind Ivars corresponding
  ## to the field declarations in decls to an Objective-C class object.
  result = newNimNode(nnkStmtList)
  for decl in decls:
    result.add makeSingleIvar(decl, classVariable)

macro makeSinglePropertyMacro(className, name, typ: typed): untyped =
  let
    classVariable = newTree(nnkCall,
      ident"class",
      className)
    ivarName = name
    ivarEqName = "set" & toUpperAscii($ivarName) & ":"
    ivarIdent = ident($name)
    ivarEqIdent = ident($name & "=")
    encodeMacro = bindsym"encode"
    self = ident"self"
    value = ident"val"
  if (typ.getImpl)[2].isObject:
    let
      entryType = bindsym"Id"
      exitType = typ
      newTypName = ident("new" & $typ)
    result = quote do:
      var
        attrs = [
          PropertyAttribute(name: "T", value: `encodeMacro`(`exitType`)),
          PropertyAttribute(name: "V", value: `ivarName`)
        ]
      nslog("ADDED PROPERTY? " & $`classVariable`.addProperty(`ivarName`, attrs))
      proc `ivarIdent`*(`self`: `className`): `exitType` {. objectiveSelector: `ivarName` .} =
        var
          resultPtr = `self`.id.getInstanceVariablePointer(`ivarName`)
          resultId = cast[ptr `entryType`](resultPtr)[]
        nslog("RESULT ID: " & $cast[int](resultId))
        `newTypName`(resultId)
      proc `ivarEqIdent`*(`self`: `className`; `value`: `exitType`): void {. objectiveSelector: `ivarEqName` .} =
        var
          resultPtr =  `self`.id.getInstanceVariablePointer(`ivarName`)
        nslog("VALUE ID: " & $cast[int](`value`.id))
        cast[ptr `entryType`](resultPtr)[] = `value`.id
  else:
    let
      ivarType = typ
    result = quote do:
      var
        attrs = [
          PropertyAttribute(name: "T", value: `encodeMacro`(`ivarType`)),
          PropertyAttribute(name: "V", value: `ivarName`)
        ]
      discard `classVariable`.addProperty(`ivarName`, attrs)
      proc `ivarIdent`*(`self`: `className`): `ivarType` {. objectiveSelector: `ivarName` .} =
        var
          resultPtr = `self`.id.getInstanceVariablePointer(`ivarName`)
        nslog("OH FUCK NO! " & $`ivarName`)
        cast[ptr `ivarType`](resultPtr)[]
      proc `ivarEqIdent`*(`self`: `className`; `value`: `ivarType`): void {. objectiveSelector: `ivarEqName` .} =
        var
          resultPtr =  `self`.id.getInstanceVariablePointer(`ivarName`)
        cast[ptr `ivarType`](resultPtr)[] = `value`
    

proc makeSingleProperty(className, decl: NimNode): NimNode =
  let
    ivarName = decl[0].toStrLit
    ivarType = decl[1][0]
    propertyMacro = bindsym"makeSinglePropertyMacro"
  result = quote do:
    `propertyMacro`(`className`, `ivarName`, `ivarType`)
    
proc makeClassProperties(className, decls: NimNode): NimNode =
  ## Adds properties corresponding to all Ivars in a class.
  result = newNimNode(nnkStmtList)
  for decl in decls:
    result.add makeSingleProperty(className, decl)

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
      # discard `theClass`.addProtocol(protocol("UIApplicationDelegate"))
      `theClass`.register

proc makeSuperTemplates*(className, superName: NimNode): NimNode =
  ## Creates templates to access the superclass type of a class type.
  let
    superProcName = ident"super"
    classType = bindsym"Class"
    classString = className.toStrLit
  result = quote do:
    template `superProcName`*(cls: `className`): `classType` =
      class(`classString`).super
    template `superProcName`*(clsType: typedesc[`className`]): `classType` =
      class(`classString`).super

proc makeClassUtils*(className, classArgs: NimNode): NimNode =
  ## Creates utility templates, procedures and converters for a given class.
  let
    classProcName = ident"class"
    metaClassProcName = ident"metaClass"
    converterName = ident"dyn"
    classType = bindsym"Class"
    classString = className.toStrLit
    newClass = ident("new" & $className)
    newClassClass = ident("new" & $className & "Class")
    newClassMetaClass = ident("new" & $className & "MetaClass")
    classClassName = ident($className & "Class")
    classMetaClassName = ident($className & "MetaClass")

  if classArgs.len == 0:
    result = quote do:
      template `classProcName`*(cls: `className`): `classType` =
        class(`classString`)
      template `classProcName`*(clsType: typedesc[`className`]): `classType` =
        class(`classString`)
      template `metaClassProcName`*(cls: `className`): `classType` =
        metaClass(`classString`)
      template `metaClassProcName`*(cls: typedesc[`className`]): `classType` =
        metaClass(`classString`)
      template id*(cls: typedesc[`className`]): Id = Id(cls.class)
      template metaId*(cls: typedesc[`className`]): Id = Id(cls.metaClass)
      template `converterName`*(cls: `className`): Id = cls.id
      proc standardDispose(cls: `className`) =
        when defined(objcDebugAlloc):
          echo "RELEASED ", repr(cast[pointer](cls.id))
        discard objcMsgSend(cls.id, $$"release")
      proc `newClass`*: `className` =
        var res: `className`
        when not defined(manualMode):
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
        when not defined(manualMode):
          new res, standardDispose
        res.id = id
        when defined(objcDebugAlloc):
          echo "RETAINED ", `classString`, ": ", repr(cast[pointer](res.id))
        discard objcMsgSend(id, $$"retain")
        res
      proc `newClassClass`*(class: Class): `classClassName` =
        `classClassName`(class: class)
      proc `newClassMetaClass`*(class: Class): `classMetaClassName` =
        `classMetaClassName`(class: class)
      proc `newClassClass`*(class: Id): `classClassName` =
        `classClassName`(class: Class(class))
      proc `newClassMetaClass`*(class: Id): `classMetaClassName` =
        `classMetaClassName`(class: Class(class))
  else:
    let
      classNameGeneric = ident($className & "Any")
      newClassGeneric = ident("new" & $className & "Any")
    result = quote do:
      template `classProcName`*(cls: `classNameGeneric`): `classType` =
        class(`classString`)
      template `classProcName`*(clsType: typedesc[`classNameGeneric`]): `classType` =
        class(`classString`)
      template `metaClassProcName`*(cls: `classNameGeneric`): `classType` =
        metaClass(`classString`)
      template `metaClassProcName`*(cls: typedesc[`classNameGeneric`]): `classType` =
        metaClass(`classString`)
      template id*(cls: typedesc[`classNameGeneric`]): Id = Id(cls.class)
      template metaId*(cls: typedesc[`classNameGeneric`]): Id = Id(cls.metaClass)
      template `converterName`*(cls: `className`): Id = cls.id
      proc standardDispose[`classArgs`](cls: `className`[`classArgs`]) =
        when defined(objcDebugAlloc):
          echo "RELEASED ", repr(cast[pointer](cls.id))
        discard objcMsgSend(cls.id, $$"release")
      proc standardDispose(cls: `classNameGeneric`) =
        when defined(objcDebugAlloc):
          echo "RELEASED ", repr(cast[pointer](cls.id))
        discard objcMsgSend(cls.id, $$"release")
      proc `newClass`*[`classArgs`]: `className`[`classArgs`] =
        var res: `className`[`classArgs`]
        when not defined(manualMode):
          new res, standardDispose[`classArgs`]
        res.id = objcMsgSend(
          objcMsgSend(`classString`.class.Id,
                      $$"alloc"),
          $$"init")
        when defined(objcDebugAlloc):
          echo "ALLOCATED ", `classString`, ": ", repr(cast[pointer](res.id))
        res
      proc `newClass`*[`classArgs`](id: Id): `className`[`classArgs`] =
        var res: `className`[`classArgs`]
        when not defined(manualMode):
          new res, standardDispose[`classArgs`]
        res.id = id
        when defined(objcDebugAlloc):
          echo "RETAINED ", `classString`, ": ", repr(cast[pointer](res.id))
        discard objcMsgSend(id, $$"retain")
        res
      proc `newClassGeneric`*: `classNameGeneric` =
        var res: `classNameGeneric`
        when not defined(manualMode):
          new res, standardDispose
        res.id = objcMsgSend(
          objcMsgSend(`classString`.class.Id,
                      $$"alloc"),
          $$"init")
        when defined(objcDebugAlloc):
          echo "ALLOCATED ", `classString`, ": ", repr(cast[pointer](res.id))
        res
      proc `newClassGeneric`*(id: Id): `classNameGeneric` =
        var res: `classNameGeneric`
        when not defined(manualMode):
          new res, standardDispose
        res.id = id
        when defined(objcDebugAlloc):
          echo "RETAINED ", `classString`, ": ", repr(cast[pointer](res.id))
        discard objcMsgSend(id, $$"retain")
        res
  result = result.copyNimTree

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
    classUtilities = makeClassUtils(className, classArgs)
    classProperties = makeClassProperties(className, decls)
    superTemplates = makeSuperTemplates(className, superName)
  result = newTree(nnkStmtList,
    typeDecl,
    classVariable,
    classUtilities,
    classProperties,
    superTemplates
  )

macro objectiveClass*(nameExpr: untyped): untyped =
  ## Creates types, variables and procedures for an Objective-C
  ## class without member fields.
  let
    (className, superName, classArgs, superArgs) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, classArgs, superArgs, newEmptyNode())
    classVariable = makeClassVariable(className, superName, newEmptyNode())
    classUtilities = makeClassUtils(className, classArgs)
    superTemplates = makeSuperTemplates(className, superName)
  result = newTree(nnkStmtList,
    typeDecl,
    classVariable,
    classUtilities,
    superTemplates
  )

macro importClass*(nameExpr: untyped, decls: untyped): untyped =
  ## Imports an existing Objective-C class and generates types for it.
  let
    (className, superName, classArgs, superArgs) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, classArgs, superArgs, decls)
    classUtilities = makeClassUtils(className, classArgs)
    superTemplates = makeSuperTemplates(className, superName)
  result = newTree(nnkStmtList,
    typeDecl,
    classUtilities,
    superTemplates
  )

macro importClass*(nameExpr: untyped): untyped =
  ## Imports an existing Objective-C class and generates types for it.
  let
    (className, superName, classArgs, superArgs) = makeClassNames(nameExpr)
    typeDecl = makeClassTypeDecl(className, superName, classArgs, superArgs, newEmptyNode())
    classUtilities = makeClassUtils(className, classArgs)
    superTemplates = makeSuperTemplates(className, superName)
  result = newTree(nnkStmtList,
    typeDecl,
    classUtilities,
    superTemplates
  )
