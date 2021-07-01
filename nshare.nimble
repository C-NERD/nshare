# Package

version       = "0.2.5"
author        = "C-NERD"
description   = "Web app for sharing files via wifi"
license       = "MIT"
srcDir        = "src"
#binDir        = "bin"
bin           = @["nshare"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.0", "jester >= 0.4.0", "zip >= 0.2.0"

task thread, "compiles with thread":
    exec "nim cpp -d:ssl -d:danger -d:release -o:bin/nshare --threads:on src/nshare"
    mvDir "public", "bin/public"

task windows, "compiles a standalone executable for windows":
    exec "nim cpp -d:mingw -d:ssl -d:danger -d:release --cpu:i386 -passC: -m32 --cincludes:/usr/include/ -o:wbin/nshare --threads:on src/nshare"
    mvDir "public", "wbin/public"