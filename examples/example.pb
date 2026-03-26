XIncludeFile "webui.pb"

Define window.i

window = webui_new_window()
webui_show(window, "<html><script src=""webui.js""></script><body>Hello World from PureBasic!</body></html>")
webui_wait()
