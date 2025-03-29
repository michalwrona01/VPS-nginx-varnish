vcl 4.1;

import std;

backend nginx_1 {
    .host = "nginx_1";
    .port = "8080";
}
//
//backend faker_app {
//    .host = "faker_app";
//    .port = "8083";
//}

sub vcl_pipe {
    if (req.http.upgrade) {
        set bereq.http.upgrade = req.http.upgrade;
        set bereq.http.connection = req.http.connection;
    }
}

sub vcl_recv {
        if (req.method == "FULLBAN") {
            ban("req.http.host ~ .*");
            return (synth(200, "Full cache cleared"));
        }

        set req.backend_hint = nginx_1;

//        if (req.http.host ~ "www.djqubus.pl" || req.http.host ~ "djqubus.pl" || req.http.host ~ "admin.djqubus.pl") {
//            set req.backend_hint = nginx_1;
//            if (req.http.upgrade) {
//                return (pipe);
//            }
//            return (pass);
//        } else {
//            set req.backend_hint = nginx_1;
//            return (pass);
//        }
        return (pass);
        if (req.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
            unset req.http.Cookie;
              unset req.http.Authorization;
            return(hash);
        }
        if (req.method == "POST") {
            return (pass);
        }
        return(hash);
    }

sub vcl_backend_response {
    if (bereq.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
        unset beresp.http.Set-Cookie;
        set beresp.ttl = 1d;
    }
}

sub vcl_deliver {
    unset resp.http.Via;
    unset resp.http.X-Varnish;
    unset resp.http.Server;
    unset resp.http.x-content-type-options;
    unset resp.http.x-frame-options;
    unset resp.http.vary;
    unset resp.http.CF-Cache-Status;
    unset resp.http.CF-RAY;
}

sub vcl_synth {
    if (resp.status == 750) {
        set resp.status = 301;
        set resp.http.location = "https://" + req.http.Host + req.url;
        set resp.reason = "Moved";
        return (deliver);
    }
    if (resp.status == 503) {
        set resp.http.Content-Type = "text/html; charset=utf-8";
        set resp.http.Cache-Control = "no-cache";
        set resp.body = std.fileread("/var/www/500.html");
        return (deliver);
    }

}

