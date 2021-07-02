import jester, zipper, logging
from net import getPrimaryIPAddr, `$`
#from strutils import removePrefix, format, split, strip, contains, splitLines
#from sequtils import mapIt
include "view.tmpl"

let logger = newConsoleLogger()

router server:

  get "/":
    resp nshare("js/main", "css/main", "")


proc main() =
  try:

    let
      port = Port(5000)
      settings = newSettings(port = port)#, bindAddr = $getPrimaryIPAddr())

    var jester = initJester(server, settings)
    jester.serve()
  except:

    logger.log(lvlNotice, "Your wifi is not connected")
    quit(0)
  
when isMainModule:
  main()