import jester, zipper, logging, datatypes
#from net import getPrimaryIPAddr, `$`
from json import to, parseFile, `%*`, `$`, `%`
from os import getAppDir, joinPath, walkDir, lastPathPart, PathComponent, splitFile
#from strutils import removePrefix, format, split, strip, contains, splitLines
from sequtils import mapIt, concat
include "view.tmpl"

type

  FileType = enum
    document, music, video, image, folder

let 
  logger = newConsoleLogger()

proc getData(data : FileType) : seq[FileObj] =

  let appsettings = parseFile(joinPath(getAppDir(), "public/settings.json")).to(Settings)
  var directories : tuple[locations, ext : seq[string]]

  case data:

  of folder:

    directories = (locations : concat(
      appsettings.locations.document,
      appsettings.locations.music,
      appsettings.locations.video,
      appsettings.locations.image,
    ), ext : @[""])
  of document:

    directories = (appsettings.locations.document, appsettings.extensions.docext)
  of music:

    directories = (appsettings.locations.music, appsettings.extensions.musicext)
  of image:

    directories = (appsettings.locations.image, appsettings.extensions.imageext)
  of video:

    directories = (appsettings.locations.video, appsettings.extensions.videoext)


  for dir in directories.locations:
    for folder in walkDir(dir):

      let ext = folder.path.splitFile.ext
      if ext in directories.ext or folder.kind == pcDir:

        result.add(FileObj(name : folder.path.lastPathPart(), path : folder.path, ext : ext))
  

router server:

  get "/":
    resp nshare("js/main", "css/main", "")

  post "/folder":
    resp $(%(getData(folder)))

  post "/music":
    resp $(%(getData(music)))

  post "/image":
    resp $(%(getData(image)))

  post "/video":
    resp $(%(getData(video)))

  post "/document":
    resp $(%(getData(document)))


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