import objc, strutils

{.passL: "-framework Foundation" .}
{.passL: "-framework AppKit" .}
{.passL: "-framework ApplicationServices" .}

const
  NSBorderlessWindowMask  = 0
  NSTitledWindowMask      = 1 shl 0
  NSClosableWindowMask    = 1 shl 1
  NSMiniaturizableWindowMask  = 1 shl 2
  NSResizableWindowMask   = 1 shl 3

var NSApp {.importc.}: Id

type
  NSApplicationActivationPolicy {.size: sizeof(cint).} = enum
    NSApplicationActivationPolicyRegular
    NSApplicationActivationPolicyAccessory
    NSApplicationActivationPolicyProhibited

  CMRect = object
    x, y, w, h: float64

  CMPoint = object
    x, y: float64

proc `@`(a: string): Id =
  objc_msgSend(class"NSString".Id, $$"stringWithUTF8String:", a.cstring)

let NSBackingStoreBuffered = 2.cuint

proc newClass(cls: string): Id =
  objc_msgSend(objc_msgSend(cls.class.Id, $$"alloc"), $$"init")

proc main() =
  discard objc_msgSend(class"NSApplication".Id, $$"sharedApplication")

  if NSApp.isNil:
    echo "Failed to initialized NSApplication...  terminating..."
    return

  discard objc_msgSend(NSApp, $$"setActivationPolicy:", NSApplicationActivationPolicyRegular.cint)

  # Create the menubar
  var menuBar = newClass("NSMenu")
  var appMenuItem = newClass("NSMenuItem")

  discard menuBar.objc_msgSend($$"addItem:", appMenuItem)
  discard NSApp.objc_msgSend($$"setMainMenu:", menuBar)

  var appMenu = newClass("NSMenu")

  var quitTitle = @("Quit ")
  var quitMenuItem = objc_msgSend(class"NSMenuItem".Id, $$"alloc")
  quitMenuItem = objc_msgSend(quitMenuItem,
                              $$"initWithTitle:action:keyEquivalent:",
                              quitTitle, $$"terminate:", @("q"))

  discard appMenu.objc_msgSend($$"addItem:", quitMenuItem)
  discard appMenuItem.objc_msgSend($$"setSubmenu:", appMenu)

  var mainWindow = objc_msgSend(class"NSWindow".Id, $$"alloc")
  var rect = CMRect(x:0,y:0,w:200,h:200)
  discard mainWindow.objc_msgSend($$"initWithContentRect:styleMask:backing:defer:",
    rect, NSTitledWindowMask, NSBackingStoreBuffered, false)

  var pos = CMPoint(x:20,y:20)
  discard mainWindow.objc_msgSend($$"cascadeTopLeftFromPoint:", pos)
  discard mainWindow.objc_msgSend($$"setTitle:", @("Hello"))
  discard mainWindow.objc_msgSend($$"makeKeyAndOrderFront:", NSApp)

  # Bring the app out
  discard objc_msgSend(NSApp, $$("activateIgnoringOtherApps:"), true)
  discard objc_msgSend(NSApp, $$("run"))

main()
