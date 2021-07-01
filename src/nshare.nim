import nigui
from os import getAppDir, joinPath, fileExists
#import jester, zipper, nigui
#[from net import getPrimaryIPAddr, `$`
from strutils import removePrefix, format, split, strip, contains, splitLines
from os import walkFiles, walkDir, PathComponent, getHomeDir, removeFile, joinPath
from sequtils import mapIt
include "view.tmpl"]#

const
  wet_asphalt = rgb(52, 73, 94)
  midnight_blue = rgb(44, 62, 80)
  concrete = rgb(149, 165, 166)
  albestos = rgb(127, 140, 141)
  aliceblue = rgb(240, 248, 255)
  white = rgb(255, 255, 255)
  black = rgb(0, 0, 0)

app.init()
app.defaultBackgroundColor = aliceblue

type

  ImageButton = ref object of Button
    image : string

  Nav = ref object of Container


method handleDrawEvent(control: ImageButton, event: DrawEvent) =
  let 
    canvas = event.control.canvas
    image = newImage()

  image.loadFromFile(joinPath(getAppDir(), control.image))

  canvas.areaColor = control.backgroundColor()
  canvas.textColor = control.textColor()
  canvas.lineColor = control.backgroundColor()
  canvas.drawRectArea(0, 0, control.width, control.height)
  canvas.drawRectOutline(0, 0, control.width, control.height)
  canvas.drawImage(image, 0, 0, control.width, control.height)

method handleDrawEvent(control: Nav, event: DrawEvent) =
  let 
    canvas = event.control.canvas

  canvas.areaColor = control.backgroundColor()
  canvas.textColor = control.textColor()
  canvas.lineColor = control.backgroundColor()
  canvas.drawRectArea(0, 0, control.width, control.height)
  canvas.drawRectOutline(0, 0, control.width, control.height)


proc serverside() =
  proc setLayout(dimensions : tuple[width, height : int]) : tuple[container : Container, menu, app: LayoutContainer] {.closure.} =
    let
      container = new Nav
      app = newLayoutContainer(Layout_Vertical)
      menu = newLayoutContainer(Layout_Horizontal)
      menubtns = [
        "public/img/fileslight.png", 
        "public/img/imagelight.png", 
        "public/img/musiclight.png",
        "public/img/videolight.png"
      ]

    container.height = dimensions.height
    container.width = dimensions.width
    container.setBackgroundColor(wet_asphalt)

    menu.height = (dimensions.height / 8).toInt()
    menu.width = (dimensions.width / 2).toInt()
    menu.setBackgroundColor(wet_asphalt)
    menu.scrollableHeight = 0
    menu.scrollableWidth = 0

    for img in menubtns:
      let button = new ImageButton
      button.init()
      button.image = img
      button.height = (menu.height / 2).toInt
      button.width = (menu.height / 2).toInt
      menu.add(button)

    app.height = (dimensions.height - (menu.height + 20))
    app.width = dimensions.width

    container.add(app)
    app.padding = 20
    app.frame = newFrame("app")
    #[app.x = 0
    app.y = 0]#

    container.add(menu)
    menu.frame = newFrame("menu")
    menu.spacing = 13
    #[menu.x = ((dimensions.width - menu.width) / 2).toInt()
    menu.y = app.height]#

    return (container, menu, app)

  let
    mainWindow = newWindow("Nshare")
    structure = setLayout((width : 800, height : 500))

  mainWindow.width = 800
  mainWindow.height = 500
  mainWindow.centerOnScreen()

  mainWindow.add(structure.container)
  mainWindow.show()

when isMainModule:
  serverside()
  app.run()
  #[routes:

    get "/":
      resp nshare("js/main.js", "css/main.css", "")]#
