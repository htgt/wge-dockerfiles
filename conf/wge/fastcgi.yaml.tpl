---
- name:            "wge"
  server_class:    "FCGI::Engine::Manager::Server"
  scriptname:      "/home/www/lib/WGE/bin/wge_fastcgi.pl"
  nproc:            8
  pidfile:         "/home/www/logs/fastcgi.pid"
  socket:          "0.0.0.0:#WGE_FCGI_PORT"
