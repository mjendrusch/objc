import objc
import unittest
import macros

importClass NSObject
importClass NSArray[T] of NSObject

proc `[]`*[T: AbstractObject](self: NSArray[T]; index: culong): T
  {. importMethod: "objectAtIndex:" .}

suite "generics":
  test "generic methods":
    discard
