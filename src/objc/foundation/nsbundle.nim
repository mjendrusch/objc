import objc
import nsobject

importClass NSBundle of NSObject

proc main*(self: typedesc[NSBundle]): NSBundle {. importMethod: "mainBundle" .}
