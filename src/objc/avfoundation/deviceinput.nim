import objc
import objc / foundation
import avclasses

AVCaptureInput.importProperties:
  (ports is NSArray[AVCaptureInputPort])[readonly = true]

AVCaptureDeviceInput.importProperties:
  (device is AVCaptureDevice)[readonly = true]

proc create*(self: typedesc[AVCaptureDeviceInput]; device: AVCaptureDevice;
             error: ptr Id): AVCaptureDeviceInput {.
  importMethod: "deviceInputWithDevice:error:"             
.}
proc init*(self: AVCaptureDeviceInput; device: AVCaptureDevice;
           error: ptr Id): AVCaptureDeviceInput {.
  importMethod: "initWithDevice:error:"           
.}