import objc.base, objc.macroCommons, objc.typeEncoding
import multimeta

proc genMethodSelector(procedure: NimNode): NimNode =
  ## Generates a unique selector name for a procedure, given its arguments.


proc genMethodProc(procedure: NimNode): NimNode =
  ## Generates a wrapper for a procedure, such that this wrapper can be used
  ## to attach the given procedure to a class, as an instance method or
  ## class method.


macro objectiveMethod*(procedure: untyped; class: untyped): untyped =
  ## Adds a procedure to an Objective-C runtime class.
  ## TODO: WIP
  let
    methodProcedure = genMethodProc(procedure)
    methodSelector = genMethodSelector(procedure)
    encoding = genProcEncoding(procedure)
    procName = procedure[0]
    implementation = bindsym"Implementation"
  echo encoding
  result = quote do:
    `methodProcedure`
    addMethod(`class`, `methodSelector`, cast[`implementation`](procName), `encoding`)
