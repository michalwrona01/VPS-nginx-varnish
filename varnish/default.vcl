vcl 4.1;

import directors;

backend nginx_1 {
    .host = "nginx_1";
    .port = "8080";
}

backend nginx_2 {
    .host = "nginx_2";
    .port = "8081";
}

sub vcl_init {
    new balancer = directors.round_robin();
    balancer.add_backend(nginx_1);
    balancer.add_backend(nginx_2);
}

sub vcl_recv {
    set req.backend_hint = balancer.backend();

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
    if (bereq.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)$") {
        unset beresp.http.Set-Cookie;
        set beresp.ttl = 1d;
    }
}
