import jester, zipper
#from net import getPrimaryIPAddr, `$`
#from strutils import removePrefix, format, split, strip, contains, splitLines
from sequtils import mapIt
include "view.tmpl"

when isMainModule:
  routes:

    get "/":
      resp nshare("js/main.js", "css/main.css", "")
