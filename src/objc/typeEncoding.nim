import objc.macroCommons
import macros, strutils

proc genTypeEncoding*(typ: NimNode; pointerDepth: int = 0): string

proc genPrimitiveTypeEncoding*(typ: NimNode): string =
  ## Generates an Objective-C type encoding for a primitive type.
  expectKind typ, nnkSym
  let identifier = $typ
  case identifier
  of "int8", "char", "cchar":
    result = "c"
  of "int16", "cshort":
    result = "s"
  of "int32", "cint":
    result = "i"
  of "clong":
    result = "l"
  of "clonglong", "int64", "int":
    result = "q"
  of "uint8", "byte", "cuchar":
    result = "C"
  of "uint16", "cushort":
    result = "S"
  of "uint32", "cuint", "csize":
    result = "I"
  of "culong":
    result = "L"
  of "uint", "uint64", "culonglong":
    result = "Q"
  of "float32", "cfloat":
    result = "f"
  of "float64", "float", "cdouble":
    result = "d"
  of "void":
    result = "v"
  of "cstring":
    result = "*"
  else:
    result = "ERROR-TYPE"
    error("Unknown primitive type: " & $toStrLit(typ), typ)

proc genFieldEncoding*(typ: NimNode): string =
  ## Generates a type encoding string for a RecList.
  result = ""
  for recordField in typ[2]:
    let recordType = recordField[^2]
    result.add genTypeEncoding(recordType)

proc genClassEncoding*(typ: NimNode): string =
  ## Generates a type encoding string for an Objective-C class type
  ## dummy type.
  result = genFieldEncoding(typ)
  for super in typ.supers:
    result = genFieldEncoding(super.getTypeImpl) & result

proc genTypeEncoding*(typ: NimNode; pointerDepth: int = 0): string =
  ## Generates an Objective-C type encoding for a given Nim type node.
  let
    typeImplementation = typ.getTypeImpl
  if typ.kind == nnkSym:
    if typ.eqIdent "Id":
      return "@"
    elif typ.eqIdent "Selector":
      return ":"
    elif typ.eqIdent "Class":
      return "#"
  case typeImplementation.kind
  of nnkRefTy:
    if typeImplementation[0].getTypeImpl.isObject:
      result = "@"
  of nnkObjectTy:
    if typeImplementation.isClass and pointerDepth > 0:
      result = "@"
    elif typeImplementation.isClass:
      result = "{$#=$#}" % [$typ, genClassEncoding(typeImplementation)]
    else:
      result = "{`$#`=$#}" % [$typ, genFieldEncoding(typeImplementation)]
  of nnkTupleTy:
    result = "{`$#`=$#}" % [genFieldEncoding(typeImplementation)]
  of nnkPtrTy:
    let nextType = genTypeEncoding(typeImplementation[0], pointerDepth + 1)
    if nextType.endswith"@" and pointerDepth == 0:
      result = nextType
    else:
      result = "^" & nextType
  of nnkProcTy:
    result = "^?"
  of nnkSym:
    result = genPrimitiveTypeEncoding(typeImplementation)
  else:
    error("Unsupported type for encoding: " & $typ.toStrLit & " please file an issue on GitHub.", typ)

proc decodeTypeStringImpl(typeString: string; pos: var int): string =
  ## Decodes a type encoding string to the corresponding Nim type sourcecode.
  result = ""
  echo "converting: ", typeString
  let
    length = typeString.len
  while pos < length:
    var
      current = ""
      c = typeString[pos]
    case c
    of '{':
      inc pos
      var
        name = ""
        fields = ""
      while c != '=':
        inc pos
        c = typeString[pos]
        name.add c
      while c != '}':
        fields.add decodeTypeStringImpl(typeString, pos)
        c = typeString[pos]
        echo c
    of '@':
      inc pos
      return "Object"
    of '^':
      inc pos
      c = typeString[pos]
      if c == '?':
        inc pos
        return "proc"
      else:
        let
          pointerType = decodeTypeStringImpl(typeString, pos)
        return "ptr[" & pointerType & "]"
    of ':':
      inc pos
      return "Selector"
    of '#':
      inc pos
      return "Class"
    of 'c':
      inc pos
      return "int8"
    of 's':
      inc pos
      return "int16"
    of 'i':
      inc pos
      return "int32"
    of 'l':
      inc pos
      return "clong"
    of 'q':
      inc pos
      return "int64"
    of 'C':
      inc pos
      return "uint8"
    of 'S':
      inc pos
      return "uint16"
    of 'I':
      inc pos
      return "uint32"
    of 'L':
      inc pos
      return "culong"
    of 'Q':
      inc pos
      return "uint64"
    of 'f':
      inc pos
      return "float32"
    of 'd':
      inc pos
      return "float64"
    of 'v':
      inc pos
      return "void"
    of '*':
      inc pos
      return "cstring"
    else:
      inc pos
      return "ERRORTYPE"

proc decodeTypeString*(typeString: string): string =
  var
    pos = 0
  decodeTypeStringImpl(typeString, pos)

proc genProcEncoding*(procedure: NimNode): string =
  ## Generates a type encoding for a procedure, to be used for adding methods
  ## to classes.
  let args = procedure[3]
  result = genTypeEncoding(args[0])
  for idx in 1 ..< args.len:
    let
      identDef = args[idx]
      encoding = genTypeEncoding(identDef[^2])
    result &= encoding.repeat(identDef.len - 2)

macro encode*(typ: typedesc): untyped =
  ## Given a typedesc, generates the corresponding Objective-C runtime type
  ## encoding.
  let
    typeNode = typ.getTypeImpl[1]
    encodeString = "\"" & genTypeEncoding(typeNode) & "\";"
    emitEncode = gensym(nskProc)
  result = quote do:
    proc `emitEncode`: cstring {. inline .} =
      var res {. exportc .} = cstring""
      {. emit: "res = " & `encodeString` .}
      res
    `emitEncode`()
