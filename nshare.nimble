# Package

version       = "0.2.0"
author        = "C_nerd"
description   = "A simple web app for sharing documents between electronic devices via wifi"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nshare"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.0", "jester >= 0.4.0", "zip >= 0.2.0"

task thread, "compiles with thread":
    exec "nim cpp -r -d:ssl --threads:on src/nshare.nim"
    mvFile "src/nshare", "nshare"

task linux, "compiles a standalone executable for linux":
    exec "nim cpp -r -l:/usr/lib/x86_64-linux-gnu/libzip.so -d:release --threads:on src/nshare"
    exec "mv src/nshare nshare"

task windows, "compiles a standalone executable for windows":
    exec "nim cpp -d:mingw --cpu:i386 -passC: -m32 --cincludes:/usr/include/ --threads:on src/nshare"