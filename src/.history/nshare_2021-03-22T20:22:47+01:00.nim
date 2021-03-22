# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import jester
from net import getPrimaryIPAddr, `$`
from strutils import removePrefix
from json import getStr, parseJson, `[]`, getElems, JsonNode
from os import walkFiles, walkDir, PathComponent, getHomeDir, removeFile, joinPath
from strutils import split, strip, contains, splitLines
from sequtils import mapIt
from threadpool import spawn, sync, FlowVar, spawnX, `^`
import nsharepkg/zipper
include "nsharepkg/views.tmpl"

type
    Content* = object
        path* : string
        name* : string
        contenttype* : PathComponent


const homedir = getHomeDir()

try:
  let ip1 = $getPrimaryIPAddr()
  echo "Type {}:5000 in your browser\'s url bar on the receiving device\n"

except OSError:
  echo "Could not find wifi connection, make a connection to the receiving device to continue or use CTRL C to quit the application\n"

  while true:
    try:
      let ip2 = $getPrimaryIPAddr()
      echo "Connection found, type {}:5000 in your browser\'s url bar on the receiving device\n"
      break
      
    except:
      continue

proc newfile(name, data : string) =
  var dump = open(name, fmWrite)
  dump.write(data)
  dump.flushFile
  dump.close

proc packzip(name : string) : string =
  var fdata = open(name & ".zip")
  var finfo : string
  finfo.add(fdata.readAll)
  fdata.flushFile
  fdata.close
  removeFile(name & ".zip")

  return finfo

