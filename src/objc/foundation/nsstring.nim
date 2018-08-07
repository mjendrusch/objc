import objc
import nsobject

type
  NSStringEncoding* = NSUInteger
importClass NSString of NSObject

proc str*(self: typedesc[NSString]): NSString {. importMethod: "string" .}
proc init*(self: NSString): NSString {. importMethod: "init" .}
proc init*(self: NSString; buf: pointer; length: NSUInteger; encoding: NSStringEncoding): NSString {. importMethod: "initWithBytes:length:encoding:" .}
proc init*(self: NSString; buf: cstring): NSString {. importMethod: "initWithUTF8String:" .}

template `$!`*(s: auto): NSString =
  ## Converts any given stringifyable object to ``NSString``.
  let
    str = $s
  result = NSString.str
  result.init(s.cstring)
