import objc / [base, macroCommons, typeEncoding]
import macros

proc genMethodArgTypes*(procedure: NimNode): seq[NimNode] =
  ## Generates a sequence of argument types for an Objective-C method.
  var
    args = procedure[3]
  result = newSeq[NimNode]()
  for idx in 2 ..< args.len:
    let
      identDef = args[idx]
      defType = identDef[^2]
      defLen = identDef.len - 2
    for idy in 0 ..< defLen:
      result.add defType

proc mangleMethodSelector*(name: string; types: seq[NimNode]): string =
  ## Mangles a procedure name given a list of types, to create an easily
  ## reproducible, yet overloadable method selector.
  result = name
  for typ in types:
    result.add ":" & $toStrLit(typ)

proc mangleMethodSelector*(procedure: NimNode): NimNode =
  ## Mangles a procedure name to produce an easily reproducible,
  ## yet overloadable method selector.
  var
    types = genMethodArgTypes(procedure)
    mangledName = $procedure[0]
  result = newStrLitNode(mangleMethodSelector(mangledName, types))

proc genMethodSelector(procedure: NimNode; name: string = nil): NimNode =
  ## Generates a unique selector name for a procedure, given its arguments.
  let
    mangledSelector = gensym(nskProc)
    symbolString =
      if name.len == 0:
        mangleMethodSelector(procedure)
      else:
        newStrLitNode(name)
  result = quote do:
    proc `mangledSelector`: string {. inline .} =
      var res {. exportc .} = cstring""
      {. emit: ["res = \"", `symbolString`, "\";"] .}
      $res
    `mangledSelector`()

proc genMethodPrototype*(procedure: NimNode): NimNode =
  ## Generates a prototype for a procedure, such that it is correctly
  ## encodable for the Objective-C runtime.
  let
    symbol = procedure[0]
    args = procedure[3]
  var
    newArgs = newTree(nnkFormalParams,
    procedure[3][0],
    newTree(nnkIdentDefs,
      ident"self",
      bindsym"Id",
      newEmptyNode()),
    newTree(nnkIdentDefs,
      ident"selector",
      bindsym"Selector",
      newEmptyNode()))
  for idx in 2 ..< args.len:
    let identDef = args[idx]
    newArgs.add identDef.copyNimTree

  result = newTree(nnkProcDef,
    symbol,
    newEmptyNode(),
    newEmptyNode(),
    newArgs,
    newTree(nnkPragma, ident"cdecl"),
    newEmptyNode(),
    newEmptyNode())

  if not args[0].eqIdent "void":
    if args[0].getTypeImpl.isObject:
      result[3][0] = bindsym"Id"

proc genInstanceMethodProc(procedure, name: NimNode): NimNode =
  ## Generates a wrapper for a procedure, such that this wrapper can be used
  ## to attach the given procedure to a class, as an instance method.
  ## TODO: make this work with generics.
  let
    symbol = procedure[0]
    selfType = procedure[3][1][^2]
    newCallName = ident("new" & $selfType)

  var
    call = newTree(nnkCall, symbol, quote do:
      `newCallName`(self))
  let args = procedure[3]
  for idx in 2 ..< args.len:
    let identDef = args[idx]
    for idy in 0 ..< identDef.len - 2:
      let arg = identDef[idy]
      call.add arg
  result = genMethodPrototype(procedure)
  result.name = name
  if not args[0].eqIdent "void":
    if args[0].getTypeImpl.isObject:
      result[6] = newTree(nnkStmtList,
        newTree(nnkAsgn,
          ident"result",
          quote do:
            `call`.id
        )
      )
    else:
      result[6] = newTree(nnkStmtList,
        newTree(nnkAsgn, ident"result", call))
  else:
    result[6] = newTree(nnkStmtList,
      call)
  result = result.copyNimTree

