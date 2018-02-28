import objc

template toIdPointer*[T: AbstractObject](x: varargs[T]): tuple[p: pointer, l: cuint] =
  ## Converts a ``varargs`` to a ``tuple`` of an address and a length.
  ## This is a facility to simplify the wrapping of variadic methods.
  when defined(manualMode):
    (pointer x[0].unsafeAddr, cuint x.len)
  else:
    var
      sq = newSeqOfCap[Id](x.len)
    for elem in x:
      sq.add elem.id
    (pointer sq[0].unsafeAddr, cuint sq.len)
