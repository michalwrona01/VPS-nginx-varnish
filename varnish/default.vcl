vcl 4.1;

backend nginx_1 {
    .host = "nginx_1";
    .port = "8080";
}

backend nginx_cms {
    .host = "nginx_cms";
    .port = "8082";
}

backend nginx_front {
    .host = "nginx_cms";
    .port = "8081";
}

sub vcl_recv {
    if (req.http.host ~ "infoboard.wronamichal.pl") {
        set req.backend_hint = nginx_front;
    }
    elsif (req.http.host ~ "cms.infoboard.wronamichal.pl") {
        set req.backend_hint = nginx_cms;
    }
    else {
        set req.backend_hint = nginx_1;
    }

    if (req.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)$") {
        unset req.http.Cookie;
        return(hash);
    }

    if (req.method == "FULLBAN") {
        ban("req.http.host ~ .*");
        return (synth(200, "Full cache cleared"));
    }
}

sub vcl_backend_response {
    set beresp.ttl = 1d;
}
