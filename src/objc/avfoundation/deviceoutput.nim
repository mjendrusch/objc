import objc
import objc / foundation
import avclasses

AVCaptureVideoDataOutput.importProperties:
  videoSettings is NSDictionary
  alwaysDiscardsLateVideoFrames is Boolean

proc alloc*(self: typedesc[AVCaptureVideoDataOutput]): AVCaptureVideoDataOutput {.
  importMethod: "alloc"
.}
proc init*(self: AVCaptureVideoDataOutput): AVCaptureVideoDataOutput {.
  importMethod: "init"
.}