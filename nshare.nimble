# Package

version       = "0.2.5"
author        = "C-NERD"
description   = "Web app for sharing files via wifi"
license       = "MIT"
srcDir        = "src"
#binDir        = "bin"
bin           = @["nshare"]

backend       = "c"

# Dependencies

requires "nim >= 1.0.0", "jester >= 0.4.0", "zip >= 0.2.0", "webview >= 0.1.0"

task test, "compiles to executable for debugging":
    exec "nim c -d:ssl -o:nshare --threads:on src/nshare"
    exec "nim js -o:public/js/main.js src/frontend/main"

task frontend, "compiles the frontend code to javascript":
    exec "nim js -d:danger -d:release -o:public/js/main.js src/frontend/main"

task make, "compiles with thread":
    exec "nim c -d:ssl -d:danger -d:release -o:bin/nshare --threads:on src/nshare"
    exec "nimble frontend"
    mvDir "public", "bin/public"

task windows, "compiles a standalone executable for windows":
    exec "nim c -d:mingw -d:ssl -d:danger -d:release --cpu:i386 -passC: -m32 --cincludes:/usr/include/ -o:wbin/nshare --threads:on src/nshare"
    exec "nimble frontend"
    mvDir "public", "wbin/public"