import objc
import unittest
import macros

importClass NSObject
importClass NSArray[T] of NSObject
importClass NSMutableArray[T] of NSArray[T]

suite "generics":
  test "generic methods":
    discard
