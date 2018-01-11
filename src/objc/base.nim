const objcLibName* = "libobjc.A.dylib"

{. pragma: objcImport, cdecl, importc, dynlib: objcLibName .}
{. pragma: objcCallback, cdecl .}

when defined(cpu64):
  type
    CGFloat* = cdouble
    NSInteger* = clong
    NSUInteger* = culong
else:
  type
    CGFloat* = cfloat
    NSInteger* = cint
    NSUInteger* = cuint

type
  Class* = distinct pointer
  Method* = distinct pointer
  Ivar* = distinct pointer
  Category* = distinct pointer
  Protocol* = distinct pointer
  Id* = distinct pointer
  Selector* = distinct pointer
  Str* = ptr cchar
  Arith* = cint
  UArith* = cuint
  PtrDiff* = int
  Boolean* = cchar

  MethodDescription* = object
    name*: Selector
    types*: string

  Property* = distinct pointer

  Super* = object
    receiver*: Id
    superClass*: Class

  PropertyAttribute* = object
    name*: string
    value*: string

  ExceptionFunctions* = object
    version*: cint
    throw_exc*: proc(id: Id) {.objccallback.}
    try_enter*: proc(p: pointer) {.objccallback.}
    try_exit*: proc(p: pointer) {.objccallback.}
    extract*: proc(p: pointer): Id {.objccallback.}
    match*: proc(class: Class, id: Id): cint {.objccallback.}

  Implementation* = proc(id: Id, selector: Selector): Id {.cdecl, varargs.}

  objc_AssociationPolicy* {.size: sizeof(cuint).} = enum
    OBJC_ASSOCIATION_ASSIGN = 0
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3
    OBJC_ASSOCIATION_RETAIN = 01401
    OBJC_ASSOCIATION_COPY = 01403
  EnumerationHandler* = proc(a2: Id) {.objccallback.}

const
  yes* = Boolean(1)
  no*  = Boolean(0)

proc isNil*(a: Class): bool =
  result = a.pointer == nil

proc isNil*(a: Id): bool =
  result = a.pointer == nil

proc class_getName*(cls: Class): cstring {. objcimport .}
proc class_getSuperclass*(cls: Class): Class {. objcimport .}
proc class_isMetaClass*(cls: Class): Boolean {. objcimport .}
proc class_getInstanceSize*(cls: Class): csize {. objcimport .}
proc class_getInstanceVariable*(cls: Class; name: cstring): Ivar {. objcimport .}
proc class_getClassVariable*(cls: Class; name: cstring): Ivar {. objcimport .}
proc class_addIvar*(cls: Class; name: cstring; size: csize; alignment: uint8; types: cstring): Boolean {. objcimport .}
proc class_copyIvarList*(cls: Class; outCount: var cuint): ptr Ivar {. objcimport .}
proc class_getIvarLayout*(cls: Class): ptr uint8 {. objcimport .}
proc class_getWeakIvarLayout*(cls: Class): ptr uint8 {. objcimport .}
proc class_setIvarLayout*(cls: Class; layout: ptr uint8) {. objcimport .}
proc class_setWeakIvarLayout*(cls: Class; layout: ptr uint8) {. objcimport .}
proc class_getProperty*(cls: Class; name: cstring): Property {. objcimport .}
proc class_copyPropertyList*(cls: Class, outCount: var cuint): ptr Property {. objcimport .}
proc class_addMethod*(cls: Class; name: Selector; imp: Implementation; types: cstring): Boolean {. objcimport .}
proc class_getInstanceMethod*(cls: Class; name: Selector): Method {. objcimport .}
proc class_getClassMethod*(cls: Class; name: Selector): Method {. objcimport .}
proc class_copyMethodList*(cls: Class; outCount: var cuint): ptr Method {. objcimport .}
proc class_replaceMethod*(cls: Class; name: Selector; imp: Implementation; types: cstring): Implementation {. objcimport .}
proc class_getMethodImplementation*(cls: Class; name: Selector): Implementation {. objcimport .}
proc class_getMethodImplementation_stret*(cls: Class; name: Selector): Implementation {. objcimport .}
proc class_respondsToSelector*(cls: Class; sel: Selector): Boolean {. objcimport .}
proc class_addProtocol*(cls: Class; protocol: Protocol): Boolean {. objcimport .}
proc class_addProperty*(cls: Class; name: cstring;
                        attributes: ptr PropertyAttribute;
                        attributeCount: cuint): Boolean {. objcimport .}
