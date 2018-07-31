import objc
import objc.foundation

importClass NSString of NSObject

importClass AVMediaType of NSString
importClass AVCaptureDevice of NSObject

proc authorized*(self: typedesc[AVCaptureDevice]; typ: AVMediaType): int {.
  importMethod: "authorizationStatusForMediaType:"
.}

proc requestAuthorization*(self: typedesc[AVCaptureDevice];
                           typ: AVMediaType;
                           handler: proc(granted: bool): void): void {.
  importMethod: "requestAccessForMediaType:completionHandler:"
.}