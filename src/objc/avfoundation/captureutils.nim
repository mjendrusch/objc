import objc
import objc / foundation
import objc / grandcentral
import avclasses, capturedevice, captureio, deviceinput, deviceoutput

proc getCamera*(position: AVCapturePosition): AVCaptureDevice =
  AVCaptureDevice.default(
    AVCaptureDeviceTypeBuiltInWideAngleCamera,
    AVMediaTypeVideo,
    AVCapturePositionBack
  )

proc getInput*(camera: AVCaptureDevice): AVCaptureDeviceInput =
  var
    error: Id
  result = AVCaptureDeviceInput.create(camera, error.addr)
  if result.id == nil:
    nslog($!"Unable to obtain video device input. ERROR: $@", error)

proc getCaptureSession*(camera: AVCaptureDevice): AVCaptureSession =
  let
    preset = $!"AVCaptureSessionPresetMedium"
  if not bool camera.supports preset:
    nslog($!"Preset not supported by camera: $@", preset)
  result = AVCaptureSession.alloc.init
  result.sessionPreset = preset

proc setOptions*(options: NSDictionary): AVCaptureVideoDataOutput =
  result = AVCaptureVideoDataOutput.alloc.init
  result.videoSettings = options

proc setDelegate(output: AVCaptureVideoDataOutput; delegate: Object;
                 queue: DispatchQueue): void {.
  importMethod: "setSampleBufferDelegate:queue:"
.}

proc `delegate=`*(output: AVCaptureVideoDataOutput; delegate: Object) =
  let
    queue = newDispatchQueue("capture_queue")
  output.setDelegate(delegate, queue)
  output.alwaysDiscardsLateVideoFrames = yes

proc connect*(session: AVCaptureSession; input: AVCaptureDeviceInput;
              output: AVCaptureVideoDataOutput): void =
  configure session:
    session.addInput input
    session.addOutput output
  session.start

proc sessionWithDelegate*(delegate: Object;
                          position: AVCapturePosition = AVCapturePositionBack;
                          options: NSDictionary = newNSDictionary(Id(nil))) =
  let
    camera = getCamera(position)
    input = camera.getInput
    output = options.setOptions
    session = camera.getCaptureSession
  output.delegate = delegate
  session.connect input, output
  