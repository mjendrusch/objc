import objc
import objc / [foundation, coregraphics]
import uiclasses, uiview

# Activity Indicator View:
type
  UIActivityIndicatorViewStyle* = enum
    UIActivityIndicatorViewStyleWhiteLarge,
    UIActivityIndicatorViewStyleWhite,
    UIActivityIndicatorViewStyleGray
importClass UIActivityIndicatorView of UIView

UIActivityIndicatorView.importProperties:
  (animating is Boolean)[getName = "isAnimating", readonly = true]
  hidesWhenStopped is Boolean
  activityIndicatorViewStyle is UIActivityIndicatorViewStyle
  color is UIColor

proc alloc*(self: typedesc[UIActivityIndicatorView]): UIActivityIndicatorView {.
  importMethod: "alloc"
.}
proc init*(self: UIActivityIndicatorView; frame: CGRect) {. importMethod: "initWithFrame:" .}
proc start*(self: UIActivityIndicatorView): void {. importMethod: "startAnimating" .}
proc stop*(self: UIActivityIndicatorView): void {. importMethod: "stopAnimating" .}

template busy*(self: UIActivityIndicatorView; body: untyped): untyped =
  self.start
  body
  self.stop

# Image View:
importClass UIImageView of UIView

UIImageView.importProperties:
  image is UIImage
  highlightedImage is UIImage
  highlighted is Boolean

proc alloc*(self: typedesc[UIImageView]): UIImageView {. importMethod: "alloc" .}
proc init*(self: UIImageView; image: UIImage): UIImageView {. importMethod: "initWithImage:" .}

# Progress View:
type
  UIProgressViewStyle* = enum
    UIProgressViewStyleDefault,
    UIProgressViewStyleBar

importClass UIProgressView of UIView

UIProgressView.importProperties:
  progress is cfloat
  observedProgress is NSProgress
  progressViewStyle is UIProgressViewStyle
  progressTintColor is UIColor
  trackTintColor is UIColor

proc alloc*(self: typedesc[UIProgressView]): UIProgressView {. importMethod: "alloc" .}
proc init*(self: UIProgressView; frame: CGRect): UIProgressView {. importMethod: "initWithFrame:" .}

proc setProgress*(self: UIProgressView; progress: cfloat; animated: Boolean) {.
  importMethod: "setProgress:animated:"
.}

# Controls:
type
  UIControlStateEnum* = enum {. size: cint .}
    UIControlStateNormal = 0,
    UIControlStateHighlighted = 1,
    UIControlStateDisabled = 2,
    UIControlStateSelected = 4,
    UIControlStateFocused = 8,
    UIControlStateApplication = 16,
    UIControlStateReserved = 32
  UIControlContentVerticalAlignment* = enum
    UIControlContentVerticalAlignmentCenter = 0,
    UIControlContentVerticalAlignmentTop = 1,
    UIControlContentVerticalAlignmentBottom = 2,
    UIControlContentVerticalAlignmentFill = 3
  UIControlContentHorizontalAlignment* = enum
    UIControlContentHorizontalAlignmentCenter = 0,
    UIControlContentHorizontalAlignmentLeft = 1,
    UIControlContentHorizontalAlignmentRight = 2,
    UIControlContentHorizontalAlignmentFill = 3,
    UIControlContentHorizontalAlignmentLeading = 4,
    UIControlContentHorizontalAlignmentTrailing = 5
  UIControlEventEnum* = enum
  UIControlEventTouchDown = 0,
  UIControlEventTouchDownRepeat = 1,
  UIControlEventTouchDragInside = 1 shl 2,
  UIControlEventTouchDragOutside = 1 shl 3,
  UIControlEventTouchDragEnter = 1 shl 4,
  UIControlEventTouchDragExit = 1 shl 5,
  UIControlEventTouchUpInside = 1 shl 6,
  UIControlEventTouchUpOutside = 1 shl 7,
  UIControlEventTouchCancel = 1 shl 8,
  UIControlEventValueChanged = 1 shl 12,
  UIControlEventPrimaryActionTriggered = 1 shl 13,
  UIControlEventEditingDidBegin = 1 shl 16,
  UIControlEventEditingChanged = 1 shl 17,
  UIControlEventEditingDidEnd = 1 shl 18,
  UIControlEventEditingDidEndOnExit = 1 shl 19,
  UIControlEvent* = set[UIControlEventEnum]
  UIControlState* = set[UIControlStateEnum]

