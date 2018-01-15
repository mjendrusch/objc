import macros, strutils

type
  ClassType* = object {. inheritable .}
  MetaClassType* = object {. inheritable .}

iterator supers*(typ: NimNode): NimNode =
  assert typ.kind == nnkObjectTy
  var
    lastInherit = typ[1]
  while lastInherit.kind == nnkOfInherit:
    yield lastInherit[0]
    lastInherit = getTypeImpl(lastInherit[0])[1]

proc isClass*(typ: NimNode): bool =
  result = false
  for super in typ.supers:
    if super.eqIdent "ClassType":
      return true

proc genTypeEncoding*(typ: NimNode; pointerDepth: int = 0): string

proc genPrimitiveTypeEncoding*(typ: NimNode): string =
  ## Generates an Objective-C type encoding for a primitive type.
  assert typ.kind == nnkSym
  let identifier = $typ.symbol
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
  of nnkObjectTy:
    if typeImplementation.isClass and pointerDepth > 0:
      result = "@"
    elif typeImplementation.isClass:
      result = "{$#=$#}" % [$typ.symbol, genClassEncoding(typeImplementation)]
    else:
      result = "{`$#`=$#}" % [$typ.symbol, genFieldEncoding(typeImplementation)]
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
    echo "ERROR"

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

when isMainModule:
  type
    Class = object
    ClassType = object {. inheritable .}
    NSObject = object of ClassType
      id: int
    SomeClass = object of NSObject
      val: int
      tt: ptr NSObject
      cl: ptr Class
    NonClass = object
      val: int
  var test = encode(SomeClass)
  echo test

  {. emit: """
  typedef struct {
  long long a;
  } testStruct;
  @interface NSObject
  {
    long long id;
  }
  @end
  @interface SomeClass : NSObject
  {
    // testStruct ts;
    long long val;
    NSObject *tt;
    Class *cl;
  }
  -(void)test;
  @end
  """ .}
  proc main =
    {. emit: ["printf(\"%s\\n\", @encode(SomeClass));"] .}


  main()
