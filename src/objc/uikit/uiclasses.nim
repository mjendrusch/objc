import objc
import objc / [foundation, coregraphics]

{. passL: "-framework UIKit" .}

importClass UIApplication of NSObject

importProtocol UIApplicationDelegate:
  discard

# FIXME
importClass UIImage of NSObject
importClass UIColor of NSObject
importClass UIScreen of NSObject
importClass UIScreenMode of NSObject

# FIXME: does not belong here!
importClass CADisplayLink

importClass UIFont of NSObject
importClass UIView of NSObject
importClass UIStoryboard of NSObject 

importClass UIBaselineAdjustment

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
