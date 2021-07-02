import karax / [karax, karaxdsl, vdom, kdom]

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