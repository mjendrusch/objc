# Package

version       = "0.1.0"
author        = "Andri Lim"
description   = "Wrapper for the Objective-C runtime."
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 0.17.3"

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
