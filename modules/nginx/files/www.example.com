server {
    listen       80;
    access_log /var/log/www.example.com/access_www.example.com_log;
    server_name localhost;

    location / {
        include uwsgi_params;
        uwsgi_pass localhost:9090;
    }
}
