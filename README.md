# g*Sales Nginx Configuration
[gSales](https://www.gsales.de "gSales's Homepage") Nginx Configuration on Debian 8.x, 9.x


## 1. Step - Download Zend Guard Loader from website:

- <http://www.zend.com/en/products/loader/downloads#Linux>

You have to register on Zend website first.

## 2. Step - Zend Guard Loader 5.6 installation

after registration:

~~~
su - root
cd /tmp
wget http://downloads.zend.com/guard/7.0.0/zend-loader-php5.6-linux-x86_64_update1.tar.gz
tar -zxvf zend-loader-php5.6-linux-x86_64_update1.tar.gz
mkdir -p /usr/local/zend 
cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so /usr/local/zend/ZendGuardLoader.so
cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so /usr/lib/php5/20131226/
cp zend-loader-php5.6-linux-x86_64/opcache.so /usr/lib/php5/20131226/
chmod 644 /usr/local/zend/ZendGuardLoader.so
~~~

## 3. Step PHP FPM Nginx configuration

~~~
vim /etc/php5/fpm/php.ini 
~~~

Add the following section to "Miscellaneous":

~~~
;;;;;;;;;;;;;;;;;
; Miscellaneous ;
;;;;;;;;;;;;;;;;;

; Zend Loader
zend_extension=/usr/local/zend/ZendGuardLoader.so 
zend_loader.enable=1 
zend_loader.disable_licensing=0 
zend_loader.obfuscation_level_support=3 
zend_loader.license_path=
~~~

~~~
systemctl restart php5-fpm
~~~


## Nginx site configuration

~~~
su - root
mkdir dev
cd dev
git clone https://github.com/rtulke/gsNginx.git
cp ./gsNginx/etc/nginx/sites-available/gsales.mydomain.com /etc/nginx/sites-available/
cd /etc/nginx/sites-enabled/
ln -s ../sites-available/gsales.mydomain.com gsales.mydomain.com
systemctl restart nginx
~~~

- /etc/init.d/nginx restart
- service nginx restart

## Troubleshooting

### Incompatible file format

Error Log from Nginx:

~~~
2017/01/31 15:51:03 [error] 20891#0: *1 FastCGI sent in stderr: "PHP message: PHP Fatal error:  Incompatible file format: 
The encoded file has format major ID 5, whereas the Loader expects 7 in /home/webapp/gsales.mydomain.com/index.php on line 0" 
while reading response header from upstream, client: 127.0.0.1, server: gsales.mydomain.com, request: "GET / HTTP/1.1",
upstream: "fastcgi://unix:/var/run/php5-fpm.sock:", host: "gsales.mydomain.com"
~~~

Important 

~~~
Incompatible file format:  The encoded file has format major ID 5, whereas the Loader expects 7
~~~

This means that the website (the PHP files) was coded with Zend 5.5 and it is expected to use Zend 5.5.
But instead version 7 (ZendLoader 7) was installed. The installation of an older version is a remedy.

### after upgrading php-fpm

Sometimes, after upgrading php and also php-fpm i had some issues with gsales (site is down), then i run step 2 and 3 again and that works for me.