importClass UIControl of UIView

UIControl.importProperties:
  (state is UIControlState)[readonly = true]
  (enabled is Boolean)[readonly = true]
  (selected is Boolean)[readonly = true]
  (highlighted is Boolean)[readonly = true]
  contentVerticalAlignment is UIControlContentVerticalAlignment
  contentHorizontalAlignment is UIControlContentHorizontalAlignment
  (effectiveContentHorizontalAlignment is UIControlContentHorizontalAlignment)[readonly = true]

proc addTarget*(self: UIControl; target: Object; action: Selector;
                event: UIControlEvent) {. importMethod: "addTarget:action:forControlEvents:" .}
proc removeTarget*(self: UIControl; target: Object; action: Selector;
                   event: UIControlEvent) {. importMethod: "removeTarget:action:forControlEvents:" .}

# TODO: tracking

# Button:
type
  UIButtonType* = enum
    UIButtonTypeCustom,
    UIButtonTypeSystem,
    UIButtonTypeDetailDisclosure,
    UIButtonTypeInfoLight,
    UIButtonTypeInfoDark,
    UIButtonTypeContactAdd,
    UIButtonTypePlain,
    UIButtonTypeRoundedRect
importClass UIButton of UIControl

UIButton.importProperties:
  (titleLabel is UILabel)[readonly = true]
  tintColor is UIColor
  buttonType is UIButtonType

proc create*(self: typedesc[UIButton]; typ: UIButtonType): UIButton {.
  importMethod: "buttonWithType:"
.}

proc title*(self: UIButton; state: UIControlState): NSString {.
  importMethod: "titleForState:"
.}

proc setTitle*(self: UIButton; title: NSString; state: UIControlState): void {.
  importMethod: "setTitle:forState:"
.}

proc titleColor*(self: UIButton; state: UIControlState): UIColor {.
  importMethod: "titleColorForState:"
.}

proc setTitleColor*(self: UIButton; color: UIColor; state: UIControlState): void {.
  importMethod: "setTitleColor:forState:"
.}

# Segmented Control:

importClass UISegmentedControl of UIControl

UISegmentedControl.importProperties:
  (numberOfSegments is NSUInteger)[readonly = true]
  (selectedSegmentIndex is NSUInteger)[readonly = true]

proc alloc*(self: typedesc[UISegmentedControl]): UISegmentedControl {. importMethod: "alloc" .}
proc init*(self: UISegmentedControl; items: NSArray[UIImage]): UISegmentedControl {. importMethod: "initWithItems:" .}
proc init*(self: UISegmentedControl; items: NSArray[NSString]): UISegmentedControl {. importMethod: "initWithItems:" .}

proc imageAt*(self: UISegmentedControl; index: NSUInteger): UIImage {. importMethod: "imageForSegmentAtIndex" .}
proc imageSet*(self: UISegmentedControl; img: UIImage; index: NSUInteger): void {.
  importMethod: "setImage:forSegmentAtIndex:"
.}
proc titleAt*(self: UISegmentedControl; index: NSUInteger): NSString {. importMethod: "titleForSegmentAtIndex" .}
proc titleSet*(self: UISegmentedControl; img: NSString; index: NSUInteger): void {.
  importMethod: "setTitle:forSegmentAtIndex:"
.}
proc insert*(self: UISegmentedControl; img: UIImage; index: NSUInteger; animated: Boolean): void {.
  importMethod: "insertSegmentWithImage:atIndex:animated:"
.}
proc insert*(self: UISegmentedControl; img: NSString; index: NSUInteger; animated: Boolean): void {.
  importMethod: "insertSegmentWithTitle:atIndex:animated:"
.}
proc clear*(self: UISegmentedControl): void {. importMethod: "removeAllSegments" .}
proc deleteAt*(self: UISegmentedControl; index: NSUInteger; animated: Boolean): void {.
  importMethod: "removeSegmentAtIndex:animated:"
.}
proc toggle*(self: UISegmentedControl; enabled: Boolean; index: NSUInteger): void {.
  importMethod: "setEnabled:forSegmentAtIndex:"
.}
proc enabled*(self: UISegmentedControl; index: NSUInteger): Boolean {.
  importMethod: "isEnabledForSegmentAtIndex:"
.}