proc class_replaceProperty*(cls: Class; name: cstring;
                            attributes: ptr PropertyAttribute;
                            attributeCount: cuint) {. objcimport .}
proc class_conformsToProtocol*(cls: Class; protocol: Protocol): Boolean {. objcimport .}
proc class_copyProtocolList*(cls: Class; outCount: var cuint): ptr Protocol {. objcimport .}
proc class_getVersion*(cls: Class): cint {. objcimport .}
proc class_setVersion*(cls: Class; version: cint) {. objcimport .}
proc objc_getFutureClass*(name: cstring): Class {. objcimport .}
proc objc_allocateClassPair*(superclass: Class, name: cstring, extraBytes: csize): Class {. objcimport .}
proc objc_disposeClassPair*(cls: Class) {. objcimport .}
proc objc_registerClassPair*(cls: Class) {. objcimport .}
proc objc_duplicateClass*(original: Class; name: cstring; extraBytes: csize): Class {. objcimport .}
proc class_createInstance*(cls: Class; extraBytes: csize): Id {. objcimport .}
proc objc_constructInstance*(cls: Class; bytes: pointer): Id {. objcimport .}
proc objc_destructInstance*(obj: Id): pointer {. objcimport .}
proc object_copy*(obj: Id; size: csize): Id {. objcimport .}
proc object_setInstanceVariable*(obj: Id; name: cstring; value: pointer): Ivar {. objcimport .}
proc object_getInstanceVariable*(obj: Id; name: cstring; outValue: var pointer): Ivar {. objcimport .}
proc object_getIndexedIvars*(obj: Id): pointer {. objcimport .}
proc object_getIvar*(obj: Id; ivar: Ivar): Id {. objcimport .}
proc object_setIvar*(obj: Id; ivar: Ivar; value: Id) {. objcimport .}
proc object_getClassName*(obj: Id): cstring {. objcimport .}
proc objc_getClass*(name: cstring): Class {. objcimport .}
proc object_setClass*(obj: Id; cls: Class): Class {. objcimport .}
proc objc_getClassList*(buffer: ptr Class; bufferCount: cint): cint {. objcimport .}
proc objc_copyClassList*(outCount: var cuint): ptr Class {. objcimport .}
proc objc_lookUpClass*(name: cstring): Class {. objcimport .}
proc object_getClass*(obj: Id): Class {. objcimport .}
proc objc_getRequiredClass*(name: cstring): Class {. objcimport .}
proc objc_getMetaClass*(name: cstring): Class {. objcimport .}
proc ivar_getName*(v: Ivar): cstring {. objcimport .}
proc ivar_getTypeEncoding*(v: Ivar): cstring {. objcimport .}
proc ivar_getOffset*(v: Ivar): PtrDiff {. objcimport .}
proc objc_setAssociatedObject*(obj: Id; key: pointer; value: Id; policy: objc_AssociationPolicy) {. objcimport .}
proc objc_getAssociatedObject*(obj: Id; key: pointer): Id {. objcimport .}
proc objc_removeAssociatedObjects*(obj: Id) {. objcimport .}
proc objc_msgSend*(self: Id; op: Selector): Id {.objcimport,varargs.}
proc objc_msgSend_fpret*(self: Id; op: Selector): cdouble {.objcimport,varargs.}
proc objc_msgSend_stret*(self: Id; op: Selector) {.objcimport,varargs.}
proc objc_msgSendSuper*(super: var Super; op: Selector): Id {.objcimport,varargs.}
proc objc_msgSendSuper_stret*(super: var Super; op: Selector) {.objcimport,varargs.}
proc method_invoke*(receiver: Id; m: Method): Id {.objcimport,varargs.}
proc method_invoke_stret*(receiver: Id; m: Method) {.objcimport,varargs.}
proc sel_getName*(sel: Selector): cstring {. objcimport .}
proc sel_registerName*(str: cstring): Selector {. objcimport .}
proc sel_getUid*(str: cstring): Selector {. objcimport .}
proc sel_isEqual*(lhs: Selector; rhs: Selector): Boolean {. objcimport .}
proc method_getName*(m: Method): Selector {. objcimport .}
proc method_getImplementation*(m: Method): Implementation {. objcimport .}
proc method_getTypeEncoding*(m: Method): cstring {. objcimport .}
proc method_copyReturnType*(m: Method): cstring {. objcimport .}
proc method_copyArgumentType*(m: Method; index: cuint): cstring {. objcimport .}
proc method_getReturnType*(m: Method; dst: cstring; dst_len: csize) {. objcimport .}
proc method_getNumberOfArguments*(m: Method): cuint {. objcimport .}
proc method_getArgumentType*(m: Method; index: cuint; dst: cstring; dst_len: csize) {. objcimport .}
proc method_getDescription*(m: Method): ptr MethodDescription {. objcimport .}
proc method_setImplementation*(m: Method; imp: Implementation): Implementation {. objcimport .}
proc method_exchangeImplementations*(m1: Method; m2: Method) {. objcimport .}
proc objc_copyImageNames*(outCount: var cuint): cstringArray {. objcimport .}
proc class_getImageName*(cls: Class): cstring {. objcimport .}
proc objc_copyClassNamesForImage*(image: cstring; outCount: var cuint): cstringArray {. objcimport .}
proc objc_getProtocol*(name: cstring): Protocol {. objcimport .}
proc objc_copyProtocolList*(outCount: var cuint): ptr Protocol {. objcimport .}
proc objc_allocateProtocol*(name: cstring): Protocol {. objcimport .}
proc objc_registerProtocol*(proto: Protocol) {. objcimport .}
proc protocol_addMethodDescription*(proto: Protocol; name: Selector; types: cstring;
                                   isRequiredMethod, isInstanceMethod: Boolean) {. objcimport .}