proc genClassMethodProc(procedure, name: NimNode): NimNode =
  ## Generates a wrapper for a procedure, such that this wrapper can be used
  ## to attach the given procedure to a class, as a class method.
  let
    symbol = procedure[0]
    selfClassType = procedure[3][1][^2]
    selfType = ident $selfClassType[1]
    newCallName = ident("new" & $selfType & "Class")

  var
    call = newTree(nnkCall, symbol, quote do:
      `selfType`)
  let args = procedure[3]
  for idx in 2 ..< args.len:
    let identDef = args[idx]
    for idy in 0 ..< identDef.len - 2:
      let arg = identDef[idy]
      call.add arg
  result = genMethodPrototype(procedure)
  result.name = name
  if not args[0].eqIdent "void":
    if args[0].getTypeImpl.isObject:
      result[6] = newTree(nnkStmtList,
        newTree(nnkAsgn,
          ident"result",
          quote do:
            `call`.id
        )
      )
    else:
      result[6] = newTree(nnkStmtList,
        newTree(nnkAsgn, ident"result", call))
  result = result.copyNimTree

proc prototypeIsClass*(prototype: NimNode): bool =
  ## Checks, whether a given method prototype indicates a class method.
  let
    selfType = prototype[3][1][^2]
  selfType.kind == nnkBracketExpr and selfType[0].eqIdent("typedesc")

proc genMethodProc(procedure, name: NimNode): tuple[procedure: NimNode; isClass: bool] =
  ## Generates a wrapper for a procedure, such that this wrapper can be used
  ## to attach the given procedure to a class, as an instance method or
  ## class method.
  if prototypeIsClass(procedure):
    result.procedure = genClassMethodProc(procedure, name)
    result.isClass = true
  else:
    result.procedure = genInstanceMethodProc(procedure, name)
    result.isClass = false

# macro objectiveMethod*(importString: typed; procedure: typed): untyped =
#   ## Adds a procedure to an Objective-C runtime class.
#   let
#     class = procedure[3][1][^2]
#     procName = gensym(nskProc)
#     methodProcedure = genMethodProc(procedure, procName)
#     methodSelector = genMethodSelector(procedure, importString.strVal)
#     encoding = genProcEncoding(methodProcedure)
#     implementation = bindsym"Implementation"
#   result = quote do:
#     `methodProcedure`
#     discard addMethod(`class`.class, $$`methodSelector`,
#                       cast[`implementation`](`procName`),
#                       `encoding`)

macro objectiveMethod*(procedure: typed): untyped =
  ## Adds a procedure to an Objective-C runtime class.
  let
    class = procedure[3][1][^2]
    procName = gensym(nskProc)
    (methodProcedure, isClass) = genMethodProc(procedure, procName)
    methodSelector = genMethodSelector(procedure, nil)
    encoding = genProcEncoding(methodProcedure)
    implementation = bindsym"Implementation"

  if isClass:
    result = quote do:
      `methodProcedure`
      discard addMethod(`class`.metaClass, $$`methodSelector`,
                        cast[`implementation`](`procName`),
                        `encoding`)
  else:
    result = quote do:
      `methodProcedure`
      discard addMethod(`class`.class, $$`methodSelector`,
                        cast[`implementation`](`procName`),
                        `encoding`)
  result = result.copyNimTree

macro objectiveSelector*(str: typed; procedure: typed): untyped =
  ## Adds a procedure to an Objective-C runtime class.
  let
    class = procedure[3][1][^2]
    procName = gensym(nskProc)
    (methodProcedure, isClass) = genMethodProc(procedure, procName)
    methodSelector = str#genMethodSelector(procedure, nil)
    encoding = genProcEncoding(methodProcedure)
    implementation = bindsym"Implementation"

  if isClass:
    result = quote do:
      `methodProcedure`
      discard addMethod(`class`.metaClass, $$`methodSelector`,
                        cast[`implementation`](`procName`),
                        `encoding`)
  else:
    result = quote do:
      `methodProcedure`
      discard addMethod(`class`.class, $$`methodSelector`,
                        cast[`implementation`](`procName`),
                        `encoding`)
  result = result.copyNimTree