# Slider:
importClass UISlider of UIControl

UISlider.importProperties:
  value is cfloat
  minimumValue is cfloat
  maximumValue is cfloat
  continuous is Boolean
  minimumValueImage is UIImage
  maximumValueImage is UIImage
  (currentThumbImage is UIImage)[readonly = true]
  (currentMinimumTrackImage is UIImage)[readonly = true]
  (currentMaximumTrackImage is UIImage)[readonly = true]
  minimumTrackTintColor is UIColor
  maximumTrackTintColor is UIColor
  thumbTintColor is UIColor

proc thumbImage*(self: UISlider; state: UIControlState): UIImage {.
  importMethod: "thumbImageForState:"
.}
proc setThumbImage*(self: UISlider; image: UIImage; state: UIControlState): void {.
  importMethod: "setThumbImage:forState:"
.}

proc alloc*(self: typedesc[UISlider]): UISlider {. importMethod: "alloc" .}
proc init*(self: UISlider): UISlider {. importMethod: "init" .}

proc setValue*(self: UISlider; value: cfloat; animated: Boolean): void {.
  importMethod: "setValue:animated:"
.}

# Stepper:
importClass UIStepper of UIControl

UIStepper.importProperties:
  continuous is Boolean
  autorepeat is Boolean
  wraps is Boolean
  minimumValue is cfloat
  maximumValue is cfloat
  stepValue is cfloat
  value is cfloat
  tintColor is UIColor

proc background*(self: UIStepper; state: UIControlState): UIImage {.
  importMethod: "backgroundImageForState:"
.}
proc setBackgound*(self: UIStepper; image: UIImage; state: UIControlState): void {.
  importMethod: "setBackgroundImage:forState:"
.}
proc decrementImage*(self: UIStepper; state: UIControlState): UIImage {.
  importMethod: "decrementImageForState:"
.}
proc setDecrementImage*(seld: UIStepper; image: UIImage; state: UIControlState): void {.
  importMethod: "setDecrementImage:forState:"
.}
proc incrementImage*(self: UIStepper; state: UIControlState): UIImage {.
  importMethod: "incrementImageForState:"
.}
proc setIncrementImage*(seld: UIStepper; image: UIImage; state: UIControlState): void {.
  importMethod: "setIncrementImage:forState:"
.}
proc dividerImage*(self: UIStepper; lstate, rstate: UIControlState): UIImage {.
  importMethod: "dividerImageForLeftSegmentState:rightSegmentState:"
.}
proc setDividerImage*(seld: UIStepper; image: UIImage; lstate, rstate: UIControlState): void {.
  importMethod: "setDividerImage:forStateLeftSegmentState:rightSegmentState:"
.}

proc alloc*(self: typedesc[UIStepper]): UIStepper {. importMethod: "alloc" .}
proc init*(self: UIStepper): UIStepper {. importMethod: "init" .}

# Switch:
importClass UISwitch of UIControl

UISwitch.importProperties:
  on is Boolean
  tintColor is UIColor
  onTintColor is UIColor
  thumbTintColor is UIColor

proc setOn*(self: UISwitch; on: Boolean; animated: Boolean): void {.
  importMethod: "setOn:animated:"
.}

proc alloc*(self: typedesc[UISwitch]): UISwitch {. importMethod: "alloc" .}
proc init*(self: UISwitch; frame: CGRect): UISwitch {. importMethod: "initWithFrame:" .}

# UILabel
importClass UILabel of UIView

