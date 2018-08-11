import objc
import nsobject

importClass NSLayoutAnchor of NSObject
importClass NSLayoutDimension of NSLayoutAnchor
importClass NSLayoutXAxisAnchor of NSLayoutAnchor
importClass NSLayoutYAxisAnchor of NSLayoutAnchor

# FIXME: this is important!
importClass NSBundle of NSObject

type
  NSTimeInterval* = cdouble
  NSDirectionalEdgeInsets* = object
    top, leading, bottom, trailing: cdouble