proc makeImportMethodCallArgs*(args: NimNode; isSuper: bool = false): tuple[args, types: NimNode] =
  ## Creates the call arguments for the static method call of an imported
  ## method.
  result.args = newTree(nnkArgList)
  result.types = newTree(nnkArgList)
  if isSuper:
    result.types.add newTree(nnkIdentDefs,
      ident"self",
      newTree(nnkPtrTy, bindsym"Super"),
      newEmptyNode())
  else:
    result.types.add newTree(nnkIdentDefs, ident"self", bindsym"Id", newEmptyNode())
  result.types.add newTree(nnkIdentDefs, ident"sel", bindsym"Selector", newEmptyNode())
  for idx in 2 ..< args.len:
    let
      identDef = args[idx]
      defType = identDef[^2]
      isAnObject = defType.getTypeImpl.isObject
      isAClass = defType.getTypeImpl.isClass
    for idy in 0 ..< identDef.len - 2:
      let
        param = gensym(nskParam, "arg//" & $idx & "//" & $idy)
        identifier = identDef[idy]
        callArg =
          if isAnObject:
            newTree(nnkDotExpr, identifier, ident"id")
          elif isAClass:
            newTree(nnkDotExpr, identifier, ident"class") # FIXME
          else:
            identifier
        argType =
          if isAnObject:
            newTree(nnkIdentDefs, param, ident"Id", newEmptyNode())
          elif isAClass:
            newTree(nnkIdentDefs, param, ident"Class", newEmptyNode())
          else:
            newTree(nnkIdentDefs, param, defType, newEmptyNode())
      result.args.add callArg
      result.types.add argType
  result.args = result.args.copyNimTree
  result.types = result.types.copyNimTree

template stretInsanity(typ: untyped; size: int; isSuper: static[bool]): untyped =
  when isSuper:
    if sizeof(typ) <= size:
      cast[pointer](objcMsgSendSuper)
    else:
      cast[pointer](objcMsgSendSuperStret)
  else:
    if sizeof(typ) <= size:
      cast[pointer](objcMsgSend)
    else:
      cast[pointer](objcMsgSendStret)

proc detype(x: NimNode): NimNode =
  ## Strips all nkSym nodes from a Nim tree.
  if x.kind == nnkSym:
    return ident($x)
  result = x.copyNimNode
  for child in x.children:
    result.add detype child

proc sanitizeProcParams(procedure: NimNode): NimNode =
  ## Strips Symbols from procedure parameters, to resolve symbol
  ## conflicts arising from typed ASTs.

  result = procedure.copyNimTree
  for idx in 0 ..< procedure.params.len:
    let
      param = procedure.params[idx]
    result[3][idx] = detype(param)
  result = result.copyNimTree

# proc goodGenericParams(genericSyms, genericIdents: NimNode): NimNode =
#   ## Extracts non-generated generic params from an untyped list of generic
#   ## identifiers and a typed list of generic symbols.
#   result = newNimNode(nnkGenericParams)
#   for param in genericSyms:
#     block identLoop:
#       for def in genericIdents:
#         for idx in 0 ..< def.len - 2:
#           let
#             identifier = def[idx]
#           if param.eqIdent($identifier.ident):
#             result.add param
#             break identLoop

proc sanitizeGenericArgs(procedure: NimNode): NimNode =
  ## Removes compiler-breaking typed-stage generic type symbols from
  ## nkGenericArgs nodes for macro consumption.
  # let
  #   genericSymbols = procedure[2]
  if procedure[0].kind == nnkSym:
    result = procedure.copyNimTree
    if result[5].kind == nnkBracket:
      result[2] = result[5][^1]
      result[5] = newEmptyNode()
      error("Generic method import is supported via `genericMethod`.", procedure)
    else:
      result[2] = newEmptyNode()
  else:
    result = procedure
    error("INTERNAL ERROR: expected typed AST. The received node is not typed.", procedure)
  result = result.copyNimTree

