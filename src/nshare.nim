import jester, zipper, logging, datatypes
#from net import getPrimaryIPAddr, `$`
from json import to, parseFile, `%*`, `$`
from os import getAppDir, joinPath, walkDir, lastPathPart, PathComponent, splitFile
#from strutils import removePrefix, format, split, strip, contains, splitLines
from sequtils import mapIt, concat
include "view.tmpl"

let 
  logger = newConsoleLogger()
  appsettings = parseFile(joinPath(getAppDir(), "public/settings.json")).to(Settings)
  directories = concat(
    appsettings.locations.document,
    appsettings.locations.music,
    appsettings.locations.video,
    appsettings.locations.image,
  )

var
  folders, music, images, videos, documents : seq[FileObj]

for dir in directories:

  for folder in walkDir(dir):
    
    let ext = folder.path.splitFile.ext
    case folder.kind:

    of pcDir:
      folders.add(FileObj(name : folder.path.lastPathPart(), path : folder.path, ext : ext))

    of pcFile:

      if dir in appsettings.locations.music and ext in appsettings.extensions.musicext:

        music.add(FileObj(name : folder.path.lastPathPart(), path : folder.path, ext : ext))
      elif dir in appsettings.locations.document and ext in appsettings.extensions.docext:

        documents.add(FileObj(name : folder.path.lastPathPart(), path : folder.path, ext : ext))
      elif dir in appsettings.locations.video and ext in appsettings.extensions.videoext:

        videos.add(FileObj(name : folder.path.lastPathPart(), path : folder.path, ext : ext))
      elif dir in appsettings.locations.image and ext in appsettings.extensions.imageext:

        images.add(FileObj(name : folder.path.lastPathPart(), path : folder.path, ext : ext))
      else:

        continue

    else:
      
      continue

router server:

  get "/":
    resp nshare("js/main", "css/main", "")

  post "/folder":
    resp $(%*(folders))

  post "/music":
    resp $(%*(music))

  post "/image":
    resp $(%*(images))

  post "/video":
    resp $(%*(videos))

  post "/document":
    resp $(%*(documents))


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