import objc, objc.foundation
import unittest
import macros

type Concept = concept conc
  conc.test is int

proc evilProc[X](self: typedesc[NSObject]; a: X): Object {. importMethodAuto .}

suite "generics":
  test "generic methods":
    discard
