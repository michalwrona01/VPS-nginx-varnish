vcl 4.1;

backend default {
    .host = "nginx";
    .port = "8080";
}

backend order-app {
    .host = "order-app";
    .port = "8080";
}

sub vcl_pipe {
    if (req.http.upgrade) {
        set bereq.http.upgrade = req.http.upgrade;
        set bereq.http.connection = req.http.connection;
    }
}

sub vcl_recv {
    unset req.http.Cookie;
    unset req.http.Authorization;

    if (req.http.host ~ "djqubus.wronamichal.pl") {
        set req.backend_hint = order-app;
        if (req.http.upgrade) {
            return (pipe);
        }
        return(hash);
    }

    return(hash);
}