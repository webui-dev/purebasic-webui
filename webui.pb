; /*
;   WebUI Library 2.3.0
;   http://webui.me
;   https://github.com/webui-dev/webui
;   Copyright (c) 2020-2023 Hassan Draga.
;   Licensed under MIT License.
;   All rights reserved.
;   Canada.
; */

CompilerIf Not #PB_Compiler_Thread
  CompilerError "Enable threadsafe in compiler options"
CompilerEndIf

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
CompilerEndIf


#WEBUI_VERSION = "2.3.0"
#WEBUI_MAX_IDS = 512

Enumeration webui_browsers
  #AnyBrowser
  #Chrome
  #Firefox
  #Edge
  #Safari
  #Chromium
  #Opera
  #Brave
  #Vivaldi
  #Epic
  #Yandex
EndEnumeration

Enumeration webui_runtimes 
  #None
  #Deno
  #NodeJS
EndEnumeration

Enumeration webui_events
  #WEBUI_EVENT_DISCONNECTED
  #WEBUI_EVENT_CONNECTED
  #WEBUI_EVENT_MULTI_CONNECTION
  #WEBUI_EVENT_UNWANTED_CONNECTION
  #WEBUI_EVENT_MOUSE_CLICK
  #WEBUI_EVENT_NAVIGATION
  #WEBUI_EVENT_CALLBACK
EndEnumeration

Structure webui_event_t Align #PB_Structure_AlignC
  window.i        ; The window object number
  event_type.i    ; Event type
  *element        ; HTML element ID
  *data           ; JavaScript data
  event_number.i  ; Internal WebUI
EndStructure

