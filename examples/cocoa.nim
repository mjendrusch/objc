import objc, foundation, strutils, macros, typetraits, math

type
  NSObject = object of RootObj
    id: Id

  NSWindow = object of NSObject

  NSWindowController = object of NSObject

  NSView = object of NSObject

  NSTextView = object of NSView

  NSString = object of NSObject

  NSApplication = object of NSObject

proc `@`*(a: string): NSString =
  result.id = objc_msgSend(class("NSString").Id,
                           $$"stringWithUTF8String:", a.cstring)

proc objc_alloc(cls: string): Id =
  objc_msgSend(class(cls).Id, $$"alloc")

proc autorelease(obj: NSObject) =
  discard objc_msgSend(obj.id, $$"autorelease")

proc init(x: typedesc[NSWindow]; rect: CMRect; mask, backing: int;
          xdefer: bool): NSWindow =
  var wnd = objc_alloc("NSWindow")
  var cmd = $$"initWithContentRect:styleMask:backing:defer:"
  result.id = wnd.objc_msgSend(cmd, rect, mask.uint64,
                               backing.uint64, Boolean xdefer)

proc init(x: typedesc[NSWindowController],
          window: NSWindow): NSWindowController =
  var ctrl = objc_alloc("NSWindowController")
  result.id = ctrl.objc_msgSend($$"initWithWindow:", window.id)

proc contentView(self: NSWindow, view: NSView) =
  discard objc_msgSend(self.id, $$"setContentView:", view.id)

proc init(x: typedesc[NSTextView], rect: CMRect): NSTextView =
  var view = objc_alloc("NSTextView")
  result.id = view.objc_msgSend($$"initWithFrame:", rect)

proc insertText(self: NSTextView, text: string) =
  discard objc_msgSend(self.id, $$"insertText:", @text.id)

proc call(cls: typedesc, cmd: Selector) =
  discard objc_msgSend(class(cls.name).Id, cmd)

proc `[]`(obj: NSObject, cmd: Selector) =
  discard objc_msgSend(obj.id, cmd)

macro `[]`(id: Id, cmd: Selector, args: varargs[untyped]): untyped =
  if args.len > 0:
    let p = "discard objc_msgSend($1, $2, $3)"
    var z = ""
    for a in args:
      z.add(a.toStrLit().strVal)
    var w = p % [id.toStrLit().strVal, cmd.toStrLit().strVal, z]
    result = parseStmt(w)
  else:
    let p = "discard objc_msgSend($1, $2)"
    var w = p % [id.toStrLit().strVal, cmd.toStrLit().strVal]
    result = parseStmt(w)

type
  AppDelegate = object
    isa: Class
    window: Id

proc shouldTerminate(self: Id, cmd: Selector,
                     notification: Id): Boolean {. cdecl .} =
  var cls  = self.class
  var ivar = cls.ivar("apple")
  var res = cast[int](self.getIvar(ivar))
  echo res

  result = yes

proc makeDelegate(): Class =
  result = newClass(class"NSObject", "AppDelegate", 0)
  discard result.addMethod($$"applicationShouldTerminateAfterLastWindowClosed:",
                           cast[Implementation](shouldTerminate), "c@:@")
  echo result.addIvar("apple", sizeof(int), log2(sizeof(int).float64).int, "q")
  result.register

proc getSuperMethod(id: Id, sel: Selector): Method =
  var superClass  = id.class.super
  result = instanceMethod(superClass, sel)

macro callSuper(id: Id, cmd: Selector, args: varargs[untyped]): untyped =
  let sid  = id.toStrLit().strVal
  let scmd = cmd.toStrLit().strVal
  let mm   = "getSuperMethod($1, $2)" % [sid, scmd]

  if args.len > 0:
    let p = "discard method_invoke($1, $2, $3)"
    var z = ""
    for a in args:
      z.add(a.toStrLit().strVal)
    var w = p % [sid, mm, z]
    echo w
    result = parseStmt(w)
  else:
    let p = "discard method_invoke($1, $2)"
    var w = p % [sid, mm]
    result = parseStmt(w)

proc canBe(self: Id, cmd: Selector): Boolean {. cdecl .} =
  result = yes

proc canBecome(id: Id) =
  var cls = id.class
  var sel = $$"showsResizeIndicator"
  var im  = instanceMethod(cls, sel)
  var types = typeEncoding(im)
  discard replaceMethod(cls, sel, cast[Implementation](canBe), types)

  #sel = $$"canBecomeMainWindow"
  #im  = getInstanceMethod(cls, sel)
  #types = getTypeEncoding(im)
  #discard replaceMethod(cls, sel, cast[IMP](canBe), types)

proc main() =
  var pool = newClass("NSAutoReleasePool")
  NSApplication.call $$"sharedApplication"

  if NSApp.isNil:
    echo "Failed to initialized NSApplication...  terminating..."
    return

  NSApp[$$"setActivationPolicy:", NSApplicationActivationPolicyRegular]

  var windowStyle = NSTitledWindowMask or NSClosableWindowMask or
    NSMiniaturizableWindowMask or NSResizableWindowMask

  var windowRect = NSMakeRect(100,100,400,400)
  var window = NSWindow.init(windowRect, windowStyle,
                             NSBackingStoreBuffered, false)
  window.autorelease()

  #canBecome(window.id)

  #var windowController = NSWindowController.init(window)
  #windowController.autorelease()

  #var textView = NSTextView.init(windowRect)
  #textView.autorelease()
  #textView.insertText("Hello OSX/Cocoa World!")

  #window.contentView(textView)
  #window[$$"orderFrontRegardless"]
  #window.id[$$"makeKeyAndOrderFront:", window.id]
  window.id[$$"setTitle:", @"Hello".id]

  #window.id[$$"setShowsResizeIndicator:", true]
  #echo cast[int](objc_msgSend(window.id, $$"showsResizeIndicator"))
  #echo cast[int](objc_msgSend(window.id, $$"resizeFlags"))

  var AppDelegate = makeDelegate()
  var appDel = newClass("AppDelegate")

  var ivar = AppDelegate.ivar("apple")

  setIvar(appDel, ivar, cast[Id](123))
  NSApp[$$"setDelegate:", appDel]

  window.id[$$"display"]
  window.id[$$"orderFrontRegardless"]
  NSApp[$$"run"]
  pool[$$"drain"]
  AppDelegate.dispose()

main()
