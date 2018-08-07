import objc

{. passL: "-framework Foundation" .}

let
  classList = classes()

for class in classList:
  let
    methods = class.methods
    ivars = class.ivars
  echo class.name
  for mtd in methods:
    echo "  ", mtd.name
    let
      num = mtd.argsLen
    for arg in 0 ..< num:
      echo "    ", mtd.argumentType(arg)
  for ivar in ivars:
    echo "  ", ivar.name, " : ", ivar.typeEncoding.decodeTypeString
