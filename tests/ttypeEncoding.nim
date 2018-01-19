import objc
import unittest

suite "type encodings":
  test "primitives":
    check encode(int8) == "c"
    check encode(int16) == "s"
    check encode(int32) == "i"
    check encode(int64) == "q"
    check encode(uint8) == "C"
    check encode(uint16) == "S"
    check encode(uint32) == "I"
    check encode(uint64) == "Q"
    check encode(float32) == "f"
    check encode(float64) == "d"
    check encode(void) == "v"
    check encode(cstring) == "*"

  test "Objective-C types":
    check encode(Id) == "@"
    check encode(Class) == "#"
    check encode(Selector) == ":"

  test "Composite types":
    type
      Struct {. exportc .} = object
        a, b, c: int64
        d: ptr float32
      Struct2 {. exportc .} = object
        a: Struct
        b, c, d: ptr int
        e, f: Class
        g: Id
    check encode(Struct) == "{Struct=qqq^f}"
    check encode(Struct2) == "{Struct2={Struct=qqq^f}^q^q^q##@}"
