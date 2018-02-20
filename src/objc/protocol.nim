import objc.base, objc.hli, objc.macroCommons, objc.methodMacro
import macros

type
  RootProtocol = object of RootObj
  AbstractProtocol = concept ap
    ap is RootProtocol
  TypedObject*[T: AbstractProtocol] = ref object of Object

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
  result = newTree(nnkCall, selfName)
  for typ in types:
    result.add typ
  result = newTree(nnkInfix,
    bindsym"is",
    result,
    prototype[3][0])

proc genConceptDecl(nameExpr: NimNode; methods: seq[NimNode]): NimNode =
  ## Generates a concept definition for a given nameExpression and required
  ## methods.
  let
    baseName = $nameExpr.ident
    conceptName = ident("Abstract" & baseName)
    protocolName = ident(baseName & "Protocol")
    newProcName = ident("new" & baseName)
    converterName = ident("to" & baseName)
  var
    calls = newTree(nnkStmtList)
  for prototype in methods:
    calls.add genConceptCallFromPrototype(prototype, ident"prot")
  result = quote do:
    type
      `protocolName`* = object of RootProtocol
      `nameExpr`* = TypedObject[`protocolName`]
      `conceptName`* = concept prot
        `calls`
    proc `newProcName`*(obj: `conceptName`): `nameExpr` =
      ## Creates a new TypedObject adhering to a given protocol.
      new result, objectDispose
      result.id = obj.id
      discard objcMsgSend(obj.id, $$"retain")
    converter `converterName`*(prot: `conceptName`): `nameExpr` =
      ## Converts an Object conforming to a given protocol to the SafeObject
      ## corresponding to that protocol.
      result = `newProcName`(prot)

proc genImportMethods(methods: seq[NimNode]): NimNode =
  ## Generates imports for all methods required for a protocol.
  result = newNimNode(nnkStmtList)
  for mtd in methods:
    var
      newMethod = mtd.copyNimTree
    newMethod[4] = newTree(nnkPragma, bindsym"importMangleAuto")
    result.add(newMethod)

macro objectiveProtocol*(nameExpr: untyped; body: typed): untyped =
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