UILabel.importProperties:
  text is NSString
  attributedText is NSAttributedString
  font is UIFont
  textColor is UIColor
  textAlignment is NSTextAlignment
  lineBreakMode is NSLineBreakMode
  (enabled is Boolean)[getName = "isEnabled"]
  adjustsFontSizeToFitWidth is Boolean
  allowsDefaultTighteningForTruncation is Boolean
  baselineAdjustment is UIBaselineAdjustment
  minimumScaleFactor is CGFloat
  numberOfLines is NSInteger
  highlightedTextColor is UIColor
  highlighted is Boolean
  shadowColor is UIColor
  shadowOffset is UIColor
  preferredMaxLayoutWidth is CGFloat
  userInteractionEnabled is Boolean

proc draw*(self: UILabel; rect: CGRect): void {. importMethod: "drawTextInRect:" .}

# Text Field:
importProtocol UITextFieldDelegate:
  discard
importClass UITextField of UIControl

type
  UITextBorderStyle* = cint
  UITextFieldViewMode* = cint

UITextField.importProperties:
  delegate is UITextFieldDelegate
  text is NSString
  attributedString is NSAttributedString
  placeholder is NSString
  attributedPlaceholder is NSAttributedString
  defaultTextAttribute is NSDictionary# FIXME
  font is UIFont
  textColor is UIColor
  textAlignment is NSTextAlignment
  typingAttributes is NSDictionary# FIXME
  adjustsFontSizeToFitWidth is Boolean
  minimumFontSize is CGFloat
  (editing is Boolean)[readonly = true, getName = "isEditing"]
  clearsOnBeginEditing is Boolean
  clearsOnIntersection is Boolean
  allowsEditingTextAttributes is Boolean
  borderStyle is UITextBorderStyle
  background is UIImage
  disabledBackground is UIImage
  clearButtonMode is UITextFieldViewMode
  leftView is UIView
  rightView is UIView
  rightViewMode is UITextFieldViewMode
  inputView is UIView
  inputAccessoryView is UIView

proc alloc*(self: typedesc[UITextField]): UITextField {.
  importMethod: "alloc"
.}
proc initWithFrame*(self: UITextField; frame: CGRect): UITextField {.
  importMethod: "initWithFrame:"
.}
proc draw*(self: UITextField; rect: CGRect): void {.
  importMethod: "drawTextInRect:"
.}
proc drawPlaceholder*(self: UITextField; rect: CGRect): void {.
  importMethod: "drawPlaceholderInRect:"
.}

# Text View : TODO

# Visual Effect
importClass UIVisualEffect of NSObject
importClass UIVibrancyEffect of UIVisualEffect
importClass UIBlurEffect of UIVisualEffect
importClass UIVisualEffectView of UIView

type
  UIBlurEffectStyle* = enum
    UIBlurEffectStyleExtraLight,
    UIBlurEffectStyleLight,
    UIBlurEffectStyleDark,
    UIBlurEffectStyleExtraDark,
    UIBlurEffectStyleRegular,
    UIBlurEffectStyleProminent

UIVisualEffectView.importProperties:
  (contentview is UIView)[readonly = true]
  effect is UIVisualEffect

proc alloc*(self: typedesc[UIVisualEffectView]): UIVisualEffectView {.
  importMethod: "alloc"
.}
proc init*(self: UIVisualEffectView; effect: UIVisualEffect): UIVisualEffectView {.
  importMethod: "init"
.}

proc blur*(self: typedesc[UIVibrancyEffect]; blur: UIBlurEffect): UIVibrancyEffect {.
  importMethod: "effectForBlurEffect:"
.}
proc primary*(self: typedesc[UIVibrancyEffect]): UIVibrancyEffect {.
  importMethod: "widgetPrimaryVibranceEffect"
.}
proc secondary*(self: typedesc[UIVibrancyEffect]): UIVibrancyEffect {.
  importMethod: "widgetSecondaryVibrancyEffect"
.}
proc style*(self: typedesc[UIBlurEffect]; style: UIBlurEffectStyle): UIBlurEffect {.
  importMethod: "effectWithStyle:"
.}
