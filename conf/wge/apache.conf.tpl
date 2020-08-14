Listen #WGE_APACHE_PORT
ServerName htgt-wge
ServerRoot "/usr/lib/apache2"
ServerAdmin "#WGE_SERVER_EMAIL"

LoadModule authz_host_module modules/mod_authz_host.so
LoadModule env_module modules/mod_env.so
LoadModule mime_magic_module modules/mod_mime_magic.so
LoadModule headers_module modules/mod_headers.so
LoadModule expires_module modules/mod_expires.so
LoadModule ident_module modules/mod_ident.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule mime_module modules/mod_mime.so
LoadModule status_module modules/mod_status.so
LoadModule deflate_module modules/mod_deflate.so
LoadModule dir_module modules/mod_dir.so

LoadModule alias_module modules/mod_alias.so
LoadModule rewrite_module modules/mod_rewrite.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule fastcgi_module modules/mod_fastcgi.so

LoadModule access_compat_module modules/mod_access_compat.so
LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
LoadModule slotmem_shm_module modules/mod_slotmem_shm.so
LoadModule authz_core_module modules/mod_authz_core.so

HostnameLookups Off
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 5
UseCanonicalName Off
ServerTokens Prod

ErrorLog "/home/www/logs/apache/error.log"
LogFormat "%h %l %u %t \"%r\" %>s %b %D \"%{Referer}i\" \"%{User-agent}i\"" combined
CustomLog "/home/www/logs/apache/access.log" combined
PidFile /home/www/logs/apache.pid

User www
Group www

<IfModule mpm_prefork_module>
    StartServers         10 
    MinSpareServers      10
    MaxSpareServers      10
</IfModule>

<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
</IfModule>

<IfModule setenvif_module>
    BrowserMatch Mb2345Browser bad_bot
    BrowserMatch LieBaoFast bad_bot
    BrowserMatch UCBrowser bad_bot
    BrowserMatch MQQBrowser bad_bot
</IfModule>

<VirtualHost *:#WGE_APACHE_PORT>
    ServerAdmin wge@sanger.ac.uk
    FastCGIExternalServer /wge.fcgi -host 0.0.0.0:#WGE_FCGI_PORT -idle-timeout 300 -pass-header Authorization
    Alias /htgt /home/www/htgt
    Alias / /wge.fcgi/

    <Directory />
        Options FollowSymLinks
        AllowOverride None
        Order Allow,deny
        Allow from all
        Deny from env=bad_bot
    </Directory>
    <Directory /home/www/htgt>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride None
        Order Allow,deny
        Allow from all
    </Directory>
</VirtualHost>
