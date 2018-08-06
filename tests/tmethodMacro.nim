import objc
import unittest

importClass NSObject
objectiveClass Test of NSObject
objectiveClass Inherit of Test

type
  StructF4 = object
    f: float32
  StructF8 = object
    f: float64
  StructF16 = object
    f, g: float64
  StructF20 = object
    f, g: float64
    h: float32
  StructF24 = object
    f, g, h: float64
  Struct4 = object
    f: int32
  Struct8 = object
    f: int64
  Struct16 = object
    f, g: int64
  Struct20 = object
    f, g: int64
    h: int32
  Struct24 = object
    f, g, h: int64

suite "method macro":
  test "create method":
    proc returnsFloat(self: Test): float {. objectiveMethod .} =
      return 3.14
    proc returnsTest(self: Test): Test {. objectiveMethod .} =
      return self
    proc returnsTest(self: Test, arg: int): cint {. objectiveMethod .} =
      return arg.cint
    proc returnsStruct4(self: Test): Struct4 {. objectiveMethod .} =
      return Struct4()
    proc returnsStruct8(self: Test): Struct8 {. objectiveMethod .} =
      return Struct8()
    proc returnsStruct16(self: Test): Struct16 {. objectiveMethod .} =
      return Struct16()
    proc returnsStruct20(self: Test): Struct20 {. objectiveMethod .} =
      return Struct20()
    proc returnsStruct24(self: Test): Struct24 {. objectiveMethod .} =
      return Struct24()
    proc returnsStructF4(self: Test): StructF4 {. objectiveMethod .} =
      return StructF4()
    proc returnsStructF8(self: Test): StructF8 {. objectiveMethod .} =
      return StructF8()
    proc returnsStructF16(self: Test): StructF16 {. objectiveMethod .} =
      return StructF16()
    proc returnsStructF20(self: Test): StructF20 {. objectiveMethod .} =
      return StructF20()
    proc returnsStructF24(self: Test): StructF24 {. objectiveMethod .} =
      return StructF24()
    let
      test = newTest()
      returned = test.returnsTest
      struct4 = test.returnsStruct4
      struct8 = test.returnsStruct8
      struct16 = test.returnsStruct16
      struct20 = test.returnsStruct20
      struct24 = test.returnsStruct24
      structF4 = test.returnsStructF4
      structF8 = test.returnsStructF8
      structF16 = test.returnsStructF16
      structF20 = test.returnsStructF20
      structF24 = test.returnsStructF24
    check test.returnsFloat == 3.14
    check returned.id == test.id
    check struct4.f == 0
    check struct8.f == 0
    check struct16.f == 0
    check struct20.f == 0
    check struct24.f == 0
    check structF4.f == 0'f32
    check structF8.f == 0'f64
    check structF16.f == 0'f64
    check structF20.f == 0'f64
    check structF24.f == 0'f64

  test "create class method":
    proc testClassMethod(self: typedesc[Test]): int {. objectiveMethod .} =
      return 42
    check Test.testClassMethod == 42

  test "import method":
    proc anotherFloat(self: Inherit): float {. importMangle: "returnsFloat" .}
    proc returnsInherit(self: Inherit): Inherit {. importMangle: "returnsTest" .}
    proc returnsInherit(self: Inherit; arg: int): cint {. importMangle: "returnsTest" .}
    proc anotherStruct4(self: Inherit): Struct4 {. importMethod: "returnsStruct4" .}
    proc anotherStruct8(self: Inherit): Struct8 {. importMethod: "returnsStruct8" .}
    proc anotherStruct16(self: Inherit): Struct16 {. importMethod: "returnsStruct16" .}
    proc anotherStruct20(self: Inherit): Struct20 {. importMethod: "returnsStruct20" .}
    proc anotherStruct24(self: Inherit): Struct24 {. importMethod: "returnsStruct24" .}
    proc anotherStructF4(self: Inherit): StructF4 {. importMethod: "returnsStructF4" .}
    proc anotherStructF8(self: Inherit): StructF8 {. importMethod: "returnsStructF8" .}
    proc anotherStructF16(self: Inherit): StructF16 {. importMethod: "returnsStructF16" .}
    proc anotherStructF20(self: Inherit): StructF20 {. importMethod: "returnsStructF20" .}
    proc anotherStructF24(self: Inherit): StructF24 {. importMethod: "returnsStructF24" .}
    let
      inh = newInherit()
      returned = inh.returnsInherit
      returnedOverload = inh.returnsInherit(42)
      struct4 = inh.anotherStruct4
      struct8 = inh.anotherStruct8
      struct16 = inh.anotherStruct16
      struct20 = inh.anotherStruct20
      struct24 = inh.anotherStruct24
      structF4 = inh.anotherStructF4
      structF8 = inh.anotherStructF8
      structF16 = inh.anotherStructF16
      structF20 = inh.anotherStructF20
      structF24 = inh.anotherStructF24
    check inh.anotherFloat == 3.14
    check inh.id == returned.id
    check returnedOverload == 42
    check struct4.f == 0
    check struct8.f == 0
    check struct16.f == 0
    check struct20.f == 0
    check struct24.f == 0
    check structF4.f == 0'f32
    check structF8.f == 0'f64
    check structF16.f == 0'f64
    check structF20.f == 0'f64
    check structF24.f == 0'f64

  test "import class method":
    proc testInheritMethod(self: typedesc[Inherit]): int {. importMethod: "testClassMethod" .}
    check Inherit.testInheritMethod == 42
