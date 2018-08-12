import objc
import nsobject

importClass NSLayoutAnchor of NSObject
importClass NSLayoutDimension of NSLayoutAnchor
importClass NSLayoutXAxisAnchor of NSLayoutAnchor
importClass NSLayoutYAxisAnchor of NSLayoutAnchor

type
  NSTimeInterval* = cdouble
  NSDirectionalEdgeInsets* = object
    top, leading, bottom, trailing: cdouble
