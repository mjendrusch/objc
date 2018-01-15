import objc.macroCommons, objc.hli, objc.base
import macros

when not defined(objcStrict):
  {. experimental .}
  macro `.()`*(obj: AbstractObject or UnsafeObject, sel: untyped, args: varargs[untyped]): untyped =
    ## Allows to call any method with a valid selector on any given Objective-C
    ## object. This is nice for rapid prototyping purposes, but by no means safe!
    ## It returns an explicitly unsafe ``UnsafeObject``, which may contain anything
    ## or nil in its `id` field, depending on whatever method is passed to it.
    ## Use `-d:objcWarn` to receive warnings when you are actively using this
    ## macro, and `-d:objcStrict` to disallow the use of this macro alltogether.
    if defined(objcWarn):
      warning("Trying to dynamically access Objective-C method with selector: " & $sel.toStrLit)
    let
      selString = sel.toStrLit
    if selString.strVal == "alloc":
      error("Attempting to call `alloc` into `newSharedObject`. " &
            "This would result in memory never being freed. " &
            "Use the `new<Class>` family of procedures instead!")
    if obj.typeKind == ntyTypeDesc:
      if args.len > 0:
        result = quote do:
          UnsafeObject(id: objcMsgSend(`obj`.class.Id, $$`selString`, `args`))
      else:
        result = quote do:
          UnsafeObject(id: objcMsgSend(`obj`.class.Id, $$`selString`))
    else:
      if args.len > 0:
        result = quote do:
          UnsafeObject(id: objcMsgSend(`obj`.id, $$`selString`, `args`))
      else:
        result = quote do:
          UnsafeObject(id: objcMsgSend(`obj`.id, $$`selString`))
