import objc.base, objc.hli, objc.macroCommons, objc.methodMacro
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

proc renameInterfaceToAbstract(prototype, typeName, selfName: NimNode): NimNode =
  ## Renames all instances of a ``Protocol`` interface to the ``concept`` name.
  if prototype.kind == nnkIdent and prototype.eqIdent($typeName):
    return ident("Abstract" & $typeName)
  if prototype.kind == nnkIdent and prototype.eqIdent($selfName):
    return ident("prot")
  result = prototype.copyNimNode
  for child in prototype:
    result.add renameInterfaceToAbstract(child, typeName, selfName)

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
    importMethods = genImportMethods(methods)
  result = newTree(nnkStmtList,
    conceptDecl,
    importMethods)

template `&&&`*(x, y: typedesc): untyped =
  ## `and` conjunction for objc-Protocol concepts.
  ## TODO
  discard