proc protocol_addProtocol*(proto, addition: Protocol) {. objcimport .}
proc protocol_addProperty*(proto: Protocol; name: cstring;
                          attributes: ptr PropertyAttribute;
                          attributeCount: cuint; isRequiredProperty: Boolean;
                          isInstanceProperty: Boolean) {. objcimport .}
proc protocol_getName*(p: Protocol): cstring {. objcimport .}
proc protocol_isEqual*(proto, other: Protocol): Boolean {. objcimport .}
proc protocol_copyMethodDescriptionList*(p: Protocol; isRequiredMethod, isInstanceMethod: Boolean;
  outCount: var cuint): ptr MethodDescription {. objcimport .}
proc protocol_getMethodDescription*(p: Protocol; aSel: Selector;
  isRequiredMethod, isInstanceMethod: Boolean): MethodDescription {. objcimport .}
proc protocol_copyPropertyList*(proto: Protocol; outCount: var cuint): ptr Property {. objcimport .}
proc protocol_getProperty*(proto: Protocol; name: cstring; isRequiredProperty, isInstanceProperty: Boolean): Property {. objcimport .}
proc protocol_copyProtocolList*(proto: Protocol, outCount: var cuint): ptr Protocol {. objcimport .}
proc protocol_conformsToProtocol*(proto, other: Protocol): Boolean {. objcimport .}
proc property_getName*(property: Property): cstring {. objcimport .}
proc property_getAttributes*(property: Property): cstring {. objcimport .}
proc property_copyAttributeList*(property: Property; outCount: var cuint): ptr PropertyAttribute {. objcimport .}
proc property_copyAttributeValue*(property: Property; attributeName: cstring): cstring {. objcimport .}
proc objc_enumerationMutation*(obj: Id) {. objcimport .}
proc objc_setEnumerationMutationHandler*(handler: EnumerationHandler) {. objcimport .}
proc imp_implementationWithBlock*(blok: Id): Implementation {. objcimport .}
proc imp_getBlock*(anImp: Implementation): Id {. objcimport .}
proc imp_removeBlock*(anImp: Implementation): Boolean {. objcimport .}
proc objc_loadWeak*(location: var Id): Id {. objcimport .}
proc objc_storeWeak*(location: var Id; obj: Id): Id {. objcimport .}
proc object_dispose*(obj: Id): Id {. objcimport .}
