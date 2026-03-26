; /*
;   WebUI Library 2.5.0-beta.4
;   https://webui.me
;   https://github.com/webui-dev/webui
;   Copyright (c) 2020-2026 Hassan Draga.
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


#WEBUI_VERSION = "2.5.0-beta.4"
#WEBUI_MAX_IDS = 65535

Enumeration webui_browsers
  #NoBrowser    ; 0. No web browser
  #AnyBrowser   ; 1. Default recommended web browser
  #Chrome       ; 2. Google Chrome
  #Firefox      ; 3. Mozilla Firefox
  #Edge         ; 4. Microsoft Edge
  #Safari       ; 5. Apple Safari
  #Chromium     ; 6. The Chromium Project
  #Opera        ; 7. Opera Browser
  #Brave        ; 8. The Brave Browser
  #Vivaldi      ; 9. The Vivaldi Browser
  #Epic         ; 10. The Epic Browser
  #Yandex       ; 11. The Yandex Browser
  #ChromiumBased ; 12. Any Chromium based browser
  #Webview      ; 13. WebView (Non-web-browser)
EndEnumeration

Enumeration webui_runtimes
  #None   ; 0. Prevent WebUI from using any runtime for .js and .ts files
  #Deno   ; 1. Use Deno runtime for .js and .ts files
  #NodeJS ; 2. Use Nodejs runtime for .js files
  #Bun    ; 3. Use Bun runtime for .js and .ts files
EndEnumeration

Enumeration webui_events
  #WEBUI_EVENT_DISCONNECTED ; 0. Window disconnection event
  #WEBUI_EVENT_CONNECTED    ; 1. Window connection event
  #WEBUI_EVENT_MOUSE_CLICK  ; 2. Mouse click event
  #WEBUI_EVENT_NAVIGATION   ; 3. Window navigation event
  #WEBUI_EVENT_CALLBACK     ; 4. Function call event
EndEnumeration

Enumeration webui_config
  #show_wait_connection   ; 0. Control if show() should wait for the window to connect before returning
  #ui_event_blocking      ; 1. Process UI events one at a time in a single thread (True) or each in a new thread (False)
  #folder_monitor         ; 2. Auto-refresh the window UI when any file in the root folder changes
  #multi_client           ; 3. Allow multiple clients to connect to the same window
  #use_cookies            ; 4. Allow or prevent WebUI from adding webui_auth cookies
  #asynchronous_response  ; 5. If backend uses async operations, set to True to make webui wait for webui_return_x()
EndEnumeration

Enumeration webui_logger_level
  #WEBUI_LOGGER_LEVEL_DEBUG ; 0. All logs with all details
  #WEBUI_LOGGER_LEVEL_INFO  ; 1. Only general logs
  #WEBUI_LOGGER_LEVEL_ERROR ; 2. Only fatal error logs
EndEnumeration

Structure webui_event_t Align #PB_Structure_AlignC
  window.i        ; The window object number
  event_type.i    ; Event type
  *element        ; HTML element ID
  event_number.i  ; Internal WebUI
  bind_id.i       ; Bind ID
  client_id.i     ; Client's unique ID
  connection_id.i ; Client's connection ID
  *cookies        ; Client's full cookies
EndStructure

PrototypeC   PrototypeC_webui_event(*e.webui_event_t)
PrototypeC.i PrototypeC_webui_close_handler(window.i)
PrototypeC.i PrototypeC_webui_file_handler(filename.p-Ascii, *length)
PrototypeC.i PrototypeC_webui_file_handler_window(window.i, filename.p-Ascii, *length)
PrototypeC   PrototypeC_webui_logger(level.i, log.p-Ascii, *user_data)

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

      ; -- Window --------------------------
      ; Create a new webui window object.
      webui_new_window.i()
      ; Create a new webui window object using a specified window number.
      webui_new_window_id.i(window_number.i)
      ; Get a free window ID that can be used with `webui_new_window_id()`.
      webui_get_new_window_id.i()
      ; Bind an HTML element and a JavaScript object with a backend function. Empty element means all events.
      webui_bind.i(window.i, element.p-Ascii, func.PrototypeC_webui_event)
      ; Add user data to a bind that can be read later using `webui_get_context()`.
      webui_set_context(window.i, element.p-Ascii, *context)
      ; Get user data set using `webui_set_context()`.
      webui_get_context.i(*e.webui_event_t)
      ; Get the recommended web browser ID to use.
      webui_get_best_browser.i(window.i)
      ; Show a window using embedded HTML, or a file. Refreshes all clients in multi-client mode.
      webui_show.i(window.i, content.p-Ascii)
      ; Show a window using embedded HTML, or a file. Single client.
      webui_show_client.i(*e.webui_event_t, content.p-Ascii)
      ; Same as `webui_show()` but using a specific web browser.
      webui_show_browser.i(window.i, content.p-Ascii, browser.i)
      ; Start only the local web server and return the URL. No window will be shown.
      webui_start_server.i(window.i, content.p-Ascii)
      ; Show a WebView window using embedded HTML, or a file.
      webui_show_wv.i(window.i, content.p-Ascii)
      ; Set the window in Kiosk mode (Full screen).
      webui_set_kiosk(window.i, status.i)
      ; Bring a window to the front and focus it.
      webui_focus(window.i)
      ; Add user-defined web browser CLI parameters.
      webui_set_custom_parameters(window.i, params.p-Ascii)
      ; Set the window with high-contrast support.
      webui_set_high_contrast(window.i, status.i)
      ; Sets whether the window frame is resizable or fixed. Works only on WebView window.
      webui_set_resizable(window.i, status.i)
      ; Get OS high contrast preference.
      webui_is_high_contrast.i()
      ; Check if a web browser is installed.
      webui_browser_exist.i(browser.i)
      ; Wait until all opened windows get closed.
      webui_wait()
      ; Wait asynchronously until all opened windows get closed.
      webui_wait_async.i()
      ; Close a specific window only. The window object will still exist. All clients.
      webui_close(window.i)
      ; Minimize a WebView window.
      webui_minimize(window.i)
      ; Maximize a WebView window.
      webui_maximize(window.i)
      ; Close a specific client.
      webui_close_client(*e.webui_event_t)
      ; Close a specific window and free all memory resources.
      webui_destroy(window.i)
      ; Close all open windows. `webui_wait()` will return (Break).
      webui_exit()
      ; Set the web-server root folder path for a specific window.
      webui_set_root_folder.i(window.i, path.p-Ascii)
      ; Set custom browser folder path.
      webui_set_browser_folder(path.p-Ascii)
      ; Set the web-server root folder path for all windows.
      webui_set_default_root_folder.i(path.p-Ascii)
      ; Set a callback to catch the close event of the WebView window. Must return False to prevent close.
      webui_set_close_handler_wv(window.i, close_handler.PrototypeC_webui_close_handler)
      ; Set a custom handler to serve files (returns full HTTP header and body).
      webui_set_file_handler(window.i, handler.PrototypeC_webui_file_handler)
      ; Set a custom handler to serve files with window parameter (returns full HTTP header and body).
      webui_set_file_handler_window(window.i, handler.PrototypeC_webui_file_handler_window)

      ; -- Other ---------------------------
      ; Check if a specific window is still running.
      webui_is_shown.i(window.i)
      ; Set the maximum time in seconds to wait for the window to connect.
      webui_set_timeout(second.i)
      ; Set the default embedded HTML favicon.
      webui_set_icon(window.i, icon.p-Ascii, icon_type.p-Ascii)
      ; Encode text to Base64. The returned buffer needs to be freed.
      webui_encode.i(str.p-Ascii)
      ; Decode a Base64 encoded text. The returned buffer needs to be freed.
      webui_decode.i(str.p-Ascii)
      ; Safely free a buffer allocated by WebUI.
      webui_free(*ptr)
      ; Safely allocate memory using the WebUI memory management system.
      webui_malloc.i(size.i)
      ; Copy raw data.
      webui_memcpy(*dest, *src, count.i)
      ; Safely send raw data to the UI. All clients.
      webui_send_raw(window.i, function.p-Ascii, *raw, size.i)
      ; Safely send raw data to the UI. Single client.
      webui_send_raw_client(*e.webui_event_t, function.p-Ascii, *raw, size.i)
      ; Set a window in hidden mode. Should be called before `webui_show()`.
      webui_set_hide(window.i, status.i)
      ; Set the window size.
      webui_set_size(window.i, width.l, height.l)
      ; Set the window minimum size.
      webui_set_minimum_size(window.i, width.l, height.l)
      ; Set the window position.
      webui_set_position(window.i, x.l, y.l)
      ; Center the window on the screen.
      webui_set_center(window.i)
      ; Set the web browser profile to use.
      webui_set_profile(window.i, name.p-Ascii, path.p-Ascii)
      ; Set the web browser proxy server to use.
      webui_set_proxy(window.i, proxy_server.p-Ascii)
      ; Get current URL of a running window.
      webui_get_url.i(window.i)
      ; Open a URL in the native default web browser.
      webui_open_url(url.p-Ascii)
      ; Allow a specific window address to be accessible from a public network.
      webui_set_public(window.i, status.i)
      ; Navigate to a specific URL. All clients.
      webui_navigate(window.i, url.p-Ascii)
      ; Navigate to a specific URL. Single client.
      webui_navigate_client(*e.webui_event_t, url.p-Ascii)
      ; Free all memory resources. Should be called only at the end.
      webui_clean()
      ; Delete all local web-browser profiles folder.
      webui_delete_all_profiles()
      ; Delete a specific window web-browser local folder profile.
      webui_delete_profile(window.i)
      ; Get the parent process ID (current backend application process).
      webui_get_parent_process_id.i(window.i)
      ; Get the child process ID (web browser window).
      webui_get_child_process_id.i(window.i)
      ; Get Win32 window HWND (Windows only).
      webui_win32_get_hwnd.i(window.i)
      ; Get window HWND (Win32) or GtkWindow (Linux).
      webui_get_hwnd.i(window.i)
      ; Get the network port of a running window.
      webui_get_port.i(window.i)
      ; Set a custom web-server/websocket network port to be used by WebUI.
      webui_set_port.i(window.i, port.i)
      ; Get an available usable free network port.
      webui_get_free_port.i()
      ; Set a custom logger function.
      webui_set_logger(func.PrototypeC_webui_logger, *user_data)
      ; Control the WebUI behaviour.
      webui_set_config(option.i, status.i)
      ; Control if UI events from this window should be processed in a single blocking thread or non-blocking threads.
      webui_set_event_blocking(window.i, status.i)
      ; Make a WebView window frameless.
      webui_set_frameless(window.i, status.i)
      ; Make a WebView window transparent.
      webui_set_transparent(window.i, status.i)
      ; Get the HTTP mime type of a file.
      webui_get_mime_type.i(file.p-Ascii)
      ; Set the SSL/TLS certificate and the private key content, both in PEM format.
      webui_set_tls_certificate.i(certificate_pem.p-Ascii, private_key_pem.p-Ascii)

      ; -- JavaScript ----------------------
      ; Run JavaScript without waiting for the response. All clients.
      webui_run(window.i, script.p-Ascii)
      ; Run JavaScript without waiting for the response. Single client.
      webui_run_client(*e.webui_event_t, script.p-Ascii)
      ; Run JavaScript and get the response back. Single client mode only.
      webui_script.i(window.i, script.p-Ascii, timeout.i, *buffer, buffer_length.i)
      ; Run JavaScript and get the response back. Single client.
      webui_script_client.i(*e.webui_event_t, script.p-Ascii, timeout.i, *buffer, buffer_length.i)
      ; Choose between Deno, Bun and Nodejs as runtime for .js and .ts files.
      webui_set_runtime(window.i, runtime.i)
      ; Get how many arguments there are in an event.
      webui_get_count.i(*e.webui_event_t)
      ; Get an argument as integer at a specific index.
      webui_get_int_at.q(*e.webui_event_t, index.i)
      ; Get the first argument as integer.
      webui_get_int.q(*e.webui_event_t)
      ; Get an argument as float at a specific index.
      webui_get_float_at.d(*e.webui_event_t, index.i)
      ; Get the first argument as float.
      webui_get_float.d(*e.webui_event_t)
      ; Get an argument as string at a specific index.
      webui_get_string_at.i(*e.webui_event_t, index.i)
      ; Get the first argument as string.
      webui_get_string.i(*e.webui_event_t)
      ; Get an argument as boolean at a specific index.
      webui_get_bool_at.i(*e.webui_event_t, index.i)
      ; Get the first argument as boolean.
      webui_get_bool.i(*e.webui_event_t)
      ; Get the size in bytes of an argument at a specific index.
      webui_get_size_at.i(*e.webui_event_t, index.i)
      ; Get the size in bytes of the first argument.
      webui_get_size.i(*e.webui_event_t)
      ; Return the response to JavaScript as integer.
      webui_return_int(*e.webui_event_t, n.q)
      ; Return the response to JavaScript as float.
      webui_return_float(*e.webui_event_t, f.d)
      ; Return the response to JavaScript as string.
      webui_return_string(*e.webui_event_t, s.p-Ascii)
      ; Return the response to JavaScript as boolean.
      webui_return_bool(*e.webui_event_t, b.i)
      ; Get the last WebUI error code.
      webui_get_last_error_number.i()
      ; Get the last WebUI error message.
      webui_get_last_error_message.i()

      ; -- Interface -----------------------
      ; Bind an HTML element with a function. Empty element means all events. The func is (Window, EventType, Element, EventNumber, BindID)
      webui_interface_bind.i(window.i, element.p-Ascii, *func)
      ; When using `webui_interface_bind()`, set the response to JavaScript.
      webui_interface_set_response(window.i, event_number.i, response.p-Ascii)
      ; Set an async file handler response.
      webui_interface_set_response_file_handler(window.i, *response, length.l)
      ; Check if the app is still running.
      webui_interface_is_app_running.i()
      ; Get a unique window ID.
      webui_interface_get_window_id.i(window.i)
      ; Get an argument as string at a specific index.
      webui_interface_get_string_at.i(window.i, event_number.i, index.i)
      ; Get an argument as integer at a specific index.
      webui_interface_get_int_at.q(window.i, event_number.i, index.i)
      ; Get an argument as float at a specific index.
      webui_interface_get_float_at.d(window.i, event_number.i, index.i)
      ; Get an argument as boolean at a specific index.
      webui_interface_get_bool_at.i(window.i, event_number.i, index.i)
      ; Get the size in bytes of an argument at a specific index.
      webui_interface_get_size_at.i(window.i, event_number.i, index.i)
      ; Show a window using embedded HTML, or a file. Single client.
      webui_interface_show_client.i(window.i, event_number.i, content.p-Ascii)
      ; Close a specific client.
      webui_interface_close_client(window.i, event_number.i)
      ; Safely send raw data to the UI. Single client.
      webui_interface_send_raw_client(window.i, event_number.i, function.p-Ascii, *raw, size.i)
      ; Navigate to a specific URL. Single client.
      webui_interface_navigate_client(window.i, event_number.i, url.p-Ascii)
      ; Run JavaScript without waiting for the response. Single client.
      webui_interface_run_client(window.i, event_number.i, script.p-Ascii)
      ; Run JavaScript and get the response back. Single client.
      webui_interface_script_client.i(window.i, event_number.i, script.p-Ascii, timeout.i, *buffer, buffer_length.i)
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
