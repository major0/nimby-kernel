const target {.strdefine.} = hostCPU
const arch {.strdefine.} = "x86_64"
const bootloader {.strdefine.} = "multiboot2"
const fpu {.strdefine.} = "fpu"

when bootloader == "multiboot2" or bootloader == "multiboot1":
  include "boot/multiboot.nim"
