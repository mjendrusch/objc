import objc
import foundation / [nsobject, nsarray, nsstring, nscoder, nsmisc, nsdict,
                     nsbundle]
export nsarray, nsobject, nsstring, nscoder, nsmisc, nsdict, nsbundle

{. passL: "-framework Foundation" .}

proc nslog(x: Id): void {. importc: "NSLog", varargs .}
proc nslog*(x: auto) =
  nslog(($!x).id)
proc nslog*(x: auto; y: varargs[auto]) =
  nslog(x, y)