when isMainModule:
  
  routes:

    get "/":
      redirect uri("/client")

    get "/client":
      var msg = readFile("public/nshare.json")
      var r_msg = parseJson(msg)
      var music = r_msg["musicext"].getStr
      var image = r_msg["imageext"].getStr
      var video = r_msg["videoext"].getStr
      var doc = r_msg["docext"].getStr

      resp mainrender(client(music, image, video, doc))

    post "/client":

      var msg = readFile("public/nshare.json")
      var data = parseJson(msg)
      var loc = data["location"].getStr
      var music = request.formData.getOrDefault("musicname").body
      music.removePrefix("""C:\fakepath\""")

      var photo = request.formData.getOrDefault("photoname").body
      photo.removePrefix("""C:\fakepath\""")
      
      var video = request.formData.getOrDefault("videoname").body
      video.removePrefix("""C:\fakepath\""")

      var doc = request.formData.getOrDefault("docname").body
      doc.removePrefix("""C:\fakepath\""")

      if music != "":
        spawn newfile(joinPath(loc, music), request.formData.getOrDefault("music").body)
        sync()
        redirect("/client")

      elif photo != "":
        spawn newfile(joinPath(loc, photo), request.formData.getOrDefault("photo").body)
        sync()
        redirect("/client")
      
      elif video != "":
        spawn newfile(joinPath(loc, video), request.formData.getOrDefault("video").body)
        sync()
        redirect("/client")

      elif doc != "":
        spawn newfile(joinPath(loc, doc), request.formData.getOrDefault("doc").body)
        sync()
        redirect("/client")
      else:
        redirect("/client")

    get "/server":
      
      var music : string
      var rmusic : seq[Content]
      var image : string
      var rimage : seq[Content]
      var video : string
      var rvideo : seq[Content]
      var doc : string
      var rdoc : seq[Content]
      var msg = readFile("public/nshare.json")
      var data = parseJson(msg)
      music = data["music"].getStr
      image = data["image"].getStr
      video = data["video"].getStr
      doc = data["doc"].getStr
      var musicext = data["musicext"].getStr
      var imageext = data["imageext"].getStr
      var videoext = data["videoext"].getStr
      var docext = data["docext"].getStr


      for each in music.split(','):
        if each.contains(homedir):
          try:
            for ftype, files in walkDir(each.strip):
              var segments = files.split({'/', '\\'})
              var size = high(segments)
              var ssize = high((segments[size].split(".")))
              if (segments[size].split("."))[ssize] in musicext.split({',', '.'}) or ftype == pcDir:
                rmusic.add(Content(path: files, name: segments[size], contenttype: ftype))
              else:
                continue
          except:
            continue

        else:
          try:
            for ftype, files in walkDir(homedir & each.strip):
              var segments = files.split({'/', '\\'})
              var size = high(segments)
              var ssize = high((segments[size].split(".")))
              if (segments[size].split("."))[ssize] in musicext.split({',', '.'}) or ftype == pcDir:
                rmusic.add(Content(path: files, name: segments[size], contenttype: ftype))
              else:
                continue
          except:
            continue

      for each in image.split(','):
        if each.contains(homedir):
          try:
            for ftype, files in walkDir(each.strip):
              var segments = files.split({'/', '\\'})
              var size = high(segments)
              var ssize = high((segments[size].split(".")))
              if (segments[size].split("."))[ssize] in imageext.split({',', '.'}) or ftype == pcDir:
                rimage.add(Content(path: files, name: segments[size], contenttype: ftype))
              else:
                continue
          except:
            continue

        else:
          try:
            for ftype, files in walkDir(homedir & each.strip):
              var segments = files.split({'/', '\\'})
              var size = high(segments)
              var ssize = high((segments[size].split(".")))
              if (segments[size].split("."))[ssize] in imageext.split({',', '.'}) or ftype == pcDir:
                rimage.add(Content(path: files, name: segments[size], contenttype: ftype))
              else:
                continue
          except:
            continue

      for each in video.split(','):
        if each.contains(homedir):
          try:
            for ftype, files in walkDir(each.strip):
              var segments = files.split({'/', '\\'})
              var size = high(segments)
              var ssize = high((segments[size].split(".")))
              if (segments[size].split("."))[ssize] in videoext.split({',', '.'}) or ftype == pcDir:
                rvideo.add(Content(path: files, name: segments[size], contenttype: ftype))
              else:
                continue
          except:
            continue

        else:
          try:
            for ftype, files in walkDir(homedir & each.strip):
              var segments = files.split({'/', '\\'})
              var size = high(segments)
              var ssize = high((segments[size].split(".")))
              if (segments[size].split("."))[ssize] in videoext.split({',', '.'}) or ftype == pcDir:
                rvideo.add(Content(path: files, name: segments[size], contenttype: ftype))
              else:
                continue
          except:
            continue

      for each in doc.split(','):
        if each.contains(homedir):
          try:
            for ftype, files in walkDir(each.strip):
              var segments = files.split({'/', '\\'})
              if (segments[^1].split("."))[^1] in docext.split({',', '.'}) or ftype == pcDir:
                rdoc.add(Content(path: files, name: segments[^1], contenttype: ftype))
              else:
                continue
          except:
            continue

        else:
          try:
            for ftype, files in walkDir(homedir & each.strip):
              var segments = files.split({'/', '\\'})
              if (segments[^1].split("."))[^1] in docext.split({',', '.'}) or ftype == pcDir:
                rdoc.add(Content(path: files, name: segments[^1], contenttype: ftype))
              else:
                continue
          except:
            continue

      resp mainrender(server(rmusic.mapIt(it.name), rmusic.mapIt(it.path), rmusic.mapIt($it.contenttype), rimage.mapIt(it.name), rimage.mapIt(it.path), rimage.mapIt($it.contenttype), rvideo.mapIt(it.name), rvideo.mapIt(it.path), rvideo.mapIt($it.contenttype), rdoc.mapIt(it.name), rdoc.mapIt(it.path), rdoc.mapIt($it.contenttype)))

    post "/server":

      if @"type" == "pcFile":
        var path = @"path"
        var name = @"name"
        
        try:
          attachment name
          resp readFile path
        except:
          redirect uri("/server")

      elif @"type" == "pcDir":
                
        spawn createZip(@"path")
        sync()

        try:
          attachment @"name" & ".zip"
          var finfo = spawn packzip(@"name")
          sync()
          resp ^finfo
        except:
          redirect uri("/server")

  runForever()
