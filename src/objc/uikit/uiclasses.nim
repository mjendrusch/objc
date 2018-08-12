import objc
import objc / [foundation, coregraphics]

importClass UIApplication of NSObject

importProtocol UIApplicationDelegate:
  discard

# FIXME
importClass UIColor of NSObject
importClass UIScreen of NSObject
importClass UIScreenMode of NSObject

# FIXME: does not belong here!
importClass CADisplayLink

importClass UIView of NSObject
importClass UIStoryboard of NSObject 

# FIXME: this is a protocol!
importProtocol UICoordinateSpace:
  discard
importProtocol UIFocusItem:
  discard
importProtocol UIViewControllerTransitioningDelegate:
  discard
importProtocol UIViewControllerTransitionCoordinator:
  discard

importClass UIWindow of UIView

importClass UIResponder of NSObject
importClass UIViewController of UIResponder

importClass UIPresentationController of NSObject
importClass UIPopoverPresentationController of UIPresentationController

type
  UIWindowLevel* = CGFloat