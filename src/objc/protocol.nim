import objc.base, objc.hli, objc.macroCommons, objc.methodMacro, objc.typeEncoding
import macros

{. hints: off .}

type
  RootProtocol = object of RootObj
  AbstractProtocol = concept ap
    ap is RootProtocol
  TypedObject*[T: AbstractProtocol] = ref object of Object

{. hints: on .}

proc getRequiredMethods(protocolBody: NimNode): seq[NimNode] =
  ## Retrieves all required methods from the body of an objc-Protocol
  ## definition.
  result = newSeq[NimNode]()
  for child in protocolBody:
    if child.kind == nnkProcDef:
      result.add child.copyNimTree

proc genConceptCallFromPrototype(prototype: NimNode; selfName: NimNode): NimNode =
  ## Generates a call statement for a concept body based on a method prototype.
  let
    types = genMethodArgTypes(prototype)
    methodNameRaw = prototype[0]
    methodName =
      if methodNameRaw.kind == nnkPostfix:
        methodNameRaw.baseName
      else:
        methodNameRaw
  result = newTree(nnkCall,
    newTree(nnkDotExpr,
      selfName,
      methodName
    )
  )
  for typ in types:
    result.add typ
  result = newTree(nnkInfix,
    bindsym"is",
    result,
    prototype[3][0])

proc genMethodDescriptorsFromPrototype(prototype: NimNode): tuple[
  selector, encoding: string
] =
  ## Generates an encoding string and selector from a method prototype.
  let
    encoding = genProcEncoding(genMethodPrototype(prototype))
    pragma = prototype.pragma
    selector =
      if pragma.kind != nnkEmpty:
        pragma[1].strVal
      else:
        $prototype.name
  result.selector = selector
  result.encoding = encoding

proc renameInterfaceToAbstract(prototype, typeName, selfName: NimNode): NimNode =
  ## Renames all instances of a ``Protocol`` interface to the ``concept`` name.
  if prototype.kind == nnkIdent and prototype.eqIdent($typeName):
    return ident("Abstract" & $typeName)
  if prototype.kind == nnkIdent and prototype.eqIdent($selfName):
    return ident("prot")
  result = prototype.copyNimNode
  for child in prototype:
    result.add renameInterfaceToAbstract(child, typeName, selfName)

proc genAddProtocolMethod(protocolName, prototype: NimNode): NimNode =
  ## Adds a class- or instance-method as a required method to a given
  ## Objective-C runtime protocol.
  let
    isClassMethod = prototypeIsClass(prototype)
    (selector, encoding) = genMethodDescriptorsFromPrototype(prototype)
  result = quote do:
    const
      sel = `selector`
      enc = `encoding`
    `protocolName`.addMethodDescription($$sel, enc, true, bool `isClassMethod`)

macro protocolMethod(protocol, prototype: typed): untyped =
  ## Wrapping inner-layer macro for typed protocol definition.
  result = genAddProtocolMethod(protocol, prototype)

proc genMacroProtocolMethod(protocol, prototype: NimNode): NimNode =
  let
    protocolMethodSym = bindSym"protocolMethod"
  var
    omittPrototype = prototype.copyNimTree
  omittPrototype.addPragma(ident"nodecl")
  omittPrototype.addPragma(ident"importc")
  omittPrototype.addPragma(ident"used")
  if omittPrototype[0].kind == nnkPostfix:
    omittPrototype[0] = omittPrototype.name
  result = quote do:
    block:
      `protocolMethodSym`(`protocol`, `omittPrototype`)

proc genProtocolDecl(nameExpr: NimNode; methods: seq[NimNode]): NimNode =
  ## Generates an Objective-C runtime protocol from a set of methods,
  ## and attaches it to the concept of a given name.
  let
    name = $nameExpr
    protocolName = gensym(nskVar)
  result = newTree(nnkStmtList)
  result.add quote do:
    var
      `protocolName` = newProtocol(`name`)
  for prototype in methods:
    result.add genMacroProtocolMethod(protocolName, prototype)
  result.add quote do:
    `protocolName`.register
  result.add quote do:
    template protocol*(typ: typedesc[`nameExpr`]): Protocol = `protocolName`

proc genConceptDecl(nameExpr: NimNode; methods: seq[NimNode]): NimNode =
  ## Generates a concept definition for a given nameExpression and required
  ## methods.
  let
    baseName = $nameExpr
    conceptName = ident("Abstract" & baseName)
    protocolName = ident(baseName & "Protocol")
    newProcName = ident("new" & baseName)
    converterName = ident("to" & baseName)
    resultName = ident"result"
  var
    calls = newTree(nnkStmtList)
  for prototype in methods:
    let
      selfName = prototype.params[1][0]
      processedPrototype = renameInterfaceToAbstract(prototype, nameExpr, selfName)
    calls.add genConceptCallFromPrototype(processedPrototype, ident"prot")
  result = quote do:
    type
      `protocolName`* = object of RootProtocol
      `nameExpr`* = TypedObject[`protocolName`]

    {. hints: off .}

    type
      `conceptName`* = concept prot
        `calls`

    {. hints: on .}

    proc standardDispose*(obj: `nameExpr`) =
      ## Disposes a ``TypedObject`` of the given ``Protocol``.
      when defined(objcDebugAlloc):
        echo "RELEASED ", repr(cast[pointer](obj.id))
      discard objcMsgSend(obj.id, $$"release")
    proc `newProcName`*(id: Id): `nameExpr` =
      ## Creates a new TypedObject adhering to a given protocol.
      new `resultName`, standardDispose
      `resultName`.id = id
      discard objcMsgSend(id, $$"retain")
    proc `newProcName`*(obj: `conceptName`): `nameExpr` =
      ## Creates a new TypedObject adhering to a given protocol.
      `newProcName`(obj.id)
    proc `converterName`*(prot: `conceptName`): `nameExpr` =
      ## Converts an Object conforming to a given protocol to the SafeObject
      ## corresponding to that protocol.
      `resultName` = `newProcName`(prot)

proc genImportMethods(methods: seq[NimNode]): NimNode =
  ## Generates imports for all methods required for a protocol.
  result = newNimNode(nnkStmtList)
  for mtd in methods:
    var
      newMethod = mtd.copyNimTree
    newMethod[4] = newTree(nnkPragma, bindsym"importMangleAuto")
    result.add(newMethod)

macro objectiveProtocol*(nameExpr: untyped; body: untyped): untyped =
  ## Creates concepts and Objective-C methods to emulate Objective-C protocols
  ## and lightweight generics.
  var
    methods = getRequiredMethods(body)
    conceptDecl = genConceptDecl(nameExpr, methods)
    protocolDecl = genProtocolDecl(nameExpr, methods)
    importMethods = genImportMethods(methods)
  result = newTree(nnkStmtList,
    conceptDecl,
    protocolDecl,
    importMethods)

template attachProtocol*(c, p: untyped): untyped =
  var
    cls: Class = c.class
    prt: Protocol = p.protocol
  discard addProtocol(cls, prt)

template `&&&`*(x, y: typedesc): untyped =
  ## `and` conjunction for objc-Protocol concepts.
  ## TODO
  discard
