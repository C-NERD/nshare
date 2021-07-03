import zip/zipfiles, logging, threadpool
from os import walkDir, lastPathPart, normalizedPath, joinPath, fileExists, dirExists
from strutils import split, replaceWord, format
from sequtils import filterIt

proc zipAppend(name, folder: string, dir: seq[string],
    logger: ConsoleLogger): seq[string] =

  var
    item: ZipArchive
    dir = dir

  let
    title = lastPathPart(name)

  if item.open(title & ".zip", fmAppend):
    for kind, path in walkDir(folder):

      if $kind == "pcDir":
        try:

          item.createDir(normalizedPath(path.replaceWord(name)))
          dir.add(path)
        except:

          continue

      elif $kind == "pcFile":
        try:

          item.addFile(normalizedPath(path.replaceWord(name)), path)
        except:

          continue

      else:
        continue

    item.close()
    return dir

  else:
    logger.log(lvlError, "Unable to open file $1.zip".format([
      title
    ]))

proc createZip*(name: string) : bool =

  var
    item: ZipArchive
    directory: seq[string]
    oldirectory: seq[string]
    ddirectory: seq[string]
    logger = newConsoleLogger()

  let
    title = lastPathPart(name)

  if item.open(title & ".zip", fmWrite):
    for kind, path in walkDir(name, true):
      
      if $kind == "pcDir":
        try:

          item.createDir(path)
          directory.add(joinPath(name, path))
        except:

          continue

      elif $kind == "pcFile":
        try:

          item.addFile(path, joinPath(name, path))
        except:

          continue

      else:

        continue

    item.close()

    while directory != oldirectory:

      ddirectory = directory
      for each in ddirectory:
        if each notin oldirectory:

          oldirectory.add(each)
          let newdirectory = spawn zipAppend(name, each, directory, logger)
          sync()

          directory.add((^newdirectory).filterIt(it notin directory))
        else:

          continue

    logger.log(lvlNotice, "zipped $1".format([
      name
    ]))
    return true

  else:

    logger.log(lvlError, "Unable to create file $1.zip".format(title))
    return false

when isMainModule:
  from os import paramCount, paramStr

  if paramCount() == 1:

    if fileExists(paramStr(1)) or dirExists(paramStr(1)):

      discard createZip(paramStr(1))
    else:
      echo "File does not exists"