proc makeProcedurePointerType(returnType, callArgTypes, args: NimNode): NimNode =
  ## Constructs the type an objc_msgSend procedure pointer should be cast to,
  ## given the destructured ``FormalParams`` node of a given procedure signature
  ## to be imported or defined as a method.
  # var res: tuple[vaNode, typ: NimNode]
  result = newTree(nnkProcTy)
  var
    formalParams = newTree(nnkFormalParams, returnType)
    pragmas = newTree(nnkPragma, ident"cdecl")
  for idx in 1 ..< args.len:
    let
      arg = args[idx]
      typ = arg[^2]
    if typ.kind == nnkBracketExpr and typ[0].kind in {nnkIdent, nnkSym} and
       typ[0].eqIdent "varargs":
      error("Varargs arguments to methods are currently not supported!", args)
  for idx in 0 ..< callArgTypes.len:
    let
      argType = callArgTypes[idx]
    formalParams.add argType
  if returnType.getTypeImpl.isObject:
    formalParams[0] = bindsym"Id"
  result.add formalParams
  result.add pragmas
  result = result.copyNimTree

## TODO: find another way to automatically wrap variadic methods.
# macro resolveVarArgsInProc(typ: typed; varArgSize: static[int]): untyped =
#   ## Resolves a vararg argument inside a procedure or a procedure type.
#   let
#     args = typ[0]
#     returnType = args[0]
#   var
#     formalParams = newTree(nnkFormalParams, returnType)
#   result = newTree(nnkProcTy)
#   for idx in 1 ..< args.len:
#     let
#       arg = args[idx]
#       argType = arg[^2]
#     if argType.kind == nnkBracketExpr and argType[0].eqIdent "varargs":
#       let
#         varArgType = argType[0].copyNimTree
#       for idx in 0 ..< varArgSize:
#         let
#           varArgNSym = gensym(nskParam, "varArg" & $idx)
#           varArg = newTree(nnkIdentDefs,
#             varArgNSym,
#             varArgType,
#             newEmptyNode())
#         formalParams.add varArg
#     else:
#       formalParams.add arg.copyNimTree
#   result.add formalParams
#   result.add newTree(nnkPragma, ident"cdecl")

proc genConstructorName(typ: NimNode): tuple[name, args: NimNode] =
  ## Generates the identifier for a type's constructor based on that type's
  ## name and generic parameters.
  result.args = newEmptyNode()
  case typ.kind
  of nnkSym, nnkIdent:
    result.name = ident("new" & $typ)
  of nnkBracketExpr:
    if typ[0].kind notin {nnkSym, nnkIdent}:
      error("Unsupported return type is not identifier or generic", typ)
    result.name = ident("new" & $typ[0])
    result.args = newTree(nnkArgList)
    for idx in 1 ..< typ.len:
      result.args.add typ[idx].copyNimTree
  else:
    error("Internal error genConstructorName: this should be impossible. Please file an issue on GitHub.")
  result.name = result.name.copyNimTree
  result.args = result.args.copyNimTree

