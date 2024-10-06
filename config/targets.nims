from macros import error
import std/strscans
import tables
from std/sequtils import zip


let
  config_fields =[ "target", "arch", "bootloader", "fpu", "endian"]
  config_values = ["unknown"]

var config = initTable[string, string]()

for (k,v) in zip(config_fields, config_values):
  config[k] = v

const target {.strdefine.} = hostCPU
config["target"] = target


# Note: NimScript doesn't have any usable `regex` module that is part of
# the std module distribution. `std/re` and `std/nre` both pass through
# FFI which is not available to NimScript. There is a 3rd party `regex`
# module available, but for now we are hoping to avoid pulling in any 3rd
# party dipendencies, so for now we are using `scanf()`, even though it
# allows for some non-matching inputs.
if @["amd64", "x86_64"].contains(config["target"]):
  include "x86_64/default.nims"
elif (var c: char; @["x86", "i86pc"].contains(config["target"]) or scanf(config["target"], "i$c86", c) or scanf(config["target"], "i80$c86", c)):
  include "x86_32/default.nims"
else:
  error("Do not know how to build for target: " & config["target"])
