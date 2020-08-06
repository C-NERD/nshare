# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import os, jester, asyncdispatch, htmlgen, asyncfile, asyncstreams, streams
import strutils
import ws, ws/jester_extra

settings:
  port = Port 3000

routes:
  get "/":
    var html = """
    <script>
    function submit_file() {
      let ws = new WebSocket("ws://localhost:3000/ws-upload");
      let filedom = document.querySelector("#input-field");
      ws.onmessage = function(evnt) {
        console.log(evnt.data);
      }
      ws.onopen = function(evnt) {
        ws.send(filedom.files[0].name);
        ws.send(filedom.files[0].slice());
        ws.close();
      }
      return true;
    }
    </script>
    """
    for file in walkFiles("*.*"):
      html.add "<li>" & file & "</li>"
    html.add "<form action=\"upload\" method=\"post\"enctype=\"multipart/form-data\">"
    html.add "<input id=\"input-field\" type=\"file\" name=\"file\" value=\"file\">"
    html.add "<input type=\"button\" value=\"Submit\" name=\"submit-button\" onclick=\"submit_file()\">"
    html.add "</form>"
    resp(html)
  
  post "/upload":
    try:
      var wsconn = await newWebSocket(request)
      await wsconn.send("send the filename")
      var fname = await wsconn.receiveStrPacket()
      var f = openAsync(fname, fmWrite)
      while wsconn.readyState == Open:
        let (op, seqbyte) = await wsconn.receivePacket()
        if op != Binary:
          resp Http400, "invalid sent format"
          wsconn.close()
          return
        var cnt = 0
        if seqbyte.len < 4096:
          await f.write seqbyte.join
          continue
        
        while cnt < (seqbyte.len-4096):
          let datastr = seqbyte[cnt .. cnt+4095].join
          cnt.inc 4096
          await f.write(datastr)
        
        wsconn.close()
      f.close()
    except:
      echo "websocket close: ", getCurrentExceptionMsg()
    resp Http200, "file uploaded"