proc importStandardImpl(messageName: string; typedProcedure: NimNode; isSuper: bool = false): NimNode =
  ## Implements Objective-C runtime method import.
  let
    procedure = sanitizeGenericArgs(typedProcedure)
    msgSend =
      if isSuper:
        bindsym"objcMsgSendSuper"
      else:
        bindsym"objcMsgSend"
    msgSendFloat =
      if isSuper:
        bindsym"objcMsgSendSuper"
      else:
        bindsym"objcMsgSendFpRet"
    msgSendStruct =
      if isSuper:
        bindsym"objcMsgSendSuperStret"
      else:
        bindsym"objcMsgSendStret"
    args = procedure[3]
    self = newTree(nnkDotExpr,
      args[1][0].copyNimTree,
      ident"id")
    returnType = args[0]
    returnTypeImpl = returnType.getTypeImpl
    (callArgs, callArgTypes) = makeImportMethodCallArgs(args, isSuper = isSuper)
    castType = makeProcedurePointerType(returnType, callArgTypes, args)
  result = procedure.copyNimTree

  if returnType == bindsym"void":
    result[6] = quote do:
      discard `msgSend`(`self`, $$`messageName`, `callArgs`)
  elif returnType == bindsym"float" or returnType == bindsym"float32" or
       returnType == bindsym"float64":
    let
      funp = gensym(nskLet)
    result[6] = quote do:
      let `funp` = cast[`castType`](`msgSendFloat`)
      return `funp`(`self`, $$`messageName`, `callArgs`)
  elif returnType.typeKind in {ntyTuple, ntyObject}:
    # XXX: this is insane!
    # We are choosing whether to use objcMsgSend or objcMsgSendStret, depending
    # on the target architecture and object size.
    var
      whichMsgSend = msgSendStruct
      stretTemplate = bindsym"stretInsanity"
    case hostCPU
    of "amd64", "powerpc64", "arm64":
      whichMsgSend = quote do:
        `stretTemplate`(`returnType`, 16, bool `isSuper`)
    of "i386":
      whichMsgSend = quote do:
        `stretTemplate`(`returnType`, 8, bool `isSuper`)
    of "powerpc":
      whichMsgSend = quote do:
        `stretTemplate`(`returnType`, 0, bool `isSuper`)
    of "arm":
      whichMsgSend = quote do:
        `stretTemplate`(`returnType`, 4, bool `isSuper`)
    else:
      discard
    let
      funp = gensym(nskLet)
    result[6] = quote do:
      let `funp` = cast[`castType`](`whichMsgSend`)
      return `funp`(`self`, $$`messageName`, `callArgs`)
  elif returnTypeImpl.isObject:
    let
      typ = returnType.getTypeInst
      (newResult, args) = genConstructorName(typ)#ident("new" & $typ.symbol)
      funp = gensym(nskLet)
    if args.kind == nnkEmpty:
      result[6] = quote do:
        let `funp` = `msgSend`
        `newResult`(`funp`(`self`, $$`messageName`, `callArgs`))
    else:
      result[6] = quote do:
        let `funp` = `msgSend`
        `newResult`[`args`](`funp`(`self`, $$`messageName`, `callArgs`))
  else:
    let
      funp = gensym(nskLet)
    result[6] = quote do:
      let `funp` = cast[`castType`](`msgSend`)
      return `funp`(`self`, $$`messageName`, `callArgs`)
  result = sanitizeProcParams(result)
  result = result.copyNimTree

proc importSuperImpl(messageName: string; typedProcedure: NimNode;
                     shouldExport: bool): NimNode =
  ## Implements Objective-C runtime superclass method import.
  var
    newProcedure = typedProcedure.copyNimTree
    selfType = newProcedure[3][1][^2]
  if selfType.kind == nnkBracketExpr and selfType[0].eqIdent("typedesc"):
    return newTree(nnkDiscardStmt, newEmptyNode())
  newProcedure[3][1][^2] = newTree(nnkBracketExpr,
    ident"AsSuper",
    typedProcedure[3][1][^2])
  result = importStandardImpl(messageName, newProcedure, isSuper = true)
  if shouldExport:
    result[0] = newTree(nnkPostfix, ident"*", ident($newProcedure[0]))
  else:
    result[0] = ident($newProcedure[0])
    result.addPragma(ident"used")

proc importMethodImpl(messageName: string; typedProcedure: NimNode;
                      shouldExport: bool;
                      isSuper: bool = false;
                      isSelf: bool = true): NimNode =
  ## Implements Objective-C runtime method import.
  result = newTree(nnkStmtList)
  if isSuper:
    let
      super = importSuperImpl(messageName, typedProcedure, shouldExport)
    result.add super
  if isSelf:
    let
      self = importStandardImpl(messageName, typedProcedure)
    result.add self
  echo toStrLit result

macro importSuperTyped(messageName: static[string]; procedure: typed;
                        shouldExport: static[bool]): untyped =
  ## Creates Objective-C bindings for a procedure prototype.
  result = importMethodImpl(messageName, procedure, shouldExport,
                            isSuper = true, isSelf = false)

macro importMethodTyped(messageName: static[string]; procedure: typed;
                        shouldExport: static[bool]): untyped =
  ## Creates Objective-C bindings for a procedure prototype.
  result = importMethodImpl(messageName, procedure, shouldExport,
                            isSuper = true)

