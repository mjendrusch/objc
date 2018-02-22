import objc
import unittest
import macros

type AbstractObject = concept obj
  obj is Object

importClass NSObject
importClass NSArray[T] of NSObject

proc `[]`*[T: AbstractObject](self: NSArray[T]; index: culong): T
  {. importMethod: "objectAtIndex:" .}

suite "generics":
  test "generic methods":
    discard
