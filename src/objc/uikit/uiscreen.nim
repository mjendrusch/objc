import objc
import objc / [foundation, coregraphics]
import uiclasses

UIScreen.importProperty testIt is NSArray[UIScreen]
# proc testIt*(self: UIScreen): NSArray[UIScreen] {. importMethod: "testIt" .}

UIScreen.importProperties:
  (mainScreen is UIScreen)[readonly = true, class = true]
  (screens is NSArray[UIScreen])[readonly = true]
  mirroredScreen is UIScreen
  (coordinateSpace is UICoordinateSpace)[readonly = true]
  (fixedCoordinateSpace is UICoordinateSpace)[readonly = true]
  (bounds is CGRect)[readonly = true]
  (nativeBounds is CGRect)[readonly = true]
  (scale is CGFloat)[readonly = true]
  (nativeScale is CGFloat)[readonly = true]
  currentMode is UIScreenMode
  (preferredMode is UIScreenMode)[readonly = true]
  (availableModes is NSArray[UIScreenMode])[readonly = true]
  (maximumFramesPerSecond is NSInteger)[readonly = true]
  brightness is CGFloat
  wantsSoftwareDimming is Boolean
  (focusedItem is UIFocusItem)[readonly = true]
  (focusedView is UIView)[readonly = true]
  (supportsFocus is Boolean)[readonly = true]

proc displayLink*(self: UIScreen; target: Object; selector: Selector): CADisplayLink {.
  importMethod: "displayLinkWithTarget:selector:"
.}