macro importMethodNoSuperTyped(messageName: static[string]; procedure: typed;
                               shouldExport: static[bool]): untyped =
  ## Creates Objective-C bindings for a procedure prototype.
  result = importMethodImpl(messageName, procedure, shouldExport,
                            isSuper = false)

macro importMethodAutoTyped(procedure: typed; shouldExport: static[bool]): untyped =
  ## Creates Objective-C bindings for a procedure prototype.
  let
    messageName = $procedure[0]
  result = importMethodImpl(messageName, procedure, shouldExport,
                            isSuper = true)
  result = result.copyNimTree

macro importMangleTyped(messageName: static[string]; procedure: typed;
                    shouldExport: static[bool]): untyped =
  ## Creates Objective-C bindings for a procedure prototype, automatically
  ## mangling the message name.
  let
    mangledName = mangleMethodSelector(messageName,
                                       genMethodArgTypes(procedure))
  result = importMethodImpl(mangledName, procedure, shouldExport,
                            isSuper = true)
  result = result.copyNimTree

macro importMangleAutoTyped(procedure: typed; shouldExport: static[bool]): untyped =
  ## Creates Objective-C bindings for a procedure prototype, automatically
  ## mangling the message name.
  let
    messageName = $procedure[0]
    mangledName = mangleMethodSelector(messageName,
                                       genMethodArgTypes(procedure))
  result = importMethodImpl(mangledName, procedure, shouldExport,
                            isSuper = true)
  result = result.copyNimTree

macro importMangleAutoNoSuperTyped(procedure: typed; shouldExport: static[bool]): untyped =
  ## Creates Objective-C bindings for a procedure prototype, automatically
  ## mangling the message name.
  let
    messageName = $procedure[0]
    mangledName = mangleMethodSelector(messageName,
                                       genMethodArgTypes(procedure))
  result = importMethodImpl(mangledName, procedure, shouldExport,
                            isSuper = false)
  result = result.copyNimTree

template createImportMethod(name: untyped, selector: static[string]): untyped =
  macro `name`*(messageName, procedure: untyped): untyped =
    let
      shouldExport = procedure[0].kind == nnkPostfix
      typedName = bindsym(selector)
    result = newTree(nnkCall,
      typedName,
      messageName,
      procedure,
      newTree(nnkCall,
        ident"bool",
        newIntLitNode(int shouldExport)))

template createImportMethodAuto(name: untyped, selector: static[string]): untyped =
  macro `name`*(procedure: untyped): untyped =
    let
      shouldExport = procedure[0].kind == nnkPostfix
      typedName = bindsym(selector)
    result = newTree(nnkCall,
      typedName,
      procedure,
      newTree(nnkCall,
        ident"bool",
        newIntLitNode(int shouldExport)))

createImportMethod(importMethod, "importMethodTyped")
createImportMethod(importSuper, "importSuperTyped")
createImportMethod(importMethodNoSuper, "importMethodNoSuperTyped")
createImportMethodAuto(importMethodAuto, "importMethodAutoTyped")
createImportMethod(importMangle, "importMangleTyped")
createImportMethodAuto(importMangleAuto, "importMangleAutoTyped")
createImportMethodAuto(importMangleAutoNoSuper, "importMangleAutoNoSuperTyped")

macro genericMethod*(prototype: untyped): untyped =
  ## Given a method defined for the ``XAny`` type of a class ``X``,
  ## create a generic wrapper with the given type signature for that method.
  let
    procName = prototype[0]
    procArgs = prototype.params
    self = procArgs[1][0]
    returnType = procArgs[0]
    baseName =
      if procName.kind == nnkIdent:
        procName
      else:
        procName.baseName
    procCall = block:
      var res = newTree(nnkCall, baseName)
      res.add newTree(nnkCall,
        newTree(nnkCall,
          ident"genericType",
          self),
        self)
      for idx in 2 ..< procArgs.len:
        let
          name = procArgs[idx][0]
        res.add name
      res
  result = newTree(nnkProcDef)
  for child in prototype.children:
    result.add child.copyNimTree
  result[6] = newTree(nnkCast, returnType, procCall)
