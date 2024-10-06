{.passC: "-Isrc/include"}

when bootloader == "multiboot1":
  let
    MULTIBOOT1_HEADER_MAGIC {.importc: "MULTIBOOT_HEADER_MAGIC", header: "multiboot.h" .}: uint32
    MULTIBOOT_PAGE_ALIGN {.importc: "MULTIBOOT_PAGE_ALIGN", header: "multiboot.h" .}: uint32
    MULTIBOOT_VIDEO_MODE {.importc: "MULTIBOOT_VIDEO_MODE", header: "multiboot.h" .}: uint32  

  var multiboot_flags {.importc: "MULTIBOOT_PAGE_ALIGN", header:"multiboot.h" .}: uint32

  when defined framebufffer:
    multiboot_flags |= MULTIBOOT_VIDEO_MODE

  var multiboot_header {.codegenDecl: "[[gnu::section(\".multiboot1_header\")]] $# $#" .} : array[4, uint32] = [
    MULTIBOOT1_HEADER_MAGIC,
    multiboot_flags,
    -(MULTIBOOT1_HEADER_MAGIC + multiboot_flags),
  ]

  # TODO: we need to parse -d:framebuffer=HeightxWidth@Depth
  when defined framebuffer:
    var framebuffer_info {.codegenDecl: "[[gnu::section(\".multiboot1_framebuffer_info\")]] $# $#" .} : array[4, uint32] = [
      framebuffer.mode,
      framebuffer.width,
      framebuffer.height,
      framebuffer.depth
    ]

when bootloader == "multiboot2":
  type multiboot_header {.header: "multiboot2.h", importc: "struct multiboot_header" .} = object
  let
    MULTIBOOT2_HEADER_MAGIC {.importc: "MULTIBOOT2_HEADER_MAGIC", header: "multiboot2.h" .}: uint32
    MULTIBOOT2_ARCHITECTURE_I386 {.importc: "MULTIBOOT2_ARCHITECTURE_I386", header: "multiboot2.h" .}: uint32

  var multiboot2_header {.codegenDecl: "[[gnu::section(\".multiboot2_header\")]] $# $#" .} : array[4, uint32] = [
    MULTIBOOT2_HEADER_MAGIC,
    MULTIBOOT2_ARCHITECTURE_I386,
    cast[uint32](sizeof(multiboot_header)),
    cast[uint32](-1 * (cast[int32](MULTIBOOT2_HEADER_MAGIC + MULTIBOOT2_ARCHITECTURE_I386) + sizeof(multiboot_header))),
  ]

  # TODO: we need to parse -d:framebuffer=HeightxWidth@Depth
  when defined framebuffer:
    type multiboot_header_tag {.header: "multiboot2.h", importc: "struct multiboot2_header_tag" .} = object
    {.emit: """/*MB FB Tags*/
      #include "multiboot2.h"
      [[gnu::section(".multiboot2_fb_tags")]] struct multiboot2_framebuffer_tag {
        multiboot_uint16_t type = MULTIBOOT_TAG_HEADER_FRAMEBUFFER;
        multiboot_uint16_t size = sizeof(struct multiboot2_framebuffer_tag);
        multiboot_uint32_t width = framebuffer.width;
        multiboot_uint32_t height = framebuffer.height;
        multiboot_uint32_t depth = framebuffer.depth;
      }
    """.}


proc multiboot_entry {.exportc: "_multiboot_entry", noreturn, raises: [], codegenDecl: "[[noreturn, gnu::naked, gnu::section(\".multiboot_entry\")]] $# $# $#" .} =
  # TODO map in the multiboot data into our standard kernel structures and then call the kernel main.
  discard

#[ Multiboot1 enters through 32-bit task gate constructed in 16-bit mode
   Our parameters are passed on the stack, which is located in high
   memory.  Before any significant memory use occurs, we must switch it
   down to a proper stack. ]#
proc main {.exportc: "_main", noreturn, raises: [], codegenDecl: "[[noreturn, gnu::naked, gnu::section(\".main\")]] $# $# $#" .} =
  asm """
    jmp _multiboot_entry
  """


proc halt() {.exportc: "_halt", noreturn, raises: [], codegenDecl: "[[noreturn, gnu::nakid, gnu::section(\".halt\")]] $# $# $#" .} =
   asm """
    halt:
    hlt
    jmp halt
  """
