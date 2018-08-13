import objc
import objc / foundation

importClass DispathQueueAttribute of NSObject
importClass DispatchQueue of NSObject

proc dispatchQueueCreate*(label: cstring; attr: Id): Id {.
  importc: "dispatch_queue_create"
.}

proc newDispatchQueue*(label: string): DispatchQueue =
  newDispatchQueue(dispatchQueueCreate(label, Id(nil)))