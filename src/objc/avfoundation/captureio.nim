import objc
import objc.foundation

importClass AVCaptureVideoPreviewLayer of NSObject
importClass AVCaptureInputPort of NSObject
importClass AVCaptureConnection of NSObject
importClass AVCaptureInput of NSObject
importClass AVCaptureOutput of NSObject

proc connect*(self: typedesc[AVCaptureConnection];
              inputs: NSArray[AVCaptureInputPort];
              output: AVCaptureOutput): AVCaptureConnection {.
  importMethod: "connectionWithInputPorts:output:"              
.}

proc init*(self: AVCaptureConnection;
           inputs: NSArray[AVCaptureInputPort];
           output: AVCaptureOutput): AVCaptureConnection {.
  importMethod: "initWithInputPorts:output:"
.}

proc connect*(self: typedesc[AVCaptureConnection];
              input: AVCaptureInputPort;
              layer: AVCaptureVideoPreviewLayer): AVCaptureConnection {.
  importMethod: "connectionWithInput:videoPreviewLayer:"              
.}