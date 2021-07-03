import jester, zipper, logging, datatypes
#from net import getPrimaryIPAddr, `$`
from json import to, parseFile, `%*`, `$`, `%`
from os import getAppDir, joinPath, walkDir, lastPathPart, PathComponent, splitFile, getHomeDir, dirExists, fileExists, removeFile, getFileSize
from strutils import removePrefix, format
from sequtils import mapIt, concat
include "view.tmpl"

type

  FileType = enum
    document, music, video, image, folder, downloads

let 
  logger = newConsoleLogger()

proc getData(data : FileType) : seq[FileObj] =

  let appsettings = parseFile(joinPath(getAppDir(), "public/settings.json")).to(Settings)
  var directories : tuple[locations, ext : seq[string]]

  case data:

  of downloads:

    return @[FileObj(path : appsettings.locations.downloads)]
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
    for container in walkDir(joinPath(getHomeDir(), dir)):

      var ext = container.path.splitFile.ext
      ext.removePrefix('.')
      if ext in directories.ext or (container.kind == pcDir and data == folder):

        result.add(FileObj(name : container.path.lastPathPart(), path : container.path, ext : ext))
  

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

  post "/quit":
    quit()

  post "/send":
    let 
      path = request.formData.getOrDefault("path").body
      name = path.lastPathPart()
      
    if dirExists(path):

      if createZip(path):

        attachment name & ".zip"

        let file = readFile(path & ".zip")
        removeFile(path & ".zip")

        resp file
      else:

        resp "Unable to send file"
    elif fileExists(path):
      
      if getFileSize(path) > 20000000:

        if createZip(path):

          attachment name & ".zip"
          
          let file = readFile(path & ".zip")
          removeFile(path & ".zip")

          resp file
        else:

          resp "Unable to send file"
      else:

        attachment name
        resp readFile(path)

  post "/receive":
    let
      file = request.formData.getOrDefault("file").body
      filename = request.formData.getOrDefault("filename").body
      download = getData(downloads)[0].path
    
    try:

      writeFile(joinPath(download, filename), file)
      resp "successfull"
    except:

      resp "An error occured"

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