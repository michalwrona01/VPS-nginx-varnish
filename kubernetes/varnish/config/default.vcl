vcl 4.1;

backend default {
    .host = "nginx";
    .port = "8080";
}

backend order-app {
    .host = "order-app";
    .port = "8080";
}

backend cms {
    .host = "cms";
    .port = "8080";
}

backend front {
    .host = "front";
    .port = "8080";
}

sub vcl_pipe {
    if (req.http.upgrade) {
        set bereq.http.upgrade = req.http.upgrade;
        set bereq.http.connection = req.http.connection;
    }
}

sub vcl_recv {
    if (req.http.host ~ "djqubus.wronamichal.pl") {
        set req.backend_hint = order-app;
        if (req.http.upgrade) {
            return (pipe);
        }
        return(hash);
    }

    if (req.method == "POST") {
        return (pass);
    }

    if (req.http.host == "cms-infoboard.wronamichal.pl") {
        set req.http.host = "cms-infoboard.wronamichal.pl";
        set req.backend_hint = cms;
        return (pass);
    }

    if (req.http.host == "infoboard.wronamichal.pl") {
        set req.http.host = "infoboard.wronamichal.pl";
        unset req.http.Authorization;
        unset req.http.Cookie;
        set req.backend_hint = front;
    }

    if (req.url ~ "^[^?]*\.(jpeg|jpg|js|mp4|svg||webp)(\?.*)?$") {
        unset req.http.Cookie;
        unset req.http.Authorization;
    }

    return(hash);
}

sub vcl_backend_response {
    set beresp.ttl = 24h;
    set beresp.grace = 3d;
    set beresp.keep = 7d;
}