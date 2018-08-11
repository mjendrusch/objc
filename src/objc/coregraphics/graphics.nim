# (c) 2017 Yuriy Glukhov

import objc
import objc/foundation

# when sizeof(pointer) == 8:
#   type CGFloat* = cdouble
# else:
#   type CGFloat* = cfloat


type
  CGPoint* = object
      x*: CGFloat
      y*: CGFloat

  CGSize* = object
      width*: CGFloat
      height*: CGFloat

  CGVector* = object
      dx*: CGFloat
      dy*: CGFloat

  CGRect* = object
      origin*: CGPoint
      size*: CGSize

proc CGPointMake*(x, y: CGFloat): CGPoint {.inline.} =
  result.x = x
  result.y = y

type
  CGFontIndex* = distinct uint16
  CGGlyph* = distinct CGFontIndex

# proc CGFontCreateWithFontName*(name: CFString): CGFont {.importc.}
# proc getGlyphAdvances*(font: CGFont, glyphs: ptr CGGlyph, count: csize, advances: ptr cint): bool {.importc: "CGFontGetGlyphAdvances".}
# proc getGlyphBBoxes*(font: CGFont, glyphs: ptr CGGlyph, count: csize, bboxes: ptr CGRect): bool {.importc: "CGFontGetGlyphBBoxes".}

# proc getAscent*(font: CGFont): cint {.importc: "CGFontGetAscent".}
# proc getDescent*(font: CGFont): cint {.importc: "CGFontGetDescent".}