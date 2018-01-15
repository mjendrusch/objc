import objc.base, objc.hli, objc.macroCommons
import macros

type
  CanHello* = concept h
    h.helloTest is type(h)
  SafeObjectCanHello* = ref object of Object

template toCanHello*(h: CanHello): SafeObjectCanHello =
  SafeObjectCanHello(id: h.id)

template helloTest*(so: SafeObjectCanHello): type(so) =
  cast[type(so)](objcMsgSend(so.id, $$"helloTest"))
