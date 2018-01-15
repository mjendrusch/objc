import objc.base, objc.macroCommons, objc.typeEncoding
import macros

proc genMethodSelector(procedure: NimNode): NimNode =
  ## Generates a unique selector name for a procedure, given its arguments.
  let
    mangledSelector = gensym(nskProc)
    symbol = procedure[0]
    symbolString = symbol.toStrLit
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
  var
    call = newTree(nnkCall, symbol, quote do:
      newTest(self))
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
    result[6] = newTree(nnkStmtList,
      newTree(nnkAsgn, ident"result", call))

macro objectiveMethod*(procedure: typed): untyped =
  ## Adds a procedure to an Objective-C runtime class.
  let
    class = procedure[3][1][^2]
    procName = gensym(nskProc)
    methodProcedure = genMethodProc(procedure, procName)
    methodSelector = genMethodSelector(procedure)
    encoding = genProcEncoding(methodProcedure)
    implementation = bindsym"Implementation"
  result = quote do:
    `methodProcedure`
    discard addMethod(`class`.class, $$`methodSelector`,
                      cast[`implementation`](`procName`),
                      `encoding`)
