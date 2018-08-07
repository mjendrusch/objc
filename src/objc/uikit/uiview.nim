import objc
import objc/foundation
import objc/coregraphics
import uicolor

importClass UIView of NSObject

proc init*(self: UIView; frame: CGRect): UIView {. importMethod: "initWithFrame:" .}
proc init*(self: UIView; coder: NSCoder): UIView {. importMethod: "initWithCoder:" .}
#
UIView.importProperties:
  backgroundColor is UIColor
  alpha is CGFloat
  tintColor is UIColor
  tintAdjustmentMode is UIViewTintAdjustmentMode
  clipsToBounds is Boolean
  clearsContextBeforeDrawing is Boolean
  maskView is UIView
  frame is CGRect
  bounds is CGRect
  center is CGPoint
  transform is CGAffineTransform
  directionalLayoutMargins is NSDirectionalEdgeInsets
  layoutMargins is UIEdgeInsets
  preservesSuperviewLayoutMargins is Boolean
  insetsLayoutMarginsFromSafeArea is Boolean
  contentMode is UIViewContentMode
  autoresizesSubviews is Boolean
  autoresizeingMask is UIViewAutoresizing
  translatesAutoresizingMaskIntoConstraints is Boolean
  semanticContentAttribute is UISemanticContentAttribute
  interactions is NSArray[UIInteraction]
  contentScaleFactor is CGFloat
  gestureRecognizers is NSArray[UIGestureRecognizer]
  motionEffects is NSArray[UIMotionEffect]
  restorationIdentifier is NSString
  tag is NSInteger
  accessibilityIgnoresInvertColors is Boolean
  (areAnimationsEnabled is Boolean)[readonly = true]
  (canBecomeFocused is Boolean)[readonly = true]
  (inheritedAnimationDuration is NSTimeInterval)[readonly = true]
  (focus is Boolean)[readonly = true, getName = "isFocused"]
  (effectiveUserInterfaceLayoutDirection is UIUserInterfaceLayoutDirection)[readonly = true]
  (requiresConstraintBasedLayout is Boolean)[readonly = true]
  (hasAmbiguousLayout is Boolean)[readonly = true]
  (viewForFirstBaselineLayout is UIView)[readonly = true]
  (viewForLastBaselineLayout is UIView)[readonly = true]
  (alignmentRectInsets is UIEdgeInsets)[readonly = true]
  (intrinsicContentSize is CGSize)[readonly = true]
  (layoutGuides is NSArray[UILayoutGuide])[readonly = true]
  (layoutMarginsGuide is UILayoutGuide)[readonly = true]
  (readableContentGuide is UILayoutGuide)[readonly = true]
  (bottomAnchor is NSLayoutYAxisAnchor)[readonly = true]
  (centerXAnchor is NSLayoutXAxisAnchor)[readonly = true]
  (centerYAnchor is NSLayoutYAxisAnchor)[readonly = true]
  (firstBaselineAnchor is NSLayoutYAxisAnchor)[readonly = true]
  (heightAnchor is NSLayoutDimension)[readonly = true]
  (lastBaselineAnchor is NSLayoutYAxisAnchor)[readonly = true]
  (leadingAnchor is NSLayoutXAxisAnchor)[readonly = true]
  (leftAnchor is NSLayoutXAxisAnchor)[readonly = true]
  (rightAnchor is NSLayoutXAxisAnchor)[readonly = true]
  (topAnchor is NSLayoutYAxisAnchor)[readonly = true]
  (trailingAnchor is NSLayoutXAxisAnchor)[readonly = true]
  (widthAnchod is NSLayoutDimension)[readonly = true]
  (constraints is NSArray[UIView])[readonly = true]
  (safeAreaLayoutGuide is UILayoutGuide)[readonly = true]
  (safeAreaInsets is UIEdgeInsets)[readonly = true]
  (window is UIWindow)[readonly = true]
  (superview is UIView)[readonly = true]
  (subview is NSArray[UIView])[readonly = true]
  (layer is CALayer)[readonly = true]
  (layerClass is Class)[readonly = true]
  (opaque is Boolean)[getName = "isOpaque"]
  (hidden is Boolean)[getName = "isHidden"]
  (userInteractionEnabled is Boolean)[getName = "isUserInteractionEnabled"]
  (multiTouchEnabled is Boolean)[getName = "isMultiTouchEnabled"]
  (exclusiveTouch is Boolean)[getName = "isExclusiveTouch"]
