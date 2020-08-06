# Package

version       = "0.1.0"
author        = "C_nerd"
description   = "A simple web app for sharing documents between pc's and mobile devices"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nshare"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.0", "jester >= 0.4.0", "zip >= 0.2.0", "ws >= 0.0.1"

task thread, "compiles with thread":
    exec "nim cpp -r --threads:on src/nshare.nim --out:nshare"

task test, "compiles test file":
    exec "nim cpp -r tests/test1.nim --out:nshare"

task linux, "compile a standalone for linux":
    exec "nim cpp -r -l:/usr/lib/x86_64-linux-gnu/libzip.so -d:release --threads:on src/nshare"
    exec "mv src/nshare nshare"

task windows, "compile for windows":
    exec "nim cpp -d:mingw --cpu:i386 -passC: -m32 --cincludes:/usr/include/ --threads:on src/nshare"