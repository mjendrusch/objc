# Package

version       = "0.1.0"
author        = "Michael Jendrusch"
license       = "MIT"
description   = "Wrapper for the Objective-C runtime."
srcDir        = "src"

# Dependencies

requires "nim >= 0.18.1"

# Configuration

proc testDebugConfig() =
  --define: debug
  --define: objcStrict
  --path: "../src"
  --run

proc testReleaseConfig() =
  --define: release
  --path: "../src"
  --run

# Tasks

task test, "run objc tests":
  testDebugConfig()
  setCommand "c", "tests/tall.nim"

task testRelease, "run objc tests in release mode":
  testReleaseConfig()
  setCommand "c", "tests/tall.nim"