PrototypeC PrototypeC_webui_event(*e.webui_event_t)

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    ImportC "webui-2-x64.lib"
    ;ImportC "webui-2-static-x64.lib"
    CompilerCase #PB_OS_Linux
      ImportC "webui-2-x64.so"
      CompilerCase #PB_OS_MacOS
        ;ImportC "webui-2-x64.dyn"
        ImportC "webui-2-static-x64.a"
      CompilerEndSelect
      ; Create a new webui window object.
      webui_new_window()
      ; Create a new webui window object.
      webui_new_window_id(window_number.i)
      ; Get a free window ID that can be used with `webui_new_window_id()`
      webui_get_new_window_id.i()
      ; Bind a specific html element click event with a function. Empty element means all events.
      webui_bind.i(window.i, element.p-Ascii, webui_event.PrototypeC_webui_event)
      ; Show a window using a embedded HTML, or a file. If the window is already
      webui_show.i(window.i, content.p-Ascii)
      ; Same as webui_show(). But with a specific web browser.
      webui_show_browser(window.i, content.p-Ascii, browser.i)
      ; Set the window in Kiosk mode (Full screen)
      webui_set_kiosk(window.i, status.i)
      ; Wait until all opened windows get closed.
      webui_wait()
      ; Close a specific window only. The window object will still exist.
      webui_close(window.i)
      ; Close a specific window and free all memory resources.
      webui_destroy(window.i)
      ; Close all opened windows. webui_wait() will break.
      webui_exit()
      ; Set the web-server root folder path.
      webui_set_root_folder.i(window.i, path.p-Ascii)
      
      ; -- Other ---------------------------
      ; Check a specific window if it's still running
      webui_is_shown.i(window.i)
      ; Set the maximum time in seconds to wait for browser to start
      webui_set_timeout(second.i)
      ; Set the default embedded HTML favicon
      webui_set_icon(window.i, icon.p-Ascii, icon_type.p-Ascii)
      ; Allow the window URL to be re-used in normal web browsers
      webui_set_multi_access(window.i, status.b)
      
      ; -- JavaScript ----------------------
      ; Run JavaScript quickly with no waiting for the response.
      webui_run(window.i, script.p-Ascii)
      ; Run a JavaScript, and get the response back (Make sure your local buffer can hold the response).
      webui_script.i(window.i, script.p-Ascii, timeout.i, *buffer, buffer_length.i)
      ; Chose between Deno and Nodejs runtime for .js and .ts files.
      webui_set_runtime(window.i, run_time.i)
      ; Parse argument as integer.
      webui_get_int.q(*e.webui_event_t)
      ; Parse argument as string.
      webui_get_string.i(*e.webui_event_t)
      ; Parse argument as boolean.
      webui_get_bool.i(*e.webui_event_t)
      ; Return the response to JavaScript as integer.
      webui_return_int(*e.webui_event_t, number.i)
      ; Return the response to JavaScript as string.
      webui_return_string(*e.webui_event_t, const.p-Ascii)
      ; Return the response to JavaScript as boolean.
      webui_return_bool(*e.webui_event_t, bool.i)
      ; Base64 encoding. Use this to safely send text based data to the UI. If it fails it will return NULL.
      webui_encode.i(*char)
      ; Base64 decoding. Use this to safely decode received Base64 text from the UI. If it fails it will return NULL.
      webui_decode.i(char.p-Ascii)
      ; Safely free a buffer allocated by WebUI, For example when using webui_encode().
      webui_free(*ptr)
      
      ; -- Interface -----------------------
      ; Bind a specific html element click event with a function. Empty element means all events. This replace webui_bind(). The func is (Window, EventType, Element, Data, EventNumber)
      webui_interface_bind.i(window.i, element.p-Ascii, *func)
      ; When using `webui_interface_bind()` you may need this function to easily set your callback response.
      webui_interface_set_response(window.i, event_number.i, response.p-Ascii)
      ; Check if the app still running or not. This replace webui_wait().
      webui_interface_is_app_running.i()
      ; Get window unique ID
      webui_interface_get_window_id.i(window.i)
      ; Get a unique ID. Same ID as `webui_bind()`. Return > 0 if bind exist.
      webui_interface_get_bind_id.i(window.i, element.p-Ascii)
    EndImport
    
    CompilerIf #PB_Compiler_IsMainFile
      
      Enumeration WebUI_Examples
        #PB_Forum_Example
        #WEBUI_Example_C_call_c_from_js
        #WEBUI_Example_C_call_js_from_c
        #WEBUI_Example_C_minimal
        #WEBUI_Example_C_serve_a_folder
        #WEBUI_Example_C_text_editor
      EndEnumeration
      
      #WebUI_Example = #PB_Forum_Example
      
      CompilerSelect #WebUI_Example
        CompilerCase #PB_Forum_Example
          
          ProcedureC webui_event_proc(*e.webui_event_t)
            Debug "webui_event_proc"
            Debug "Window      : " + Str(*e\window)
            Select *e\event_type
              Case #WEBUI_EVENT_CALLBACK
                Debug "Event_Type  : callback"
              Case #WEBUI_EVENT_CONNECTED
                Debug "Event_Type  : connected"
              Case #WEBUI_EVENT_DISCONNECTED
                Debug "Event_Type  : disconnected"
              Case #WEBUI_EVENT_MOUSE_CLICK
                Debug "Event_Type  : mouse click"
              Case #WEBUI_EVENT_MULTI_CONNECTION
                Debug "Event_Type  : multi connection"
              Case #WEBUI_EVENT_NAVIGATION
                Debug "Event_Type  : navigation"
              Case #WEBUI_EVENT_UNWANTED_CONNECTION
                Debug "Event_Type  : unwanted connection"
            EndSelect
            Debug "Element ID  : " + PeekS(*e\element, -1, #PB_Ascii)
            If *e\data
              Debug "Data        : " + PeekS(*e\data, -1, #PB_Ascii)
            EndIf
            Debug "Event_Number: " + Str(*e\event_number)
          EndProcedure
          
          
          Define.i window
          
          window = webui_new_window()
          webui_bind(window, "button_1", @webui_event_proc())
          webui_show(window, "<html><body><button id='button_1'>Click me!</button></body></html>")
          webui_wait()
          
        CompilerCase #WEBUI_Example_C_call_c_from_js
          ProcedureC my_function_string(*e.webui_event_t)
            
            Protected *str
            
            ; JavaScript:
            ; webui_fn('MyID_One', 'Hello');
            
            *str = webui_get_string(*e)
            Debug "my_function_string: " + PeekS(*str, -1, #PB_Ascii)  ; Hello
            
            ; Need Multiple Arguments?
            ;
            ; WebUI support only one argument. To get multiple arguments
            ; you can send a JSON string from JavaScript then decode it.
            ; Example:
            ;
            ; my_json = my_json_decoder(str);
            ; foo = my_json[0];
            ; bar = my_json[1];
          EndProcedure
          
          ProcedureC my_function_integer(*e.webui_event_t)
            
            Protected number.q
            
            ; JavaScript:
            ; webui_fn('MyID_Two', 123456789);
            
            number = webui_get_int(*e)
            Debug "my_function_integer: " + Str(number) ; 123456789
            
          EndProcedure
          
          ProcedureC my_function_boolean(*e.webui_event_t)
            
            Protected status.i
            
            ; JavaScript:
            ; webui_fn('MyID_Three', true)
            
            status = webui_get_bool(*e) ; True
            If status
              Debug "my_function_boolean: True"
            Else
              Debug "my_function_boolean: False"
            EndIf
            
          EndProcedure
          
          ProcedureC my_function_with_response(*e.webui_event_t)
            
            Protected number.q
            
            ; JavaScript:
            ; const result = webui_fn('MyID_Four', number);
            
            number = webui_get_int(*e)
            number = number * 2
            Debug "my_function_with_response: " + Str(number)
            
            ; Send back the response To JavaScript
            webui_return_int(*e, number)
            
          EndProcedure
          
          
          Define my_html$, my_window.i
          
          my_html$ = ""
          my_html$ + ~"<html>"
          my_html$ + ~"  <head>"
          my_html$ + ~"    <title>Call C from JavaScript Example</title>"
          my_html$ + ~"    <style>"
          my_html$ + ~"      body {"
          my_html$ + ~"        color: white;"
          my_html$ + ~"        background: #0F2027;"
          my_html$ + ~"        text-align: center;"
          my_html$ + ~"        font-size: 16px;"
          my_html$ + ~"        font-family: sans-serif;"
          my_html$ + ~"      }"
          my_html$ + ~"    </style>"
          my_html$ + ~"  </head>"
          my_html$ + ~"  <body>"
          my_html$ + ~"    <h2>WebUI - Call C from JavaScript Example</h2>"
          my_html$ + ~"    <p>Call C function with argument (<em>See the logs in your terminal</em>)</p>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <button onclick=\"webui_fn('MyID_One', 'Hello');\">Call my_function_string()</button>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <button onclick=\"webui_fn('MyID_Two', 123456789);\">Call my_function_integer()</button>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <button onclick=\"webui_fn('MyID_Three', true);\">Call my_function_boolean()</button>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <p>Call C function and wait for the response</p>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <button onclick=\"MyJS();\">Call my_function_with_response()</button>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <input type=\"text\" id=\"MyInputID\" value=\"2\">"
          my_html$ + ~"    <script>"
          my_html$ + ~"      function MyJS() {"
          my_html$ + ~"        const MyInput = document.getElementById('MyInputID');"
          my_html$ + ~"        const number = MyInput.value;"
          my_html$ + ~"        webui_fn('MyID_Four', number).then((response) => {"
          my_html$ + ~"            MyInput.value = response;"
          my_html$ + ~"        });"
          my_html$ + ~"      }"
          my_html$ + ~"    </script>"
          my_html$ + ~"  </body>"
          my_html$ + ~"</html>"
          
          ; Create a window
          my_window = webui_new_window()
          
          ; Bind HTML elements With C functions
          webui_bind(my_window, "MyID_One", @my_function_string())
          webui_bind(my_window, "MyID_Two", @my_function_integer())
          webui_bind(my_window, "MyID_Three", @my_function_boolean())
          webui_bind(my_window, "MyID_Four", @my_function_with_response())
          
          ; Show the window
          webui_show(my_window, my_html$) ; webui_show_browser(my_window, my_html, Chrome)
          
          ; Wait Until all windows get closed
          webui_wait()
          
          
        CompilerCase #WEBUI_Example_C_call_js_from_c
          ProcedureC my_function_exit(*e.webui_event_t)
            webui_exit()
          EndProcedure
          
          ProcedureC my_function_count(*e.webui_event_t)
            ; This function gets called every time the user clicks on "MyButton1"
            
            ; Create a buffer To hold the response
            Protected *response, Count.i
            
            *response = AllocateMemory(64)
            
            ; Run JavaScript
            If Not webui_script(*e\window, "return GetCount();", 0, *response, 64)
              Debug "JavaScript Error: " + PeekS(*response, -1, #PB_Ascii)
              ProcedureReturn
            EndIf
            
            Debug PeekS(*response, -1, #PB_Ascii)
            
            ; Get the count
            count = Val(PeekS(*response, -1, #PB_Ascii))
            
            ; Increment
            count + 1
            
            ; Generate a JavaScript
            
            ; Run JavaScript (Quick Way)
            webui_run(*e\window, "SetCount(" + Str(Count) + ")")
          EndProcedure
          
          
          Define my_html$, my_window.i
          
          my_html$ = ~"<html>"
          my_html$ + ~"  <head>"
          my_html$ + ~"    <title>Call JavaScript from C Example</title>"
          my_html$ + ~"    <style>"
          my_html$ + ~"      body {"
          my_html$ + ~"        color: white;"
          my_html$ + ~"        background: #0F2027;"
          my_html$ + ~"        text-align: center;"
          my_html$ + ~"        font-size: 16px;"
          my_html$ + ~"        font-family: sans-serif;"
          my_html$ + ~"      }"
          my_html$ + ~"    </style>"
          my_html$ + ~"  </head>"
          my_html$ + ~"  <body>"
          my_html$ + ~"    <h2>WebUI - Call JavaScript from C Example</h2>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <h1 id=\"MyElementID\">Count is ?</h1>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <button id=\"MyButton1\">Count</button>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <br>"
          my_html$ + ~"    <button id=\"MyButton2\">Exit</button>"
          my_html$ + ~"    <script>"
          my_html$ + ~"      var count = 0;"
          my_html$ + ~"      function GetCount() {"
          my_html$ + ~"        return count;"
          my_html$ + ~"      }"
          my_html$ + ~"      function SetCount(number) {"
          my_html$ + ~"        const MyElement = document.getElementById('MyElementID');"
          my_html$ + ~"        MyElement.innerHTML = 'Count is ' + number;"
          my_html$ + ~"        count = number;"
          my_html$ + ~"      }"
          my_html$ + ~"    </script>"
          my_html$ + ~"  </body>"
          my_html$ + ~"</html>";
          
          ; Create a window
          my_window = webui_new_window()
          
          ; Bind HTML elements With C functions
          webui_bind(my_window, "MyButton1", @my_function_count())
          webui_bind(my_window, "MyButton2", @my_function_exit())
          
          ; Show the window
          webui_show(my_window, my_html$) ; webui_show_browser(my_window, my_html, Chrome)
          
          ; Wait Until all windows get closed
          webui_wait()
          
          
        CompilerCase #WEBUI_Example_C_minimal
          Define my_window.i
          
          my_window = webui_new_window();
          webui_show(my_window, "<html>Hello</html>")
          webui_wait()
          
          
        CompilerCase #WEBUI_Example_C_serve_a_folder
          
          #MyWindow = 1
          #MySecondWindow = 2
          
          ProcedureC exit_app(*e.webui_event_t)
            
            ; Close all opened windows
            webui_exit()
          EndProcedure
          
          ProcedureC events(*e.webui_event_t)
            
            ; This function gets called every time
            ; there is an event
            
            If *e\event_type = #WEBUI_EVENT_CONNECTED
              Debug "Connected."
            ElseIf *e\event_type = #WEBUI_EVENT_DISCONNECTED
              Debug "Disconnected."
            ElseIf *e\event_type = #WEBUI_EVENT_MOUSE_CLICK
              Debug "Click."
            ElseIf *e\event_type = #WEBUI_EVENT_NAVIGATION
              Debug "Starting navigation to: " + PeekS(*e\Data, -1, #PB_Ascii)
            EndIf
          EndProcedure
          
          ProcedureC switch_to_second_page(*e.webui_event_t)
            
            ; This function gets called every
            ; time the user clicks on "SwitchToSecondPage"
            
            ; Switch To `/second.html` in the same opened window.
            webui_show(*e\window, "second.html")
          EndProcedure
          
          ProcedureC show_second_window(*e.webui_event_t)
            
            ; This function gets called every
            ; time the user clicks on "OpenNewWindow"
            
            ; Show a new window, And navigate To `/second.html`
            ; If it's already open, then switch in the same window
            webui_show(#MySecondWindow, "second.html")
            
          EndProcedure
          
          
          
          ; Create new windows
          webui_new_window_id(#MyWindow)
          webui_new_window_id(#MySecondWindow)
          
          ; Bind HTML element IDs With a C functions
          webui_bind(#MyWindow, "SwitchToSecondPage", @switch_to_second_page())
          webui_bind(#MyWindow, "OpenNewWindow", @show_second_window())
          webui_bind(#MyWindow, "Exit", @exit_app())
          webui_bind(#MySecondWindow, "Exit", @exit_app())
          
          ; Bind events
          webui_bind(#MyWindow, "", @events())
          
          ; Make Deno As the `.ts` And `.js` interpreter
          webui_set_runtime(#MyWindow, #Deno)
          
          ; Show a new window
          ; webui_set_root_folder(MyWindow, "_MY_PATH_HERE_");
          ; webui_show_browser(MyWindow, "index.html", Chrome);
          webui_show(#MyWindow, "index.html")
          
          ; Wait Until all windows get closed
          webui_wait()
          
          
          
        CompilerCase #WEBUI_Example_C_text_editor
          
          #FULL_FILE_BUFFER_SIZE = (2 * 1024 * 1024)    ; 2 MB
          Global *FULL_FILE_BUFFER
          *FULL_FILE_BUFFER = AllocateMemory(#FULL_FILE_BUFFER_SIZE, #PB_Memory_NoClear)
          Global JAVASCRIPT_BUFFER$
          Global FILE_PATH$
          
          ProcedureC Close(*e.webui_event_t)
            Debug "Exit."
            
            ; Close all opened windows
            webui_exit()
          EndProcedure
          
          ProcedureC Save(*e.webui_event_t)
            
            Protected file.i
            
            Debug "Save."
            
            ; Save Data received from the UI
            file = CreateFile(#PB_Any, FILE_PATH$)
            If file
              WriteString(file, PeekS(*e\Data, -1, #PB_Ascii))
              CloseFile(file)
            EndIf
          EndProcedure
          
          ProcedureC Open(*e.webui_event_t)
            
            Protected bytes_read.i, file.i, *file_encoded, *path_encoded, *file_path
            
            Debug "Open."
            
            ; Open a new file
            
            ; Open file And save the path To FILE_PATH
            FILE_PATH$ = OpenFileRequester("Choose a text file", "", "All|*.*", 0)
            If Len(FILE_PATH$) = 0
              ProcedureReturn
            EndIf
            
            ; Read the full content To FULL_FILE_BUFFER
            file = ReadFile(#PB_Any, FILE_PATH$)
            If file
              bytes_read = ReadData(file, *FULL_FILE_BUFFER, Lof(file))
              If bytes_read <> Lof(file)
                CloseFile(file)
                ProcedureReturn
              EndIf
              CloseFile(file)
            EndIf
            
            ; Send file content
            ; Encode the full content To base64
            *file_encoded = webui_encode(*FULL_FILE_BUFFER)
            If *file_encoded = #Null
              ProcedureReturn
            EndIf
            JAVASCRIPT_BUFFER$ = "addText('" + PeekS(*file_encoded, -1, #PB_Ascii) + "')"
            webui_run(*e\window, JAVASCRIPT_BUFFER$)
            
            ; Send file name
            ; Encode the file path To base64
            *file_path = Ascii(FILE_PATH$)
            *path_encoded = webui_encode(*file_path)
            FreeMemory(*file_path)
            If *path_encoded = #Null
              webui_free(*file_encoded)
              ProcedureReturn
            EndIf
            JAVASCRIPT_BUFFER$ = "SetFile('" + PeekS(*path_encoded, -1, #PB_Ascii) + "')"
            webui_run(*e\window, JAVASCRIPT_BUFFER$)
            
            ; Clean
            webui_free(*file_encoded)
            webui_free(*path_encoded)
            
            ;         // Add line by line example:
            ;         FILE *file = fopen(FILE_PATH, "r");
            ;         If(file == NULL)
            ;             Return;
            ;         char line[1024] = {0};
            ;         While (fgets(line, 1024, file) != NULL) {
            ;             // Line
            ;             char* line_encoded = webui_encode(line);
            ;             If(line_encoded != NULL) {
            ;                 char js[1024] = {0};
            ;                 // JS
            ;                 sprintf(js, "addLine('%s')", line_encoded);
            ;                 // Send
            ;                 webui_run(e->window, js);
            ;                 // Clean
            ;                 webui_free(line_encoded);
            ;             }
            ;         }
            ;         fclose(file);
            
          EndProcedure
          
          Define MainWindow.i
          
          MainWindow = webui_new_window()
          
          ; Bind HTML element IDs With a C functions
          webui_bind(MainWindow, "Open", @Open())
          webui_bind(MainWindow, "Save", @Save())
          webui_bind(MainWindow, "Close", @Close())
          
          ; Show a new window
          webui_show(MainWindow, "ui/MainWindow.html")
          
          ; Wait Until all windows get closed
          webui_wait()
          
      CompilerEndSelect
      
    CompilerEndIf
