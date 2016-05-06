FROM registry:2
MAINTAINER Yannick Buron yburon@goclouder.net

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -qy install locales
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN DEBIAN_FRONTEND=noninteractive locale-gen en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN update-locale LANG=en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor vim ssmtp mailutils curl
#/usr/bin/mail is used by shinken. I did all I could but I couldn't make it call ssmtp for the relay to postfix container.
#Be cautious to any application which also use it.
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
RUN rm /usr/bin/mail
RUN ln -s /usr/sbin/ssmtp /usr/bin/mail
#RUN echo "" > /etc/ssmtp/ssmtp.conf

RUN DEBIAN_FRONTEND=noninteractive apt-get -y -q install nginx
RUN echo "server {" >> /etc/nginx/sites-available/docker-registry
RUN echo "    listen      443;" >> /etc/nginx/sites-available/docker-registry
RUN echo "" >> /etc/nginx/sites-available/docker-registry
RUN echo "    # ssl files" >> /etc/nginx/sites-available/docker-registry
RUN echo "    ssl on;" >> /etc/nginx/sites-available/docker-registry
RUN echo "    ssl_certificate     /etc/ssl/certs/docker-registry.crt;" >> /etc/nginx/sites-available/docker-registry
RUN echo "    ssl_certificate_key /etc/ssl/private/docker-registry.key;" >> /etc/nginx/sites-available/docker-registry
RUN echo "    keepalive_timeout   60;" >> /etc/nginx/sites-available/docker-registry
RUN echo "" >> /etc/nginx/sites-available/docker-registry
RUN echo "    # limit ciphers" >> /etc/nginx/sites-available/docker-registry
RUN echo "    ssl_ciphers             HIGH:!ADH:!MD5;" >> /etc/nginx/sites-available/docker-registry
RUN echo "    ssl_protocols           SSLv3 TLSv1;" >> /etc/nginx/sites-available/docker-registry
RUN echo "    ssl_prefer_server_ciphers on;" >> /etc/nginx/sites-available/docker-registry
RUN echo "" >> /etc/nginx/sites-available/docker-registry
RUN echo "    # proxy buffers" >> /etc/nginx/sites-available/docker-registry
RUN echo "    proxy_buffers 16 64k;" >> /etc/nginx/sites-available/docker-registry
RUN echo "    proxy_buffer_size 128k;" >> /etc/nginx/sites-available/docker-registry
RUN echo "" >> /etc/nginx/sites-available/docker-registry
RUN echo "    ## default location ##" >> /etc/nginx/sites-available/docker-registry
RUN echo "    location / {" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_pass  http://localhost:5000;" >> /etc/nginx/sites-available/docker-registry
RUN echo "        # force timeouts if the backend dies" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_redirect off;" >> /etc/nginx/sites-available/docker-registry
RUN echo "" >> /etc/nginx/sites-available/docker-registry
RUN echo "        # set headers" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_set_header    Host            \\\$host;" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_set_header    X-Real-IP       \\\$remote_addr;" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_set_header    X-Forwarded-For \\\$proxy_add_x_forwarded_for;" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_set_header    X-Forwarded-Proto https;" >> /etc/nginx/sites-available/docker-registry
RUN echo "" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_connect_timeout       3600;" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_send_timeout          3600;" >> /etc/nginx/sites-available/docker-registry
RUN echo "        proxy_read_timeout          3600;" >> /etc/nginx/sites-available/docker-registry
RUN echo "        send_timeout                3600;" >> /etc/nginx/sites-available/docker-registry
RUN echo "    }" >> /etc/nginx/sites-available/docker-registry
RUN echo "" >> /etc/nginx/sites-available/docker-registry
RUN echo "}" >> /etc/nginx/sites-available/docker-registry
RUN ln -s /etc/nginx/sites-available/docker-registry /etc/nginx/sites-enabled/docker-registry
#RUN echo "[supervisord]" >> /etc/supervisor/conf.d/supervisord.conf
#RUN echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf
#RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf
#RUN echo "[program:docker-registry]" >> /etc/supervisor/conf.d/supervisord.conf
#RUN echo "command=docker-registry" >> /etc/supervisor/conf.d/supervisord.conf
#RUN echo "" >> /etc/supervisor/conf.d/supervisord.conf
#RUN echo "[program:nginx]" >> /etc/supervisor/conf.d/supervisord.conf
#RUN echo "command=/etc/init.d/nginx start" >> /etc/supervisor/conf.d/supervisord.conf
#CMD ["/usr/bin/supervisord"]
EXPOSE 22 5000
VOLUME /docker-registry
