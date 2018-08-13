import objc
import nsobject, nsstring

importClass NSLayoutAnchor of NSObject
importClass NSLayoutDimension of NSLayoutAnchor
importClass NSLayoutXAxisAnchor of NSLayoutAnchor
importClass NSLayoutYAxisAnchor of NSLayoutAnchor

importClass NSProgress of NSObject
importClass NSAttributedString of NSString

type
  NSTextAlignment* = cint
  NSLineBreakMode* = cint
  NSTimeInterval* = cdouble
  NSDirectionalEdgeInsets* = object
    top, leading, bottom, trailing: cdouble
