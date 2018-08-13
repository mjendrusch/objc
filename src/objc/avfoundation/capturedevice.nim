import objc
import objc / foundation
import avclasses

AVCaptureDevice.importProperties:
  focusMode is AVCaptureFocusMode

proc default*(self: typedesc[AVCaptureDevice]; typ: AVCaptureDeviceType;
              media: AVMediaType; position: AVCapturePosition): AVCaptureDevice {.
  importMethod: "defaultDeviceWithDeviceType:mediaType:position:"              
.}
proc device*(self: typedesc[AVCaptureDevice]; id: NSString): AVCaptureDevice {.
  importMethod: "deviceWithUniqueId:"
.}
proc default*(self: typedesc[AVCaptureDevice]; media: AVMediaType): AVCaptureDevice {.
  importMethod: "defaultDeviceWithMediaType:"
.}

proc supports*(self: AVCaptureDevice; preset: NSString): Boolean {.
  importMethod: "supportsAVCaptureSessionPreset:"
.}

proc authorized*(self: typedesc[AVCaptureDevice]; typ: AVMediaType): AVAuthorizationStatus {.
  importMethod: "authorizationStatusForMediaType:"
.}

proc requestAuthorization*(self: typedesc[AVCaptureDevice];
                           typ: AVMediaType;
                           handler: proc(granted: bool): void): void {.
  importMethod: "requestAccessForMediaType:completionHandler:"
.}

proc lockForConfig*(self: AVCaptureDevice; error: ptr Id): Boolean {.
  importMethod: "lockForConfiguration:"
.}
proc unlockForConfig*(self: AVCaptureDevice): void {.
  importMethod: "unlockForConfiguration"
.}

template configure*(self: AVCaptureDevice; body: untyped): untyped =
  var
    error: Id
  self.lockForConfig error.addr
  body
  self.unlockForConfig
