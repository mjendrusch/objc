import objc
import objc/foundation
import uiclasses

UIColor.importProperties:
  (darkTextColor is UIColor)[class = true, readonly = true]
  (lightTextColor is UIColor)[class = true, readonly = true]
  (groupTableViewBackgroundColor is UIColor)[class = true, readonly = true]
  (blackColor is UIColor)[class = true, readonly = true]
  (blueColor is UIColor)[class = true, readonly = true]
  (brownColor is UIColor)[class = true, readonly = true]
  (clearColor is UIColor)[class = true, readonly = true]
  (cyanColor is UIColor)[class = true, readonly = true]
  (darkGrayColor is UIColor)[class = true, readonly = true]
  (grayColor is UIColor)[class = true, readonly = true]
  (greenColor is UIColor)[class = true, readonly = true]
  (lightGrayColor is UIColor)[class = true, readonly = true]
  (magentaColor is UIColor)[class = true, readonly = true]
  (orangeColor is UIColor)[class = true, readonly = true]
  (purpleColor is UIColor)[class = true, readonly = true]
  (redColor is UIColor)[class = true, readonly = true]
  (whiteColor is UIColor)[class = true, readonly = true]
  (yellowColor is UIColor)[class = true, readonly = true]
  
proc grayscale*(self: typedesc[UIColor]; white, alpha: CGFloat): UIColor {. importMethod: "colorWithWhite:alpha:" .}
proc hsba*(self: typedesc[UIColor]; hue, saturation, brightness, alpha: CGFloat): UIColor {. importMethod: "colorWithHue:saturation:brightness:alpha:" .}
proc rgba*(self: typedesc[UIColor]; r, g, b, a: CGFloat): UIColor {. importMethod: "colorWithRed:green:blue:alpha:" .}
proc initGrayscale*(self: UIColor; white, alpha: CGFloat): UIColor {. importMethod: "initWithWhite:alpha" .}
proc initHsba*(self: UIColor; hue, saturation, brightness, alpha: CGFloat): UIColor {. importMethod: "initWithHue:saturation:brightness:alpha:" .}
proc initRgba*(self: UIColor; r, g, b, a: CGFloat): UIColor {. importMethod: "initWithRed:green:blue:alpha:" .}
proc named*(self: typedesc[UIColor]; name: NSString): UIColor {. importMethod: "colorNamed:" .}

proc set*(self: UIColor): void {. importMethod: "set" .}
proc setFill*(self: UIColor): void {. importMethod: "setFill" .}
proc setStroke*(self: UIColor): void {. importMethod: "setStroke" .}

# proc getHsba*(self: UIColor; h, s, b, a: ptr CGFloat): Boolean {. importMethod: "getHue:saturation:brightness:alpha:" .}
# proc getRgba*(self: UIColor; r, g, b, a: ptr CGFloat): Boolean {. importMethod: "getRed:blue:green:alpha:" .}
