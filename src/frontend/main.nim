import karax / [karax, karaxdsl, vdom, kdom], asyncjs
from karax / kajax import ajaxPost, ajaxGet, newFormData, append
from jsffi import to
from json import parseJson, JsonNode


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

proc main() : VNode =
    result = buildHtml(main):
        nav:
            span(id = "btncontainer"):
                for btn in ["documents", "videos", "music", "images"]:
                    button(`type` = "button", id = btn)

            button(`type` = "button", id = "modebtn")

        span(id = "mainsection")

when isMainModule:
    setRenderer main