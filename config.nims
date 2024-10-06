var author: string = "Mark Ferrell"
var version: string = "undefined"
var description: string = "NIMBY Kernel"
var license: string = "MIT"

switch("hints", "off")
switch("os", "any")
switch("mm", "none")
switch("opt", "size")
switch("threads", "off")
switch("define", "useMalloc")
switch("define", "noSignalHandler")

include "config/targets.nims"

task build, "Build the kernel":
  setCommand("compile", project="src/kernel.nim")

task showconfig, "Show current configuration":
  for k,v in config:
    echo(k, ": ", v)
