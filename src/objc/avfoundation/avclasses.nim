import objc
import objc / foundation
import objc / coreanimation / layer

type
  AVMediaType* = NSString
  AVCaptureDeviceType* = NSString
  AVCapturePosition* = enum
    AVCapturePositionUnspecified = 0,
    AVCapturePositionBack = 1,
    AVCapturePositionFront = 2
  AVAuthorizationStatus* = enum
    AVAuthorizationStatusNotDetermined = 0,
    AVAuthorizationStatusRestricted = 1,
    AVAuthorizationStatusDenied = 2,
    AVAuthorizationStatusAuthorized = 3
  AVCaptureFocusMode* = enum
    AVCaptureFocusModeLocked = 0,
    AVCaptureFocusModeAutoFocus = 1,
    AVCaptureFocusModeContinuousAutofocus = 2
  
var
  AVMediaTypeVideo* = $!"AVMediaTypeVideo"
  AVCaptureDeviceTypeBuiltInWideAngleCamera* =
    $!"AVCaptureDeviceTypeBuiltInWideAngleCamera"

importClass AVCaptureVideoPreviewLayer of CALayer
importClass AVCaptureInputPort of NSObject
importClass AVCaptureConnection of NSObject
importClass AVCaptureSession of NSObject

importClass AVCaptureDevice of NSObject
importClass AVCaptureInput of NSObject
importClass AVCaptureOutput of NSObject
importClass AVCaptureVideoDataOutput of AVCaptureOutput
importClass AVCaptureDeviceInput of AVCaptureInput
importClass AVCaptureDeviceInputSource of NSObject