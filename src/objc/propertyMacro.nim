import objc / [macroCommons, methodMacro, hli, base]
import strutils, macros

macro importProperty*(class, nameType: untyped): untyped =
  let
    name = nameType[1]
    nameEq = ident($name & "=")
    typ = nameType[2]
    getString = "get" & capitalizeAscii($name)
    setString = "set" & capitalizeAscii($name) & ":"
  result = quote do:
    proc `name`*(self: `class`): `typ` {. importMethodNoSuper: `getString` .}
    proc `nameEq`*(self: `class`; value: `typ`): void {. importMethodNoSuper: `setString` .}
  echo toStrLit result

macro importProperty*(class, nameType: untyped; options: untyped): untyped =
  var
    name = nameType[1]
    nameEq = ident($name & "=")
    typ = nameType[2]
    getString = "get" & capitalizeAscii($name)
    setString = "set" & capitalizeAscii($name) & ":"
    read = true
    write = true
    selfType = class
  for option in options:
    let
      opt = option[0]
      val = option[1]
    if opt.eqIdent("setName"):
      setString = val.strVal
    elif opt.eqIdent("getName"):
      getString = val.strVal
    elif opt.eqIdent("readonly"):
      write = false
    elif opt.eqIdent("class"):
      selfType = newTree(nnkBracketExpr,
        ident"typedesc",
        selfType.copyNimTree)

  result = quote do:
    when bool `read`:
      proc `name`*(self: `selfType`): `typ` {. importMethodNoSuper: `getString` .}
    when bool `write`:
      proc `nameEq`*(self: `selfType`; value: `typ`): void {. importMethodNoSuper: `setString` .}

macro importProperties*(class, body: untyped): untyped =
  result = newTree(nnkStmtList)
  for elem in body:
    if elem.kind == nnkInfix:
      result.add quote do:
        `class`.importProperty `elem`
    elif elem.kind == nnkBracketExpr:
      let
        infix = elem[0][0]
        options = block:
          var
            res = newTree(nnkBracket)
          for idx in 1 ..< elem.len:
            res.add elem[idx]
          res
      result.add quote do:
        `class`.importProperty `infix`, `options`