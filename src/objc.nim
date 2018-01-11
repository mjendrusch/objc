import objc.base, objc.cutils
export base

proc name*(cls: Class): string =
  result = $class_getName(cls)

proc `$`*(cls: Class): string =
    name(cls)

template super*(cls: Class): untyped =
  class_getSuperClass(cls)

template isMetaClass*(cls: Class): untyped =
  class_isMetaClass(cls)

proc getInstanceSize*(cls: Class): int = class_getInstanceSize(cls)

template ivar*(cls: Class, name: string): untyped =
  class_getInstanceVariable(cls, name.cstring)

template classVar*(cls: Class; name: string): untyped =
  class_getClassVariable(cls, name.cstring)

proc addIvar*(cls: Class; name: string; size: int;
              alignment: int; types: string): bool =
  class_addIvar(cls, name.cstring, size.csize, alignment.uint8,
                types.cstring) == yes

proc ivars*(cls: Class): seq[Ivar] =
  var
    count = 0.cuint
    ivars = class_copyIvarList(cls, count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[Ivar](count)
  copyMem(result[0].addr, ivars, sizeof(Ivar) * count.int)
  c_free(ivars)

template property*(cls: Class; name: string): untyped =
  class_getProperty(cls, name.cstring)

proc properties*(cls: Class): seq[Property] =
  var
    count = 0.cuint
    props = class_copyPropertyList(cls, count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[Property](count)
  copyMem(result[0].addr, props, sizeof(Property) * count.int)
  c_free(props)

template addMethod*(cls: Class; name: Selector; imp: Implementation;
                    types: string): untyped =
  class_addMethod(cls, name, imp, types.cstring)

template instanceMethod*(cls: Class; name: Selector): untyped =
  class_getInstanceMethod(cls, name)

template classMethod*(cls: Class; name: Selector): untyped =
  class_getClassMethod(cls, name)

proc methods*(cls: Class): seq[Method] =
  var
    count = 0.cuint
    procs = class_copyMethodList(cls, count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[Method](count)
  copyMem(result[0].addr, procs, sizeof(Method) * count.int)
  c_free(procs)

template replaceMethod*(cls: Class; name: Selector; imp: Implementation;
                        types: string): untyped =
  class_replaceMethod(cls, name, imp, types.cstring)

template methodImpl*(cls: Class; name: Selector): untyped =
  class_getMethodImplementation(cls, name)

template respondsTo*(cls: Class; sel: Selector): untyped =
  class_respondsToSelector(cls, sel)

template addProtocol*(cls: Class; protocol: Protocol): untyped =
  class_addProtocol(cls, protocol)


proc addProperty*(cls: Class; name: string;
                  attributes: openArray[PropertyAttribute]): bool =
  class_addProperty(cls, name.cstring, attributes[0].unsafeAddr,
                    attributes.len.cuint) == yes

proc replaceProperty*(cls: Class; name: string;
                      attributes: openArray[PropertyAttribute]) =
  class_replaceProperty(cls, name.cstring, attributes[0].unsafeAddr,
                        attributes.len.cuint)

template conformsTo*(cls: Class; protocol: Protocol): bool =
  class_conformsToProtocol(cls, protocol) == yes

template `<:`*(cls: Class; protocol: Protocol): bool = cls.conformsTo protocol

proc protocols*(cls: Class): seq[Protocol] =
  var
    count = 0.cuint
    prots = class_copyProtocolList(cls, count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[Protocol](count)
  copyMem(result[0].addr,  prots, sizeof(Protocol) * count.int)
  c_free(prots)

template version*(cls: Class): untyped =
  class_getVersion(cls).int

template `version=`*(cls: Class; version: int) =
  class_setVersion(cls, version.cint)

template futureClass*(name: string): untyped =
  objc_getFutureClass(name.cstring)

template newClass*(superclass: Class, name: string, extraBytes: int): untyped =
  objc_allocateClassPair(superclass, name.cstring, extrabytes.csize)

template dispose*(cls: Class) =
  objc_disposeClassPair(cls)

template register*(cls: Class) =
  objc_registerClassPair(cls)

template duplicate*(original: Class; name: string; extraBytes: int): untyped =
  objc_duplicateClass(original, name.cstring, extraBytes.csize)

template createInstance*(cls: Class; extraBytes: csize): untyped =
  class_createInstance(cls, extraBytes.csize)

template constructInstance*(cls: Class; bytes: pointer): untyped =
  objc_constructInstance(cls, bytes)

template destructInstance*(obj: Id): untyped =
  objc_destructInstance(obj)

template copy*(obj: Id; size: csize): untyped =
  object_copy(obj, size.csize)

template dispose*(obj: Id): untyped =
  object_dispose(obj)

template setInstanceVariable*(obj: Id; name: string; value: pointer): untyped =
  object_setInstanceVariable(obj, name.cstring, value)

template getInstanceVariable*(obj: Id; name: string;
                              outValue: var pointer): untyped =
  object_getInstanceVariable(obj, name.cstring, outValue)

template getIndexedIvars*(obj: Id): untyped =
  object_getIndexedIvars(obj)

template getIvar*(obj: Id; ivar: Ivar): untyped =
  object_getIvar(obj, ivar)

template setIvar*(obj: Id; ivar: Ivar; value: Id) =
  object_setIvar(obj, ivar, value)

proc className*(obj: Id): string =
  result = $object_getClassName(obj)

template class*(name: string): untyped =
  objc_getClass(name.cstring)

template `class=`*(obj: Id; cls: Class): untyped =
  object_setClass(obj, cls)

proc classes*(): seq[Class] =
  let count = objc_getClassList(nil, 0.cint)
  if count == 0:
    result = @[]
    return result
  result = newSeq[Class](count)
  discard objc_getClassList(result[0].addr, result.len.cint)

proc copyClasses*(): seq[Class] =
  var
    count = 0.cuint
    classes = objc_copyClassList(count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[Class](count)
  copyMem(result[0].addr,  classes, sizeof(Class) * count.int)
  c_free(classes)

template lookUpClass*(name: cstring): untyped =
  objc_lookUpClass(name.cstring)

template class*(obj: Id): untyped =
  object_getClass(obj)

template requiredClass*(name: string): untyped =
  objc_getRequiredClass(name.cstring)

template metaClass*(name: string): untyped =
  objc_getMetaClass(name.cstring)

template name*(v: Ivar): untyped =
  $ivar_getName(v)

proc `$`*(v: Ivar): string =
  name(v)

template typeEncoding*(v: Ivar): untyped =
  $ivar_getTypeEncoding(v)

template offset*(v: Ivar): untyped =
  ivar_getOffset(v)

template setAssociatedObject*(obj: Id; key: pointer; value: Id;
                              policy: objc_AssociationPolicy) =
  objc_setAssociatedObject(obj, key, value, policy)

template associatedObject*(obj: Id; key: pointer): untyped =
  objc_getAssociatedObject(obj, key)

template removeAssociatedObjects*(obj: Id) =
  objc_removeAssociatedObjects(obj)

template name*(sel: Selector): untyped =
  $sel_getName(sel)

proc `$`*(sel: Selector): string =
  name(sel)

template registerName*(str: string): untyped =
  sel_registerName(str.cstring)

proc `$$`*(str: string): Selector =
  sel_registerName(str.cstring)

template getUid*(str: string): untyped =
  sel_getUid(str.cstring)

template isEqual*(lhs, rhs: Selector): untyped =
  sel_isEqual(lhs, rhs)

template name*(m: Method): untyped =
  $method_getName(m)

proc `$`*(m: Method): string =
  name(m)

template implementation*(m: Method): untyped =
  method_getImplementation(m)

template typeEncoding*(m: Method): untyped =
  $method_getTypeEncoding(m)

proc copyReturnType*(m: Method): string =
  var ret = method_copyReturnType(m)
  result = $ret
  c_free(ret)

proc copyArgumentType*(m: Method; index: int): string =
  var ret = method_copyArgumentType(m, index.cuint)
  result = $ret
  c_free(ret)

proc returns*(m: Method): string =
  var ret: array[100, char]
  method_getReturnType(m, cast[cstring](ret[0].addr), sizeof(ret))
  result = $(cast[cstring](ret[0].addr))

template argsLen*(m: Method): untyped =
  method_getNumberOfArguments(m).int

proc argumentType*(m: Method; index: int): string =
  var ret: array[100, char]
  method_getArgumentType(m, index.cuint, cast[cstring](ret[0].addr),
                         sizeof(ret))
  result = $(cast[cstring](ret[0].addr))

proc argumentTypes*(m: Method): seq[string] =
  let count = m.argsLen
  result = newSeq[string](count)
  if count == 0:
    result = @[]
    return result
  for i in 0 ..< count:
    result[i] = argumentType(m, i)

proc description*(m: Method): MethodDescription =
  var p = method_getDescription(m)
  result.name = p.name
  result.types = $p.types

template `implementation=`*(m: Method; imp: Implementation): untyped =
  method_setImplementation(m, imp)

template swapImplementations*(m1: Method; m2: Method) =
  method_exchangeImplementations(m1, m2)

proc imageNames*(): seq[string] =
  var
    count = 0.cuint
    images = objc_copyImageNames(count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[string](count.int)
  for i in 0 ..< result.len:
    result[i] = $images[i]

template imageName*(cls: Class): untyped =
  $class_getImageName(cls)

proc classNamesForImage*(image: string): seq[string] =
  var
    count = 0.cuint
    classes = objc_copyClassNamesForImage(image.cstring, count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[string](count.int)
  for i in 0 ..< result.len:
    result[i] = $classes[i]

template protocol*(name: string): untyped =
  objc_getProtocol(name.cstring)

proc protocols*(): seq[Protocol] =
  var
    count = 0.cuint
    prots = objc_copyProtocolList(count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[Protocol](count.int)
  copyMem(result[0].addr, prots, result.len * sizeof(Protocol))
  c_free(prots)

template newProtocol*(name: string): untyped =
  objc_allocateProtocol(name.cstring)

template registerProtocol*(proto: Protocol) =
  objc_registerProtocol(proto)


template addMethodDescription*(proto: Protocol; name: Selector; types: string;
                               isRequiredMethod, isInstanceMethod: bool) =
  protocol_addMethodDescription(proto, name, types.cstring, isRequiredMethod,
                                isInstanceMethod)

template addProtocol*(proto, addition: Protocol) =
  protocol_addProtocol(proto, addition)

proc addProperty*(proto: Protocol; name: string;
                  attributes: openArray[PropertyAttribute],
                  isRequiredProperty, isInstanceProperty: bool) =
  protocol_addProperty(proto, name, attributes[0].unsafeAddr,
                       attributes.len.cuint, Boolean isRequiredProperty,
                       Boolean isInstanceProperty)

template name*(p: Protocol): untyped =
  $protocol_getName(p)

proc `$`*(p: Protocol): string =
  name(p)

template `==`*(proto, other: Protocol): untyped =
  protocol_isEqual(proto, other)

proc methodDescriptions*(p: Protocol; isRequiredMethod,
                         isInstanceMethod: bool): seq[MethodDescription] =
  type
    DescT {.unchecked.} = array[0..0, MethodDescription]
  var
    count = 0.cuint
    raw   = protocol_copyMethodDescriptionList(p, Boolean isRequiredMethod,
                                               Boolean isInstanceMethod, count)
    descs = cast[DescT](raw)
  if count == 0:
    result = @[]
    return result
  result = newSeq[MethodDescription](count.int)
  for i in 0 ..< count.int:
    result[i] = MethodDescription(name: descs[i].name, types: $descs[i].types)
  c_free(raw)

template methodDescription*(p: Protocol; aSel: Selector;
                            isRequiredMethod, isInstanceMethod: bool): untyped =
  protocol_getMethodDescription(p, aSel, isRequiredMethod, isInstanceMethod)

proc properties*(proto: Protocol): seq[Property] =
  var
    count = 0.cuint
    props = protocol_copyPropertyList(proto, count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[Property](count.int)
  copyMem(result[0].addr, props, result.len * sizeof(Property))
  c_free(props)

template property*(proto: Protocol; name: string;
                   isRequiredProperty, isInstanceProperty: bool): untyped =
  protocol_getProperty(proto, name.cstring, Boolean isRequiredProperty,
                       Boolean isInstanceProperty)

proc protocols*(proto: Protocol): seq[Protocol] =
  var
    count = 0.cuint
    prots = protocol_copyProtocolList(proto, count)
  if count == 0:
    result = @[]
    return result
  result = newSeq[Protocol](count.int)
  copyMem(result[0].addr, prots, result.len * sizeof(Protocol))
  c_free(prots)

template conformsTo*(proto, other: Protocol): untyped =
  protocol_conformsToProtocol(proto, other)

template `<:`*(proto, other: Protocol): untyped = proto.conformsTo other

template name*(property: Property): untyped =
  $property_getName(property)

proc `$`*(property: Property): string =
  name(property)

template attributeString*(property: Property): untyped =
  $property_getAttributes(property)

proc attributes*(property: Property): seq[PropertyAttribute] =
  type AttrT {.unchecked.} = array[0..0, PropertyAttribute]
  var
    count = 0.cuint
    raw   = property_copyAttributeList(property, count)
    attrs = cast[AttrT](raw)
  if count == 0:
    result = @[]
    return result
  result = newSeq[PropertyAttribute](count.int)
  for i in 0 ..< count.int:
    result[i] = PropertyAttribute(name: $attrs[i].name, value: $attrs[i].value)
  c_free(raw)

proc attributeValue*(property: Property; attributeName: string): string =
  var res = property_copyAttributeValue(property, attributeName.cstring)
  result = $res
  c_free(res)

template enumerationMutation*(obj: Id) =
  objc_enumerationMutation(obj)

template setEnumerationMutationHandler*(handler: EnumerationHandler) =
  objc_setEnumerationMutationHandler(handler)

template implementationWithBlock*(blok: Id): untyped =
  imp_implementationWithBlock(blok)

template getBlock*(anImp: Implementation): untyped =
  imp_getBlock(anImp)

template removeBlock*(anImp: Implementation): untyped =
  imp_removeBlock(anImp)

template loadWeak*(location: var Id): untyped =
  objc_loadWeak(location)

template storeWeak*(location: var Id; obj: Id): untyped =
  objc_storeWeak(location, obj)
