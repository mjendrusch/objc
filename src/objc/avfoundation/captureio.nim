import objc
import objc/foundation
import objc/coreanimation/layer
import avclasses

AVCaptureSession.importProperties:
  sessionPreset is NSString

proc alloc*(self: typedesc[AVCaptureSession]): AVCaptureSession {. importMethod: "alloc" .}
proc init*(self: AVCaptureSession): AVCaptureSession {. importMethod: "init" .}

proc canAddInput*(self: AVCaptureSession; input: AVCaptureInput): Boolean {. importMethod: "canAddInput:" .}
proc addInput*(self: AVCaptureSession; input: AVCaptureInput): void {. importMethod: "addInput:" .}
proc addOutput*(self: AVCaptureSession; otuput: AVCaptureOutput): void {. importMethod: "addOutput:" .}
proc removeInput*(self: AVCaptureSession; input: AVCaptureInput): void {. importMethod: "removeInput:" .}
proc start*(self: AVCaptureSession): void {. importMethod: "startRunning" .}

proc beginConfiguration*(self: AVCaptureSession): void {. importMethod: "beginConfiguration" .}
proc commitConfiguration*(self: AVCaptureSession): void {. importMethod: "commitConfiguration" .}
template configure*(self: AVCaptureSession; body: untyped): untyped =
  self.beginConfiguration
  body
  self.commitConfiguration

proc init*(self: AVCaptureVideoPreviewLayer; session: AVCaptureSession): AVCaptureVideoPreviewLayer {.
  importMethod: "initWithSession:"
.}

proc initNoConnection*(self: AVCaptureVideoPreviewLayer;
                       session: AVCaptureSession): AVCaptureVideoPreviewLayer {.
  importMethod: "initWithSessionWithNoConnection:"
.}

proc withSession*(self: typedesc[AVCaptureVideoPreviewLayer];
                  session: AVCaptureSession): AVCaptureVideoPreviewLayer {.
  importMethod: "layerWithSession:"
.}

proc withSessionNoConnection*(self: typedesc[AVCaptureVideoPreviewLayer];
                              session: AVCaptureSession): AVCaptureVideoPreviewLayer {.
  importMethod: "layerWithSessionWithNoConnection:"
.}

proc session*(self: AVCaptureVideoPreviewLayer): AVCaptureSession {.
  importMethod: "getSession"
.}

proc `session=`*(self: AVCaptureVideoPreviewLayer;
                 session: AVCaptureSession): void {.
  importMethod: "setSession:"
.}

proc `sessionNoConnection=`*(self: AVCaptureVideoPreviewLayer;
                             session: AVCaptureSession): void {.
  importMethod: "setSessionWithNoConnection:"
.}

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

proc isEnabled*(self: AVCaptureConnection): Boolean {.
  importMethod: "isEnabled"
.}

proc isActive*(self: AVCaptureConnection): Boolean {.
  importMethod: "isActive"
.}

proc inputPorts*(self: AVCaptureConnection): NSArray[AVCaptureInputPort] {.
  importMethod: "getInputPorts"
.}

proc output*(self: AVCaptureSession): AVCaptureOutput {.
  importMethod: "getOutput"
.}

proc previewLayer*(self: AVCaptureSession): AVCaptureVideoPreviewLayer {.
  importMethod: "getVideoPreviewLayer"
.}