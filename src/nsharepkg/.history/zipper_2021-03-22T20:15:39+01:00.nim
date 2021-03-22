import zip/zipfiles
from os import walkDir
from strutils import split, replaceWord
from sequtils import filterIt

proc zipappend(name, folder : string, dir : seq[string]) : seq[string] =

  var item : ZipArchive
  var dir = dir
  var title = name.split("/")
  discard item.open(title[^1] & ".zip", fmAppend)

  for kind, path in walkDir(folder):

    if $kind == "pcDir":
      try:  
        item.createDir(path.replaceWord(name)[1..^1])
        dir.add(path)
      except:
        continue

    elif $kind == "pcFile":
      try:
        item.addFile(path.replaceWord(name)[1..^1], path)
      except:
        continue

    else:
      continue

  item.close()
  return dir

proc createzip*(name : string) =

  var item : ZipArchive
  var title = name.split("/")
  var dir : seq[string]
  var oldir : seq[string]
  var ddir : seq[string]
  discard item.open(title[^1] & ".zip", fmWrite)

  for kind, path in walkDir(name, true):
  
    if $kind == "pcDir":
      try:  
        item.createDir(path)
        dir.add(name & "/" & path)
      except:
        continue

    elif $kind == "pcFile":
      try:
        item.addFile(path, name & "/" & path)
      except:
        continue

    else:
      continue

  item.close()

  while dir != oldir:
    ddir = dir
    for each in ddir:
        if each notin oldir:
            oldir.add(each)
            var ndir = zipappend(name, each, dir)
            dir.add(ndir.filterIt(it notin dir))
        else:
            continue
  echo "zipped " & name
