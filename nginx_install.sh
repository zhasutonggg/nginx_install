#!/bin/bash
# FileName: nginx_install.sh
# Author: zhasutong
# Email: 1875786959@qq.com
# Date: 2021-01-03 11:47:37
# Description: install nginx 
NGINX_PACKAGE="nginx-1.18.0.tar.gz"
NGINX_URL="https://nginx.org/download/nginx-1.18.0.tar.gz"
NGINX_TAR="nginx-1.18.0"
#gcc源码编译时需要
yum install gcc-c++  wget -y 
#PCRE pcre-devel安装，http模块使用pcre来解析正则表达式
yum install -y pcre pcre-devel 
#zlib安装，使用zlib对http包的内容进行gzip
yum install -y zlib zlib-devel
#OpenSSL 安装，强大的安全套接字层密码库，nginx不仅支持http协议，还支持https
yum install -y openssl openssl-devel
if [ $? -eq 0 ]; then
	mkdir -p /usr/local/nginx
	cd /opt
	wget -c ${NGINX_URL}
else
	echo '下载失败！'
fi
if [ $? -eq 0 ]; then
	cd /opt
	tar -xf ${NGINX_PACKAGE} 
	mv ${NGINX_TAR} /usr/local/nginx
	cd /usr/local/nginx/${NGINX_TAR} 
	./configure  && make && make install
else
	echo "安装失败"
fi
if [ $? -eq 0 ]; then
	echo '安装成功'
else
	echo '安装失败'
fi

#编写Sys init启动脚本
cat >>/usr/lib/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network.target remote-fs.target nss-lookup.target
[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
