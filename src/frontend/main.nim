import karax / [karax, karaxdsl, vdom, kdom], asyncjs, ../datatypes
from karax / kajax import ajaxPost, ajaxGet, newFormData, append
from jsffi import to
from json import parseJson, JsonNode, to

var settings : UiSetting = UiSetting(folders : @[], documents : @[], music : @[], videos : @[], images : @[])

proc toCstr*[T](item : T) : cstring =
    let item : cstring = $item
    return item

proc callOnApi*(url : string, useget : bool = false) : Future[JsonNode] =
    let 
        url : cstring = url

    var 
        headers : seq[(cstring, cstring)]
        data : cstring
        promise : Future[JsonNode]

    if useget:
        promise = newPromise() do (resolve : proc(response : JsonNode)):
            ajaxGet(url, headers, proc (status : int, resp : cstring) =
                    if status == 200:
                        echo resp, url
                        let jsonresp = parseJson($resp)
                        resolve(jsonresp)
            )

    else:
        promise = newPromise() do (resolve : proc(response : JsonNode)):
            ajaxPost(url, headers, data, proc (status : int, resp : cstring) =
                    if status == 200:
                        let jsonresp = parseJson($resp)
                        resolve(jsonresp)
            )

    return promise

proc sendToApi*(url : string, form : seq[tuple[keys, values : string]]) : Future[JsonNode] =

    var
        url : cstring = url
        info = newFormData()

    for each in form:
        info.append(each.keys.toCstr, each.values.toCstr)
    
    var 
        data : cstring = info.to(cstring)
        headers : seq[(cstring, cstring)]
        promise = newPromise() do (resolve : proc(response : JsonNode)):
            ajaxPost(url, headers, data, proc (status : int, resp : cstring) =
                    if status == 200:
                        let jsonresp = parseJson($resp)
                        resolve(jsonresp)
            )

    return promise

proc createFile*(file : FileObj) : VNode =
    var ext : string

    if file.ext == "":

        ext = "folder"
    else:

        ext = file.ext

    result = buildHtml(span(class = "file")):
        input(`type` = "hidden", value = file.path)
        tdiv(class = ext)
        p:
            text file.name

proc showFolders(ev : Event, n : VNode) =
    proc updateFolders(parent : var Node, folders : var seq[FileObj]) =
        for each in folders:
            parent.appendChild(createFile(each).vnodeToDom())

    proc updateFolder(parent : var Node, folders : var seq[FileObj]) {.async.} =
        let jsonfolders = await callOnApi("/folder")
        folders = jsonfolders.to(seq[FileObj])
        updateFolders(parent, folders)

    var 
        folders : seq[FileObj] = settings.folders
        child = buildHtml(tdiv(id = "filecontainer")).vnodeToDom()

    let
        parent = document.getElementById("mainsection")
        oldchild = document.getElementById("filecontainer")


    if folders == @[]:

        discard updateFolder(child, folders)
    else:

        updateFolders(child, folders)

    parent.replaceChild(child, oldchild)    
    settings.folders = folders

proc showDocuments(ev : Event, n : VNode) =
    proc updateDocuments(parent : var Node, documents : var seq[FileObj]) =
        for each in documents:
            parent.appendChild(createFile(each).vnodeToDom())

    proc updateDocument(parent : var Node, documents : var seq[FileObj]) {.async.} =
        let jsondocuments = await callOnApi("/document")
        documents = jsondocuments.to(seq[FileObj])
        updateDocuments(parent, documents)

    var 
        documents : seq[FileObj] = settings.documents
        child = buildHtml(tdiv(id = "filecontainer")).vnodeToDom()

    let
        parent = document.getElementById("mainsection")
        oldchild = document.getElementById("filecontainer")


    if documents == @[]:

        discard updateDocument(child, documents)
    else:

        updateDocuments(child, documents)

    parent.replaceChild(child, oldchild)
    settings.documents = documents

proc showVideos(ev : Event, n : VNode) =
    proc updateVideos(parent : var Node, videos : var seq[FileObj]) =
        for each in videos:
            parent.appendChild(createFile(each).vnodeToDom())

    proc updateVideo(parent : var Node, videos : var seq[FileObj]) {.async.} =
        let jsonvideos = await callOnApi("/video")
        videos = jsonvideos.to(seq[FileObj])
        updateVideos(parent, videos)

    var 
        videos : seq[FileObj] = settings.videos
        child = buildHtml(tdiv(id = "filecontainer")).vnodeToDom()

    let
        parent = document.getElementById("mainsection")
        oldchild = document.getElementById("filecontainer")


    if videos == @[]:

        discard updateVideo(child, videos)
    else:

        updateVideos(child, videos)

    parent.replaceChild(child, oldchild)
    settings.videos = videos

proc showImages(ev : Event, n : VNode) =
    proc updateImages(parent : var Node, images : var seq[FileObj]) =
        for each in images:
            parent.appendChild(createFile(each).vnodeToDom())

    proc updateImage(parent : var Node, images : var seq[FileObj]) {.async.} =
        let jsonimages = await callOnApi("/image")
        images = jsonimages.to(seq[FileObj])
        updateImages(parent, images)

    var 
        images : seq[FileObj] = settings.images
        child = buildHtml(tdiv(id = "filecontainer")).vnodeToDom()

    let
        parent = document.getElementById("mainsection")
        oldchild = document.getElementById("filecontainer")


    if images == @[]:

        discard updateImage(child, images)
    else:

        updateImages(child, images)

    parent.replaceChild(child, oldchild)
    settings.images = images

proc showMusic(ev : Event, n : VNode) =
    proc updateMusics(parent : var Node, musics : var seq[FileObj]) =
        for each in musics:
            parent.appendChild(createFile(each).vnodeToDom())

    proc updateMusic(parent : var Node, musics : var seq[FileObj]) {.async.} =
        let jsonmusics = await callOnApi("/music")
        musics = jsonmusics.to(seq[FileObj])
        updateMusics(parent, musics)

    var 
        musics : seq[FileObj] = settings.music
        child = buildHtml(tdiv(id = "filecontainer")).vnodeToDom()

    let
        parent = document.getElementById("mainsection")
        oldchild = document.getElementById("filecontainer")


    if musics == @[]:

        discard updateMusic(child, musics)
    else:

        updateMusics(child, musics)

    parent.replaceChild(child, oldchild)
    settings.music = musics

proc shutDown(ev : Event, n : VNode) =
    discard callOnApi("/quit")

proc changeMode(ev : Event, n : Vnode) =
    discard

proc main() : VNode =
    result = buildHtml(main):
        nav:
            span(id = "appbtns"):
                for btn in [
                    ("folders", showFolders), 
                    ("documents", showDocuments), 
                    ("videos", showVideos), 
                    ("music", showMusic), 
                    ("images", showImages)
                ]:
                    #button(`type` = "button", id = btn)
                    tdiv(class = "btns", id = btn[0], onclick = btn[1]):
                        tdiv(class = "btnbackground")

            span(id = "sudobtns"):
                for btn in [
                    ("modebtn", changeMode), 
                    ("powerbtn", shutDown)
                    ]:
                    #button(`type` = "button", id = btn)
                    tdiv(class = "btns", id = btn[0], onclick = btn[1]):
                        tdiv(class = "btnbackground")

        span(id = "mainsection"):
            tdiv(id = "filecontainer")

when isMainModule:
    setRenderer main