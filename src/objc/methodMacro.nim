import objc.base, objc.macroCommons, objc.typeEncoding
import macros

proc genMethodArgTypes(procedure: NimNode): seq[NimNode] =
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

proc mangleMethodSelector(name: string; types: seq[NimNode]): string =
  ## Mangles a procedure name given a list of types, to create an easily
  ## reproducible, yet overloadable method selector.
  result = name
  for typ in types:
    result.add ":" & $toStrLit(typ)

proc mangleMethodSelector(procedure: NimNode): NimNode =
  ## Mangles a procedure name to produce an easily reproducible,
  ## yet overloadable method selector.
  var
    types = genMethodArgTypes(procedure)
    mangledName = $procedure[0].symbol
  result = newStrLitNode(mangleMethodSelector(mangledName, types))

proc genMethodSelector(procedure: NimNode; name: string = nil): NimNode =
  ## Generates a unique selector name for a procedure, given its arguments.
  let
    mangledSelector = gensym(nskProc)
    symbolString =
      if name.isNil:
        mangleMethodSelector(procedure)
      else:
        newStrLitNode(name)
  result = quote do:
    proc `mangledSelector`: string {. inline .} =
      var res {. exportc .} = cstring""
      {. emit: ["res = \"", `symbolString`, "\";"] .}
      $res
    `mangledSelector`()

proc genMethodProc(procedure, name: NimNode): NimNode =
  ## Generates a wrapper for a procedure, such that this wrapper can be used
  ## to attach the given procedure to a class, as an instance method or
  ## class method.
  let
    symbol = procedure[0]
    selfType = procedure[3][1][^2]
    newCallName = ident("new" & $selfType.symbol)
  var
    call = newTree(nnkCall, symbol, quote do:
      `newCallName`(self))
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
  let args = procedure[3]
  for idx in 2 ..< args.len:
    let identDef = args[idx]
    newArgs.add identDef.copyNimTree
    for idy in 0 ..< identDef.len - 2:
      let arg = identDef[idy]
      call.add arg
  result = newTree(nnkProcDef,
    name,
    newEmptyNode(),
    newEmptyNode(),
    newArgs,
    newTree(nnkPragma, ident"cdecl"),
    newEmptyNode(),
    newTree(nnkStmtList, call))
  if not args[0].eqIdent "void":
    if args[0].getTypeImpl.isObject:
      result[3][0] = bindsym"Id"
      result[6] = newTree(nnkStmtList,
        newTree(nnkAsgn,
          ident"result",
          quote do:
            `call`.id
          ))
    else:
      result[6] = newTree(nnkStmtList,
        newTree(nnkAsgn, ident"result", call))

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
    methodProcedure = genMethodProc(procedure, procName)
    methodSelector = genMethodSelector(procedure, nil)
    encoding = genProcEncoding(methodProcedure)
    implementation = bindsym"Implementation"
  result = quote do:
    `methodProcedure`
    discard addMethod(`class`.class, $$`methodSelector`,
                      cast[`implementation`](`procName`),
                      `encoding`)

proc makeImportMethodCallArgs*(args: NimNode): NimNode =
  ## Creates the call arguments for the static method call of an imported
  ## method.
  result = newTree(nnkArglist)
  for idx in 2 ..< args.len:
    let
      identDef = args[idx]
      defType = identDef[^2]
      isAnObject = defType.getTypeImpl.isObject
      isAClass = defType.getTypeImpl.isClass
    for idy in 0 ..< identDef.len - 2:
      let
        identifier = identDef[idy]
        callArg =
          if isAnObject:
            newTree(nnkDotExpr, identifier, ident"id")
          elif isAClass:
            newTree(nnkDotExpr, identifier, ident"class") # FIXME
          else:
            identifier
      result.add callArg

template stretInsanity(typ: untyped; size: int): untyped =
  if sizeof(typ) <= size:
    cast[pointer](objcMsgSend)
  else:
    cast[pointer](objcMsgSendStret)

proc importMethodImpl(messageName: string; procedure: NimNode): NimNode =
  ## Implements Objective-C runtime method import.
  let
    args = procedure[3]
    self = newTree(nnkDotExpr,
      args[1][0].copyNimTree,
      ident"id")
    selfType = args[1][^2]
    returnType = args[0]
    funp = gensym(nskLet)
    callArgs = makeImportMethodCallArgs(args)

  result = procedure.copyNimTree
  if returnType == bindsym"void":
    result[6] = quote do:
      discard objcMsgSend(`self`, $$`messageName`, `callArgs`)
  elif returnType == bindsym"float" or returnType == bindsym"float32" or
       returnType == bindsym"float64":
    result[6] = quote do:
      let `funp` = cast[proc(self: Id; sel: Selector): `returnType`
                        {. varargs, cdecl .}](objcMsgSendFpRet)
      return `funp`(`self`, $$`messageName`, `callArgs`)
  elif returnType.typeKind in {ntyTuple, ntyObject}:
    # XXX: this is insane!
    # We are choosing whether to use objcMsgSend or objcMsgSendStret, depending
    # on the target architecture and object size.
    var
      whichMsgSend = bindsym"objcMsgSendStret"
      stretTemplate = bindsym"stretInsanity"
    case hostCPU
    of "amd64", "powerpc64", "arm64":
      whichMsgSend = quote do:
        `stretTemplate`(`returnType`, 16)
    of "i386":
      whichMsgSend = quote do:
        `stretTemplate`(`returnType`, 8)
    of "powerpc":
      whichMsgSend = quote do:
        `stretTemplate`(`returnType`, 0)
    of "arm":
      whichMsgSend = quote do:
        `stretTemplate`(`returnType`, 4)
    else:
      discard
    result[6] = quote do:
      let `funp` = cast[proc(self: Id; sel: Selector): `returnType`
                        {. varargs, cdecl .}](`whichMsgSend`)
      return `funp`(`self`, $$`messageName`, `callArgs`)
  elif returnType.getTypeImpl.isObject:
    let
      newResult = ident("new" & $selfType.symbol)
    result[6] = quote do:
      `newResult`(objcMsgSend(`self`, $$`messageName`, `callArgs`))
  else:
    result[6] = quote do:
      let `funp` = cast[proc(self: Id; sel: Selector): `returnType`
                        {. varargs, cdecl .}](objcMsgSend)
      return `funp`(`self`, $$`messageName`, `callArgs`)

macro importMethod*(messageName: static[string]; procedure: typed): untyped =
  ## Creates Objective-C bindings for a procedure prototype.
  result = importMethodImpl(messageName, procedure)

macro importMethodAuto*(procedure: typed): untyped =
  ## Creates Objective-C bindings for a procedure prototype.
  let
    messageName = $procedure[0].symbol
  result = importMethodImpl(messageName, procedure)

macro importMangle*(messageName: static[string]; procedure: typed): untyped =
  ## Creates Objective-C bindings for a procedure prototype, automatically
  ## mangling the message name.
  let
    mangledName = mangleMethodSelector(messageName,
                                       genMethodArgTypes(procedure))
  result = importMethodImpl(mangledName, procedure)

macro importMangleAuto*(procedure: typed): untyped =
  ## Creates Objective-C bindings for a procedure prototype, automatically
  ## mangling the message name.
  let
    messageName = $procedure[0].symbol
    mangledName = mangleMethodSelector(messageName,
                                       genMethodArgTypes(procedure))
  result = importMethodImpl(mangledName, procedure)
