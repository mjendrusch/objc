import objc
import objc.foundation
import objc.avfoundation.captureio

importClass AVCaptureSession of NSObject

proc alloc*(self: typedesc[AVCaptureSession]): AVCaptureSession {. importMethod: "alloc" .}
proc init*(self: AVCaptureSession): AVCaptureSession {. importMethod: "init" .}

proc canAddInput*(self: AVCaptureSession; input: AVCaptureInput): Boolean {. importMethod: "canAddInput:" .}
proc addInput*(self: AVCaptureSession; input: AVCaptureInput): void {. importMethod: "addInput:" .}
proc removeInput*(self: AVCaptureSession; input: AVCaptureInput): void {. importMethod: "removeInput:" .}