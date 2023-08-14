; Not Complete
; More info: https://www.purebasic.fr/english/viewtopic.php?t=81814

Procedure webuieventproc(*e.webui_event_t)
   ; ...
EndProcedure

window = newwindow()
webui_bind(window,Ascii("button"),@webuieventproc())
*cont=Ascii("<html><body><button id='button'>Click me!</button></body></html>")
webui_show(window,*cont) ; or webui_show(window,ascii("htmlfile.html"))

webui_wait()
FreeMemory(*cont)
