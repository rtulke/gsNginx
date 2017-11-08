## NON-SSL redirect to SSL
server {

        listen 80;
        server_name gsales.mydomain.com;
        root /home/webapp/gsales.mydomain.com/;

        ## letsencrypt
        location ~ /\.well-known\/acme-challenge {
                allow all;
        }

        charset utf-8;

        return 301 https://gsales.mydomain.com$request_uri;

        access_log /var/log/nginx/gsales.mydomain.com.access.log;
        error_log /var/log/nginx/gsales.mydomain.com.error.log info;
}

## SSL
server {

        listen 443;
        server_name gsales.mydomain.com;
        root /home/webapp/gsales.mydomain.com/;

        access_log /var/log/nginx/gsales.mydomain.com.access.log;
        error_log /var/log/nginx/gsales.mydomain.com.error.log info;

        ssl on;

        ssl_certificate /etc/letsencrypt/live/gsales.mydomain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/gsales.mydomain.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/gsales.mydomain.com/chain.pem;
        ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH:!AESGCM;

        location / {
                index index.php index.html;
                try_files = $uri @missing;
                #try_files $uri $uri/index.php;
        }

        location @missing {
                rewrite ^ $scheme://$host/index.php permanent;
        }

        location /DATA/ {
                deny all;
                return 404;
                #autoindex off;
        }

        location ~* \.php$ {
                try_files $uri =404;
                fastcgi_pass unix:/var/run/php5-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
                include /etc/nginx/fastcgi_params;
        }

        ## letsencrypt
        location ~ /\.well-known\/acme-challenge {
                allow all;
        }

        charset utf-8;
}
